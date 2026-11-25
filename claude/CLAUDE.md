@~/dotfiles/agents/AGENTS.md

## Claude Code
- For code symbol resolution (finding where a symbol is defined, referenced, or implemented), prefer the LSP tool (goToDefinition / findReferences / goToImplementation) over Grep — it uses type information, so it is more precise and won't confuse same-named symbols. Fall back to Grep for plain-text search or when no language server is configured.
