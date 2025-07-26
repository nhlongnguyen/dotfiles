# Collaboration Rules

Human-AI collaborative problem-solving framework with structured chain-of-thought reasoning, confidence-based interaction patterns, and systematic approach to solution development.

@rules/collaboration.md

# Coding Standards

## Rule Priority System

When writing code, apply rules in this priority order:

1. **Language-Specific Rules** (highest priority) - Apply when working with specific languages/frameworks
2. **General Coding Principles** (base rules) - Always apply as foundation

Language-specific rules override general principles when they conflict. Always follow the most specific rule available.

## General Coding Principles

@rules/general-coding-principles.md

## Language-Specific Rules

**IMPORTANT**: Only load and apply language-specific rules when working with that specific language or when explicitly requested.

### Python
**Apply ONLY when:**
- Working with Python code (.py files)
- Explicitly asked for Python guidance
- Current task involves Python development

Available at: `rules/python-coding-principles.md`

### Ruby
**Apply ONLY when:**
- Working with Ruby code (.rb files)
- Explicitly asked for Ruby guidance
- Current task involves Ruby development

Available at: `rules/ruby-coding-principles.md`

## Implementation Guidelines

### Rule Application Process
1. Identify the language/framework being used
2. Apply general coding principles as foundation
3. Override with language-specific rules when available
4. Prioritize most specific rule when conflicts arise
5. Document any deviations with clear reasoning
