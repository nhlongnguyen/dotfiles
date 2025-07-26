# General Coding Principles

## Fundamental Principles

### KISS - Keep It Stupid Simple
- Write the simplest solution that works
- Avoid unnecessary complexity and over-engineering
- Choose clarity over cleverness
- If you can't explain it simply, you don't understand it well enough

### YAGNI - You Aren't Gonna Need It
- Don't implement features until they're actually needed
- Avoid anticipating future requirements
- Focus on current, concrete needs
- Remove unused code regularly

### DRY - Don't Repeat Yourself
- Every piece of knowledge should have a single, unambiguous representation
- Extract common functionality into reusable components
- Use constants for repeated values
- Be careful not to over-DRY (avoid premature abstraction)

### SOLID Principles

#### Single Responsibility Principle (SRP)
- Each class/function should have one reason to change
- Do one thing and do it well
- High cohesion within modules
- Clear, focused interfaces

#### Open/Closed Principle (OCP)
- Software entities should be open for extension, closed for modification
- Use inheritance, composition, and interfaces for extensibility
- Avoid modifying existing, working code
- Design for change from the beginning

#### Liskov Substitution Principle (LSP)
- Subtypes must be substitutable for their base types
- Derived classes should extend, not replace, base class functionality
- Maintain behavioral compatibility in inheritance hierarchies
- Ensure contracts are preserved in subclasses

#### Interface Segregation Principle (ISP)
- Many client-specific interfaces are better than one general-purpose interface
- Clients shouldn't depend on interfaces they don't use
- Keep interfaces focused and cohesive
- Avoid fat interfaces with multiple responsibilities

#### Dependency Inversion Principle (DIP)
- Depend on abstractions, not concretions
- High-level modules shouldn't depend on low-level modules
- Both should depend on abstractions
- Abstractions shouldn't depend on details

## Code Quality Standards

