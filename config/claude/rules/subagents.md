# Subagent Delegation Guidelines

## Core Delegation Principle
IMMEDIATELY delegate ANY request for analysis, understanding, detailed accounts, narratives, explanations, or exploration of codebases/changes to subagents using Task tool BEFORE doing any other work. Handle
only trivial single-step tasks directly.

## Task Cohesion Rules

### Single Cohesive Delegation
Delegate the ENTIRE user request as a single cohesive task to ONE subagent when the request requires:
- Contextual continuity across components
- Shared understanding between analysis parts
- Narrative coherence in the response
- Cross-referencing between findings

**Do NOT** break such requests into separate todos/subtasks that would fragment the analysis or lose shared context.

### Independent Task Decomposition
ONLY decompose into separate subagents when:
- Components are truly independent
- No shared context needed between parts
- Each component can stand alone
- Results don't require cross-referencing

## Delegation Best Practices

### Context Provision
When delegating, always provide:
- Complete task description with specific deliverables
- Relevant context from the current session
- Any constraints or requirements
- Expected format or structure for results

### Information Gaps
Before delegating analysis tasks:
- Identify what information is available vs. needed
- Explicitly state any limitations or missing context
- Request additional context from user if analysis would be incomplete
- Don't proceed with analysis when lacking essential information

### Subagent Instructions
Include in every delegation:
- Instruction to report back both results AND contextual learnings
- Specific deliverables expected
- Any follow-up considerations for subsequent work
- Request for confidence assessment on findings