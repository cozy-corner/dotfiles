---
syntax: coderabbit-review
description: AI-driven review of uncommitted changes (runs in background)
allowed-tools: Bash(coderabbit:*), Bash(git:*), Bash(which:*)
---

Run CodeRabbit CLI review for uncommitted changes - perfect for pre-commit quality checks.

## Purpose
- **Pre-commit review** - Check code quality before committing
- **Instant feedback** - Get AI suggestions while coding
- **Quality gate** - Catch issues early in development

## What gets reviewed
- **Staged changes** (git add completed)
- **Working directory changes** (not yet git add)
- **All uncommitted modifications** in current repository

## Current status
!`git status`
!`git diff --stat`

## Review Process
CodeRabbit CLI provides:
- Line-by-line AI-powered review comments
- Detection of defects, refactoring opportunities, and missed unit tests
- Context-aware analysis of code changes
- Interactive or plain text output

## Execution Time
CodeRabbit reviews typically take 1-3 minutes depending on:
- Number of files changed
- Complexity of code
- Number of issues to analyze

Note: The command runs synchronously, so please wait for completion to see detailed results.

## Usage
Simply run: `/coderabbit-review`

This will review all your uncommitted changes (both staged and unstaged) and provide AI-powered suggestions for improvements.

**Tip for background execution:**
If you want to run the review in the background while continuing other work, you can:
1. First use the Task tool to launch a general-purpose agent
2. Then run `/coderabbit-review` in that agent
3. Continue working in your main session while the agent handles the review

## Tasks
Execute the following steps:

1. Verify coderabbit CLI is installed:

!`which coderabbit || echo "CodeRabbit CLI not found"`

2. Run the code review (takes 1-3 minutes):

!`coderabbit --plain 2>&1`

Note: This command runs synchronously. The review will take 1-3 minutes to complete.
Ensure you're authenticated with `coderabbit auth login` before running.