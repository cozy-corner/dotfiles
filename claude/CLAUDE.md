# Rules

- When reading or searching files, always use dedicated tools (Grep, Glob, Read) instead of Bash commands (grep, find, cat). Legitimate shell usage such as cat in a pipeline is acceptable.
- When launching subagents (Agent tool), always include in the prompt an explicit instruction to use Grep/Glob/Read instead of Bash grep/find/cat. Subagents do not reliably follow CLAUDE.md rules unless restated in their prompt.
