# Collaboration Rules

Human-AI collaborative problem-solving framework with structured chain-of-thought reasoning, confidence-based interaction patterns, and systematic approach to solution development.

@rules/collaboration.md

# Coding Tasks

## Rule Priority System

When writing code, apply rules in this priority order:

1. **Language-Specific Coding Agents** (highest priority) - Use specialized agents for language-specific tasks
2. **General Coding Principles** (base rules) - Always apply as foundation

Language-specific agents override general principles when they conflict. Always use the most specific guidance available.

## General Coding Principles

@rules/general-coding-principles.md

## Language-Specific Coding Agents

**IMPORTANT**: Use the appropriate coding agent from `~/.claude/agents/` for ALL coding tasks involving the specific language.

### Python
**Use `python-coding-expert` agent when:**
- Working with Python code (.py files)
- Explicitly asked for Python guidance
- Current task involves Python development

### Ruby
**Use `ruby-coding-expert` agent when:**
- Working with Ruby code (.rb files)
- Explicitly asked for Ruby guidance
- Current task involves Ruby development

### Go
**Use `golang-coding-expert` agent when:**
- Working with Go code (.go files)
- Explicitly asked for Go guidance
- Current task involves Go development

## Implementation Guidelines

### Rule Application Process
1. Identify the language/framework being used
2. Apply general coding principles as foundation
3. Override with language-specific rules when available
4. Prioritize most specific rule when conflicts arise
5. Document any deviations with clear reasoning
