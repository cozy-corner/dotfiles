---
syntax: pr-reviews [PR番号]
description: PRの未解決コメントとレビューを取得・表示し、pr-tasks 連携用にファイル保存（resolved除外・nitpicks対応・ページング対応）
allowed-tools: Bash(gh:*), Write
---

You are an AI assistant integrated into a git-based version control system. Your task is to fetch the actionable comments and reviews from a GitHub pull request, display them, and save them to a file for further processing (e.g. by `pr-tasks`).

"Actionable" means everything EXCEPT review comments whose thread has been resolved — those have already been addressed, so surfacing them just wastes the reader's attention. PR-level comments and review summaries have no resolved concept and are always included.

Follow these steps:

1. Use `gh pr view ${1:-} --json number,title,headRepository,headRefName` to get the PR number, title, repository info, and branch
2. Extract owner, repo, number, title, and branch from the JSON response
3. Use `gh api --paginate /repos/{owner}/{repo}/issues/{number}/comments?per_page=100` to get PR-level comments
4. **Use `gh api --paginate /repos/{owner}/{repo}/pulls/{number}/reviews?per_page=100` to get PR reviews (CRITICAL: includes CodeRabbit nitpicks)**
5. Use `gh api --paginate /repos/{owner}/{repo}/pulls/{number}/comments?per_page=100` to get review comments on specific lines
6. **Fetch resolved-thread status via GraphQL (REST does not expose it).** A busy PR can have more than 100 review threads, so paginate — `gh api graphql --paginate` walks every page automatically as long as the query exposes a `$endCursor` variable and a `pageInfo { hasNextPage endCursor }` block. Run:
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
7. **Exclude resolved review comments**: drop any comment from step 5 whose `id` is in the resolved set (match REST `id` against GraphQL `databaseId`). This is the ONLY filter applied — do not skip comments for any other reason (reactions, user type, bot vs human, etc.). Resolved status applies only to line-level review comments; PR-level comments and review summaries are always shown.
8. Pay particular attention to the following fields in reviews: `body`, `state`, `user`, `submitted_at`
9. Pay particular attention to the following fields in review comments: `body`, `diff_hunk`, `path`, `line`, `position`, `in_reply_to_id`
10. **Display EVERY remaining comment from step 5, regardless of `in_reply_to_id` value** — comments with `in_reply_to_id == null` are PRIMARY comments (display prominently); comments with `in_reply_to_id != null` are REPLIES (nest under their parent comment)
11. If a review comment references code, consider fetching it using `gh api /repos/{owner}/{repo}/contents/{path}?ref={branch} | jq .content -r | base64 -d`
12. Parse and format all comments using the format specified in the "Format the comments as:" section below
13. **Write the complete formatted output to a file named `PR-{number}-reviews.md` in the current directory using the Write tool**
    - Include a header with PR number and title
    - Include all formatted sections: PR Reviews, Review Comments, PR-level Comments
    - Include the Summary section at the end with total counts
14. Display a summary message to the user indicating the file was created and the total counts

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

## Summary

- **PR-level comments**: X件
- **Reviews**: Y件
- **Review comments (未解決)**: Z件
  - **Primary comments (in_reply_to_id == null)**: A件
  - **Reply comments (in_reply_to_id != null)**: B件
- **Resolved (除外)**: R件

If there are no comments or reviews, return "No comments or reviews found."

Remember:
1. **Always use `--paginate` with `per_page=100`** to fetch all comments (not just first 30)
2. **Always fetch the /reviews endpoint** - this is critical for CodeRabbit and other bots
3. **Always exclude resolved review comments** using the GraphQL `reviewThreads.isResolved` status - do not investigate or display comments in resolved threads. This is the only allowed filter; never skip a non-resolved comment for any other reason
4. **Display ALL non-resolved comments with `in_reply_to_id == null` as primary comments** - these are the main review points
5. **Display ALL non-resolved comments with `in_reply_to_id != null` as nested replies** - but still display them
6. Include review state (APPROVED/CHANGES_REQUESTED/COMMENTED)
7. Include PR-level comments, reviews, and code review comments
8. Preserve the threading/nesting of comment replies
9. Show the file and line number context for code review comments
10. Use jq to parse the JSON responses from the GitHub API
11. Group related information together for readability
12. **Add a summary at the end showing total counts**, including how many resolved comments were excluded
13. **Write the complete formatted output to `PR-{number}-reviews.md` using the Write tool**
14. **After writing the file, display a brief message: "✅ Created PR-{number}-reviews.md with X PR-level comments, Y reviews, Z review comments (A primary + B replies), R resolved excluded"**
15. **CRITICAL: Do NOT output HTML tags** - Remove all HTML tags like `<details>`, `<summary>`, `<blockquote>`, etc. from the output. Convert them to standard Markdown (headings, quotes, lists) or simply remove them
