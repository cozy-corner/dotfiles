---
syntax: coderabbit-review
description: AI-driven review of uncommitted changes
allowed-tools: Bash(coderabbit:*), Bash(git:*)
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

## How it works
1. **Check git status** - Show current uncommitted changes
2. **Run CodeRabbit CLI** - Execute `coderabbit --prompt-only` directly
3. **Process results** - Analyze AI prompts and format findings
4. **Provide detailed report** - Human-readable summary with specific fixes

## Review Process
CodeRabbit CLI provides:
- Line-by-line AI-powered review comments
- Detection of defects, refactoring opportunities, and missed unit tests
- Context-aware analysis of code changes
- Security vulnerability identification

## Usage
Simply run: `/coderabbit-review`

Claude Code will automatically:
- Execute the CodeRabbit review directly
- Process and format the results
- Provide actionable recommendations
- Include security vulnerability assessments

## Prerequisites
Ensure you're authenticated with CodeRabbit: `coderabbit auth login`