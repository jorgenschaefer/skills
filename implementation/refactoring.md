# Refactor Candidates

After TDD cycle, look for:

- **Duplication** → Extract function/class
- **Long methods** → Break into private helpers (keep tests on public interface)
- **Shallow modules** → Combine or deepen
- **Feature envy** → Move logic to where data lives
- **Primitive obsession** → Introduce value objects
- **Callers that are now more complex** — if adding your new module made the code that calls it harder to understand, the abstraction is wrong
- **Test setup that's harder than the test itself** — if you need 20 lines to set up a test for 3 lines of behavior, the interface is too coupled
