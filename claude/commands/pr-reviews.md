---
syntax: pr-reviews [PR番号]
description: PRの未解決コメントとレビューを取得（resolved除外・nitpicks対応・ページング対応）
allowed-tools: Bash(gh:*)
---

You are an AI assistant integrated into a git-based version control system. Your task is to fetch and display the actionable comments and reviews from a GitHub pull request. "Actionable" means everything EXCEPT review comments whose thread has been resolved — those have already been addressed, so surfacing them just wastes the reader's attention. PR-level comments and review summaries have no resolved concept and are always included.

Follow these steps:

1. Use `gh pr view ${1:-} --json number,headRepository,headRefName` to get the PR number, repository info, and branch
2. Extract owner, repo, number, and branch from the JSON response
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
7. **Exclude resolved review comments**: drop any comment from step 5 whose `id` is in the resolved set (match REST `id` against GraphQL `databaseId`). Resolved status only applies to line-level review comments — PR-level comments and review summaries have no resolved concept and are always shown.
8. Pay particular attention to the following fields in reviews: `body`, `state`, `user`, `submitted_at`
9. Pay particular attention to the following fields in review comments: `body`, `diff_hunk`, `path`, `line`, `position`, `in_reply_to_id`
10. Review comments may have an `in_reply_to_id` field - use this to identify replies and nest them under the parent comment
11. If a review comment references code, consider fetching it using `gh api /repos/{owner}/{repo}/contents/{path}?ref={branch} | jq .content -r | base64 -d`
12. Parse and format all comments in a readable way
13. Return ONLY the formatted comments, with no additional text. At the very end, append one line noting how many resolved comments were excluded, e.g. `(resolved 3件を除外)`. If none were excluded, omit the line.

Format the comments as:

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

If there are no comments or reviews, return "No comments or reviews found."

Remember:
1. **Always use `--paginate` with `per_page=100`** to fetch all comments (not just first 30)
2. **Always fetch the /reviews endpoint** - this is critical for CodeRabbit and other bots
3. **Always exclude resolved review comments** using the GraphQL `reviewThreads.isResolved` status - do not investigate or display comments in resolved threads
4. Only show the actual comments, no explanatory text
5. Include review state (APPROVED/CHANGES_REQUESTED/COMMENTED)
6. Include PR-level comments, reviews, and code review comments
7. Preserve the threading/nesting of comment replies
8. Show the file and line number context for code review comments
9. Use jq to parse the JSON responses from the GitHub API
10. Group related information together for readability
