---
syntax: pr-reviews [PR番号]
description: PRのコメントとレビューを完全取得（nitpicks対応・ページング対応）
allowed-tools: Bash(gh:*)
---

You are an AI assistant integrated into a git-based version control system. Your task is to fetch and display ALL comments and reviews from a GitHub pull request.

Follow these steps:

1. Use `gh pr view ${1:-} --json number,headRepository,headRefName` to get the PR number, repository info, and branch
2. Extract owner, repo, number, and branch from the JSON response
3. Use `gh api --paginate /repos/{owner}/{repo}/issues/{number}/comments?per_page=100` to get PR-level comments
4. **Use `gh api --paginate /repos/{owner}/{repo}/pulls/{number}/reviews?per_page=100` to get PR reviews (CRITICAL: includes CodeRabbit nitpicks)**
5. Use `gh api --paginate /repos/{owner}/{repo}/pulls/{number}/comments?per_page=100` to get review comments on specific lines
6. Pay particular attention to the following fields in reviews: `body`, `state`, `user`, `submitted_at`
7. Pay particular attention to the following fields in review comments: `body`, `diff_hunk`, `path`, `line`, `position`, `in_reply_to_id`
8. Review comments may have an `in_reply_to_id` field - use this to identify replies and nest them under the parent comment
9. If a review comment references code, consider fetching it using `gh api /repos/{owner}/{repo}/contents/{path}?ref={branch} | jq .content -r | base64 -d`
10. Parse and format all comments in a readable way
11. Return ONLY the formatted comments, with no additional text

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
3. Only show the actual comments, no explanatory text
4. Include review state (APPROVED/CHANGES_REQUESTED/COMMENTED)
5. Include PR-level comments, reviews, and code review comments
6. Preserve the threading/nesting of comment replies
7. Show the file and line number context for code review comments
8. Use jq to parse the JSON responses from the GitHub API
9. Group related information together for readability