### Naming
- Use intention-revealing names
- Choose searchable names over abbreviations
- Use pronounceable names
- Avoid mental mapping (don't use single-letter variables except for loops)
- Use nouns for classes, verbs for functions
- Be consistent with naming conventions throughout the codebase

### Functions
- Keep functions small (ideally < 20 lines)
- Functions should do one thing (implement SRP)
- Use descriptive names that explain what the function does
- Minimize the number of parameters (< 4 ideally)
- Avoid deep nesting (max 3 levels)
- Return early to reduce complexity
- Prefer pure functions when possible

### Comments
- Code should be self-documenting
- Write comments for why, not what
- Update comments when code changes
- Remove outdated comments
- Use comments to explain complex business logic
- Document assumptions and constraints
- Explain non-obvious optimizations

### Error Handling
- Use exceptions for exceptional cases, not control flow
- Fail fast - catch errors early in the process
- Provide meaningful error messages with context
- Don't ignore exceptions or errors
- Use specific exception types rather than generic ones
- Log errors appropriately for debugging
- Handle errors at the appropriate level of abstraction
- Consider error recovery strategies
- Validate inputs and handle edge cases
- Use consistent error handling patterns across the codebase

### Structure and Organization
- Group related functionality together
- Use consistent directory structure
- Keep file sizes reasonable (< 500 lines ideally)
- Use meaningful file names that reflect content
- Separate concerns into different files
- Organize imports/dependencies logically
- Follow established project conventions
- Use modules/namespaces to avoid naming conflicts

### Dependencies
- Minimize external dependencies
- Use dependency injection for better testability
- Avoid circular dependencies
- Keep dependencies explicit and visible
- Regular dependency updates and security audits
- Document dependency requirements and versions
- Consider dependency weight and performance impact
- Use interfaces to decouple from concrete implementations

## Design Paradigms

### Object-Oriented Programming (OOP)
**Recommended Languages:** Java, C#, C++, Python, Ruby, Kotlin, Scala, TypeScript

#### Core OOP Concepts
- **Encapsulation**: Hide internal implementation details, expose only necessary interfaces
- **Inheritance**: Use "is-a" relationships carefully, prefer composition over inheritance
- **Polymorphism**: Use interfaces and abstract classes to enable flexible designs
- **Abstraction**: Focus on essential features, hide unnecessary complexity

#### OOP Best Practices
- Favor composition over inheritance
- Program to interfaces, not implementations
- Use design patterns appropriately (don't over-pattern)
- Keep class hierarchies shallow and focused
- Avoid deep inheritance chains (max 3-4 levels)
- Ensure classes have clear responsibilities
- Use proper access modifiers (private, protected, public)

### Functional Programming (FP)
**Recommended Languages:** Haskell, F#, Clojure, Erlang/Elixir, Scala, JavaScript, Python, Ruby

#### Core FP Principles
- **Immutability**: Prefer immutable data structures, avoid state mutation
- **Pure Functions**: Functions should have no side effects and always return the same output for the same input
- **Higher-Order Functions**: Functions that take other functions as parameters or return functions
- **Function Composition**: Build complex operations by combining simple functions
- **Referential Transparency**: Expressions can be replaced with their values without changing program behavior

#### FP Best Practices
- Minimize mutable state
- Use map, filter, reduce instead of loops
- Avoid shared mutable state
- Handle errors functionally (Option/Maybe types, Result types)
- Separate pure and impure code
- Use recursion instead of iteration when appropriate

#### FP Benefits
- Easier to reason about and test
- Better concurrency and parallelization
- Fewer bugs related to shared state
- More modular and reusable code

### Hybrid Approaches
**Languages Supporting Multiple Paradigms:** JavaScript, Python, Ruby, Scala, F#, Kotlin, Swift, Rust

- Choose the right paradigm for the problem
- Use OOP for modeling domain entities and their relationships
- Use FP for data transformations and business logic
- Combine approaches within the same codebase when beneficial
- Be consistent within modules/components

## Testing Practices

### Testing Pyramid
- **Unit Tests** (70%): Test individual components in isolation
- **Integration Tests** (20%): Test component interactions
- **End-to-End Tests** (10%): Test complete user workflows

### Unit Testing Principles
- Write tests first (TDD approach)
- One assertion per test
- Tests should be independent and not depend on each other
- Use descriptive test names that explain what is being tested
- Tests should be fast (< 1 second each)
- Tests should be repeatable and produce consistent results
- Aim for 80-90% code coverage on critical paths

### Test Structure
- **Arrange**: Set up test data and conditions
- **Act**: Execute the code under test
- **Assert**: Verify the expected outcome
- **Cleanup**: Reset state if needed

### Testing Best Practices
- Mock external dependencies (databases, APIs, file systems)
- Test edge cases and error conditions
- Use test fixtures and factories for consistent test data
- Keep test data minimal and focused
- Use meaningful assertions with clear failure messages
- Test behavior, not implementation details
- Refactor tests when production code changes

### Integration and E2E Testing
- Test component interactions and data flow
- Verify API contracts between services
- Test complete user workflows for critical paths
- Use production-like environments for E2E tests
- Test authentication and authorization flows
- Validate error handling and recovery scenarios

## Performance and Maintainability

### Performance Optimization
- Premature optimization is the root of all evil
- Measure before optimizing - use profiling tools
- Optimize the critical path first
- Consider readability vs. performance trade-offs
- Profile your code to identify bottlenecks
- Use appropriate data structures and algorithms
- Consider memory usage and garbage collection
- Optimize database queries and network calls
- Use caching strategically
- Monitor performance in production

### Maintainability
- Write code for humans, not just computers
- Use version control effectively with meaningful commits
- Document architectural decisions and complex business logic
- Regular refactoring to improve code quality
- Code reviews are mandatory for all changes
- Keep technical debt manageable
- Use consistent coding standards across the team
- Maintain up-to-date documentation
- Plan for scalability and extensibility
- Monitor and log application behavior

### Code Style
- Use consistent formatting throughout the codebase
- Follow language-specific conventions and idioms
- Use linting tools to enforce style rules
- Agree on team standards and document them
- Automate style enforcement in CI/CD pipeline
- Use meaningful variable and function names
- Maintain consistent indentation and spacing
- Group related code logically

## Anti-Patterns and Common Mistakes

### Design Anti-Patterns
- **God Objects**: Classes that do too much - violate SRP
- **Spaghetti Code**: Tangled control flow that's hard to follow
- **Copy-Paste Programming**: Duplicating code instead of creating reusable components
- **Magic Numbers and Strings**: Hardcoded values without explanation
- **Premature Abstraction**: Creating abstractions before understanding requirements
- **Tight Coupling**: Components that depend heavily on each other's implementation
- **Circular Dependencies**: Modules that depend on each other cyclically

### Implementation Mistakes
- Ignoring compiler warnings and linting errors
- Not handling edge cases and error conditions
- Hardcoding configuration values instead of using config files
- Not cleaning up resources (files, connections, memory)
- Writing code without tests or adequate test coverage
- Not validating inputs and assumptions
- Using inefficient algorithms or data structures
- Not considering concurrency and thread safety

### Testing Anti-Patterns
- Testing implementation details instead of behavior
- Over-mocking everything instead of testing real interactions
- Writing brittle tests that break with minor changes
- Tests that depend on execution order
- Not testing edge cases and error conditions
- Ignoring test maintenance and keeping tests up-to-date

## Implementation Guidelines

### Before Writing Code
- [ ] Understand the requirements clearly
- [ ] Design the solution first
- [ ] Consider existing patterns and conventions
- [ ] Think about testing strategy
- [ ] Consider performance implications
- [ ] Plan for error handling

### While Writing Code
- [ ] Follow naming conventions
- [ ] Keep functions small and focused
- [ ] Write self-documenting code
- [ ] Handle errors appropriately
- [ ] Consider edge cases
- [ ] Write tests as you go
- [ ] Follow the Boy Scout Rule (leave code cleaner than you found it)

### After Writing Code
- [ ] Review your own code
- [ ] Write or update tests
- [ ] Update documentation
- [ ] Refactor if needed
- [ ] Get peer review
- [ ] Run linting and static analysis tools
- [ ] Verify performance meets requirements

### Code Review Checklist
- [ ] Does the code follow established patterns?
- [ ] Are naming conventions consistent?
- [ ] Is error handling appropriate?
- [ ] Are tests comprehensive?
- [ ] Is the code readable and maintainable?
- [ ] Are there any security concerns?
- [ ] Does it meet performance requirements?

## Remember

> "Any fool can write code that a computer can understand. Good programmers write code that humans can understand." - Martin Fowler

> "The best code is no code at all." - Jeff Atwood

> "Simplicity is the ultimate sophistication." - Leonardo da Vinci

> "First, solve the problem. Then, write the code." - John Johnson

> "Code is read much more often than it is written." - Guido van Rossum