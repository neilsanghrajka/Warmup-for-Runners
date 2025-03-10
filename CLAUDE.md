# CLAUDE.md for Warmup for Runners

## Build & Run Commands
- Build: `xcodebuild build -scheme "Warmup for Runners Watch App"`
- Test all: `xcodebuild test -scheme "Warmup for Runners Watch App"`
- Test single: `xcodebuild test -scheme "Warmup for Runners Watch App" -only-testing:Warmup\ for\ Runners\ Watch\ AppTests/TestClassName/testMethodName`
- Run in simulator: Launch through Xcode with ⌘+R

## Code Style Guidelines
- Swift standard naming: camelCase for variables/methods, PascalCase for types
- SwiftUI views should be structured with clear property wrappers (@State, @Binding)
- Use 4-space indentation consistently
- Include file-level comments with purpose at the top of each file
- Group related properties and methods together
- Use Swift's strong type system, avoid forced unwrapping (!)
- Prefer SwiftUI's declarative syntax for UI components
- Use async/await for asynchronous operations
- Handle errors appropriately with do/catch blocks
- Keep view files under 300 lines, extract subviews when needed

## Project Organization
- Use MVVM architecture where appropriate
- Separate business logic from view code
- Group related functionality in extensions