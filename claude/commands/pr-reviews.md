---
syntax: pr-reviews [PR番号]
description: PRの未解決コメントとレビューを取得・表示し、pr-tasks 連携用にファイル保存（resolved除外・nitpicks対応・check run annotation対応・ページング対応）
allowed-tools: Bash(gh:*), Write
---

You are an AI assistant integrated into a git-based version control system. Your task is to fetch every actionable piece of feedback on a GitHub pull request — comments, reviews, and CI/static-analysis findings from check runs and commit statuses — display them, and save them to a file for further processing (e.g. by `pr-tasks`).

"Actionable" means everything EXCEPT review comments whose thread has been resolved — those have already been addressed, so surfacing them just wastes the reader's attention. PR-level comments, review summaries, and check run / status findings have no resolved concept and are always included.

Coverage must be complete: the reader relies on this output to know whether ANY feedback exists, so a source that was not checked, or checks that had not finished, must never look like "no findings". Tools such as SonarCloud and CodeQL report file/line findings as check run annotations, not as comments.

Follow these steps:

1. Use `gh pr view ${1:-} --json number,title,headRepository,headRefName,headRefOid` to get the PR number, title, repository info, branch, and head commit SHA
2. Extract owner, repo, number, title, branch, and headRefOid from the JSON response
3. **Wait for checks to finish before collecting anything.** Run `gh pr checks {number}`; exit code 8 means checks are pending — then run `gh pr checks {number} --watch` and wait until it returns. Findings from checks that have not completed do not exist yet, so collecting early silently under-reports. If it reports no checks at all, look at `gh api '/repos/{owner}/{repo}/commits/{headRefOid}^/check-runs' --jq '.total_count'` (the parent commit): if the parent had check runs, the head's checks have not registered yet (typical right after a push) — re-run `gh pr checks {number}` every 30s until they appear, then `--watch`. Only treat "no checks" as final when the parent had none either
4. Use `gh api --paginate /repos/{owner}/{repo}/issues/{number}/comments?per_page=100` to get PR-level comments
5. **Use `gh api --paginate /repos/{owner}/{repo}/pulls/{number}/reviews?per_page=100` to get PR reviews (CRITICAL: includes CodeRabbit nitpicks)**
6. Use `gh api --paginate /repos/{owner}/{repo}/pulls/{number}/comments?per_page=100` to get review comments on specific lines
7. **Fetch resolved-thread status via GraphQL (REST does not expose it).** A busy PR can have more than 100 review threads, so paginate — `gh api graphql --paginate` walks every page automatically as long as the query exposes a `$endCursor` variable and a `pageInfo { hasNextPage endCursor }` block. Run:
   ```
   gh api graphql --paginate -f query='
   query($owner:String!, $repo:String!, $number:Int!, $endCursor:String) {
     repository(owner:$owner, name:$repo) {
       pullRequest(number:$number) {
         reviewThreads(first:100, after:$endCursor) {
           pageInfo { hasNextPage endCursor }
           nodes {
             isResolved
             comments(first:100) { nodes { databaseId } }
           }
         }
       }
     }
   }' -F owner={owner} -F repo={repo} -F number={number}
   ```
   Collect the `databaseId` of every comment inside a thread where `isResolved` is `true` into a "resolved" set. (The inner `comments(first:100)` is not paginated; a single thread with more than 100 replies is vanishingly rare, so its later replies could slip through un-excluded — an accepted limitation, unlike the thread-count cap which pagination above does handle.)
8. **Exclude resolved review comments**: drop any comment from step 6 whose `id` is in the resolved set (match REST `id` against GraphQL `databaseId`). This is the ONLY filter applied — do not skip comments for any other reason (reactions, user type, bot vs human, etc.). Resolved status applies only to line-level review comments; PR-level comments and review summaries are always shown.
9. **Fetch check runs and commit statuses for the head commit**:
   - `gh api --paginate '/repos/{owner}/{repo}/commits/{headRefOid}/check-runs?per_page=100' --jq '.check_runs[]'` — keep `id`, `name`, `app.slug`, `status`, `conclusion`, `details_url`, `output.title`, `output.summary`, `output.text`, `output.annotations_count`
   - For EVERY check run with `output.annotations_count > 0`, fetch `gh api --paginate '/repos/{owner}/{repo}/check-runs/{id}/annotations?per_page=100'` — keep `path`, `start_line`, `end_line`, `annotation_level`, `title`, `message`, `raw_details`. Do not skip any run or annotation level
   - `gh api --paginate '/repos/{owner}/{repo}/commits/{headRefOid}/statuses?per_page=100'` — legacy commit statuses (some CI/analysis services report only here); keep the latest entry per `context` with its `state`, `description`, `target_url`
