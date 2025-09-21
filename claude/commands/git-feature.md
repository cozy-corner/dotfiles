---
syntax: git-feature [target-branch]
description: Auto-create feature branch, add changes, commit, and create PR
allowed-tools: Bash(git:*), Bash(gh:*)
---

Analyze the current changes and automatically:
1. Create an appropriate feature branch name based on the changes
2. Add all modified files
3. Generate a meaningful commit message
4. Create a pull request to ${1:-main}

## Current status and changes
!`git status`
!`git diff ${1:-main} --stat`
!`git diff ${1:-main}`

## Tasks
Based on the changes above:
1. Generate a descriptive feature branch name (use kebab-case, e.g., "add-user-authentication", "fix-navbar-styling")
2. Create and checkout that branch
3. Stage all changes with `git add .`
4. Generate a clear, concise commit message that describes what was changed and why
5. Commit the changes
6. Push the branch to origin
7. Create a pull request with a descriptive title and body explaining the changes
8. Target branch: ${1:-main}