---
syntax: pr-export [PR番号]
description: PRのコメントとレビューを完全取得してファイル保存（pr-tasksとの連携用）
allowed-tools: Bash(gh:*), Write
---

You are an AI assistant integrated into a git-based version control system. Your task is to fetch and display ALL comments and reviews from a GitHub pull request, then save them to a file for further processing.

Follow these steps:

1. Use `gh pr view ${1:-} --json number,title,headRepository,headRefName` to get the PR number, title, repository info, and branch
2. Extract owner, repo, number, title, and branch from the JSON response
3. Use `gh api --paginate /repos/{owner}/{repo}/issues/{number}/comments?per_page=100` to get PR-level comments
4. **Use `gh api --paginate /repos/{owner}/{repo}/pulls/{number}/reviews?per_page=100` to get PR reviews (CRITICAL: includes CodeRabbit nitpicks)**
5. Use `gh api --paginate /repos/{owner}/{repo}/pulls/{number}/comments?per_page=100` to get review comments on specific lines
6. Pay particular attention to the following fields in reviews: `body`, `state`, `user`, `submitted_at`
7. Pay particular attention to the following fields in review comments: `body`, `diff_hunk`, `path`, `line`, `position`, `in_reply_to_id`
8. **CRITICAL: Display EVERY comment from step 5, regardless of `in_reply_to_id` value**
9. Review comments with `in_reply_to_id == null` are PRIMARY comments - display these prominently
10. Review comments with `in_reply_to_id != null` are REPLIES - nest them under their parent comment
11. **Do NOT filter out any comments based on reactions, user type, or any other criteria**
12. **Count and report the total number of comments in each category to verify completeness**
13. If a review comment references code, consider fetching it using `gh api /repos/{owner}/{repo}/contents/{path}?ref={branch} | jq .content -r | base64 -d`
14. Parse and format all comments using the format specified in the "Format the comments as:" section below
15. **Write the complete formatted output to a file named `PR-{number}-reviews.md` in the current directory using the Write tool**
    - Include a header with PR number and title
    - Include all formatted sections: PR Reviews, Review Comments, PR-level Comments
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

## Summary

- **PR-level comments**: X件
- **Reviews**: Y件
- **Review comments**: Z件
  - **Primary comments (in_reply_to_id == null)**: A件
  - **Reply comments (in_reply_to_id != null)**: B件

If there are no comments or reviews, return "No comments or reviews found."

Remember:
1. **Always use `--paginate` with `per_page=100`** to fetch all comments (not just first 30)
2. **Always fetch the /reviews endpoint** - this is critical for CodeRabbit and other bots
3. **NEVER filter or skip any comments** - every single comment must be displayed
4. **Display ALL comments with `in_reply_to_id == null` as primary comments** - these are the main review points
5. **Display ALL comments with `in_reply_to_id != null` as nested replies** - but still display them
6. Only show the actual comments, no explanatory text
7. Include review state (APPROVED/CHANGES_REQUESTED/COMMENTED)
8. Include PR-level comments, reviews, and code review comments
9. Preserve the threading/nesting of comment replies
10. Show the file and line number context for code review comments
11. Use jq to parse the JSON responses from the GitHub API
12. Group related information together for readability
13. **Add a summary at the end showing total counts: X PR-level comments, Y reviews, Z review comments (A primary + B replies)**
14. **Write the complete formatted output to `PR-{number}-reviews.md` using the Write tool**
15. **After writing the file, display a brief message: "✅ Created PR-{number}-reviews.md with X PR-level comments, Y reviews, Z review comments (A primary + B replies)"**
16. **CRITICAL: Do NOT output HTML tags** - Remove all HTML tags like `<details>`, `<summary>`, `<blockquote>`, etc. from the output. Convert them to standard Markdown (headings, quotes, lists) or simply remove them