10. Pay particular attention to the following fields in reviews: `body`, `state`, `user`, `submitted_at`
11. Pay particular attention to the following fields in review comments: `body`, `diff_hunk`, `path`, `line`, `position`, `in_reply_to_id`
12. **Display EVERY remaining comment from step 6, regardless of `in_reply_to_id` value** — comments with `in_reply_to_id == null` are PRIMARY comments (display prominently); comments with `in_reply_to_id != null` are REPLIES (nest under their parent comment)
13. If a review comment references code, consider fetching it using `gh api /repos/{owner}/{repo}/contents/{path}?ref={branch} | jq .content -r | base64 -d`
14. Parse and format all comments using the format specified in the "Format the comments as:" section below
15. **Write the complete formatted output to a file named `PR-{number}-reviews.md` in the current directory using the Write tool**
    - Include a header with PR number and title
    - Include all formatted sections: PR Reviews, Review Comments, PR-level Comments, Check Runs & Statuses
    - Include the Summary section at the end with total counts
16. Display a summary message to the user indicating the file was created and the total counts

Format the comments as:

# PR #{number} Reviews

{PR title}

---

## PR Reviews

[For each review:]
### Review by @author (APPROVED/CHANGES_REQUESTED/COMMENTED) - timestamp
> Review summary/body text (this is where CodeRabbit nitpicks appear)

---

## Review Comments (on specific code lines)

[For each comment thread:]
- @author on file.ts#L42 - timestamp:
  ```diff
  [diff_hunk from the API response]
  ```
  > quoted comment text

  [any replies indented]

---

## PR-level Comments

[For each comment:]
- @author - timestamp:
  > comment text

  [any replies indented]

---

## Check Runs & Statuses (head: {short headRefOid})

[For EVERY check run, including successful ones — a passing run can still carry annotations:]
### {name} ({app.slug}) - {conclusion or status}
{details_url}
> output.title / output.summary / output.text (omit empty ones)

[For each annotation of this run:]
- [{annotation_level}] {path}#L{start_line}-L{end_line}: {title}
  > {message}

[For each commit status context:]
- {context} - {state}: {description} ({target_url})

---

## Summary

- **PR-level comments**: X件
- **Reviews**: Y件
- **Review comments (未解決)**: Z件
  - **Primary comments (in_reply_to_id == null)**: A件
  - **Reply comments (in_reply_to_id != null)**: B件
- **Resolved (除外)**: R件
- **Check runs**: C件（failure F件）
  - **Annotations**: N件（failure / warning / notice の内訳）
- **Commit statuses**: S件

Always write every section and the Summary, even when counts are 0 — an explicit "0件" is how the reader knows the source was checked. If the head commit has 0 check runs and 0 statuses, say so explicitly in that section.

Remember:
1. **Always use `--paginate` with `per_page=100`** to fetch all comments (not just first 30)
2. **Always fetch the /reviews endpoint** - this is critical for CodeRabbit and other bots
3. **Always exclude resolved review comments** using the GraphQL `reviewThreads.isResolved` status - do not investigate or display comments in resolved threads. This is the only allowed filter; never skip a non-resolved comment for any other reason
4. **Display ALL non-resolved comments with `in_reply_to_id == null` as primary comments** - these are the main review points
5. **Display ALL non-resolved comments with `in_reply_to_id != null` as nested replies** - but still display them
6. Include review state (APPROVED/CHANGES_REQUESTED/COMMENTED)
7. Include PR-level comments, reviews, code review comments, and check run annotations / summaries / commit statuses — never conclude "no findings" from comments alone
8. Preserve the threading/nesting of comment replies
9. Show the file and line number context for code review comments
10. Use jq to parse the JSON responses from the GitHub API
11. Group related information together for readability
12. **Add a summary at the end showing total counts**, including how many resolved comments were excluded
13. **Write the complete formatted output to `PR-{number}-reviews.md` using the Write tool**
14. **After writing the file, display a brief message: "✅ Created PR-{number}-reviews.md with X PR-level comments, Y reviews, Z review comments (A primary + B replies), R resolved excluded, N annotations from C check runs (F failed), S statuses"**
15. **CRITICAL: Do NOT output HTML tags** - Remove all HTML tags like `<details>`, `<summary>`, `<blockquote>`, etc. from the output. Convert them to standard Markdown (headings, quotes, lists) or simply remove them
