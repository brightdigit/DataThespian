# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

DataThespian is a thread-safe SwiftData wrapper library that uses ModelActors to provide an optimized database interface. The library wraps SwiftData's ModelContext operations in a type-safe, async-friendly API using the Database protocol and Selector pattern.

## Build & Test Commands

### Building
```bash
# Build the package
swift build

# Build specific target
swift build --target DataThespian
```

### Testing
```bash
# Run all tests
swift test

# Run specific test
swift test --filter DataThespianTests.<TestClassName>/<testMethodName>

# Run tests with parallel execution disabled
swift test --parallel
```

### Linting & Formatting
```bash
# Run linting (uses Mint for dependency management)
./Scripts/lint.sh

# Lint in strict mode
LINT_MODE=STRICT ./Scripts/lint.sh

# Format only (skip linting)
FORMAT_ONLY=1 ./Scripts/lint.sh
```

The project uses:
- **SwiftLint** (0.58.2 via Mint) with custom rules in `.swiftlint.yml`
- **swift-format** (600.0.0 via Mint) with configuration in `.swift-format`
- 2-space indentation
- 100-character line length (swift-format), 108-character (SwiftLint warning)

### Documentation
```bash
# Generate documentation (requires swift-docc-plugin)
swift package generate-documentation

# Preview documentation
swift package --disable-sandbox preview-documentation
```

## Architecture

### Core Protocols

**Database** (`Sources/DataThespian/Databases/Database.swift:36`)
- Main protocol for database operations
- Extends `Queryable` and requires `Sendable` conformance
- Provides `withModelContext` for safe ModelContext access

**Queryable** (`Sources/DataThespian/Databases/Queryable.swift:33`)
- Defines CRUD operations: `save()`, `insert()`, `fetch()`, `get()`, `getOptional()`, `delete()`
- All operations use async/await and work with `Selector` types
- Methods accept closures for transforming results while maintaining thread safety

### Key Types

**ModelActorDatabase** (`Sources/DataThespian/Databases/ModelActorDatabase.swift:34`)
- Built-in `@ModelActor` implementation of `Database`
- Provides default database implementation using SwiftData's ModelExecutor
- Can be customized via constructor with custom ModelContext or ModelExecutor

**Selector** (`Sources/DataThespian/Databases/Selector.swift:34`)
- Type-safe query builder with three nested enums:
  - `Selector.Get` - Retrieve single items (by predicate or Model)
  - `Selector.List` - Fetch multiple items (via FetchDescriptor)
  - `Selector.Delete` - Delete items (by predicate, Model, or all)
- Provides convenience methods like `.all()`, `.descriptor(predicate:sortBy:fetchLimit:)`

**Model<T>** (`Sources/DataThespian/Model.swift:34`)
- Sendable phantom type wrapping PersistentIdentifier
- Used to pass model references across actor boundaries
- Thrown errors include `Model.NotFoundError` when identifier lookup fails

### Data Monitoring

**DataMonitor** (`Sources/DataThespian/Notification/DataMonitor.swift:37`)
- Actor-based system for observing database changes
- Monitors `NSManagedObjectContextDidSaveObjectIDs` notifications
- Supports agent registration for reactive updates via `AgentRegister` protocol

### SwiftUI Integration

The library provides SwiftUI environment integration:
- Use `.database(_:)` modifier on Scene to inject Database
- Access via `@Environment(\.database)` in views
- Typically use a SharedDatabase singleton pattern to ensure single ModelContext

## Swift 6 Features

The package uses experimental and upcoming Swift features (see `Package.swift:7-18`):
- AccessLevelOnImport
- BitwiseCopyable
- IsolatedAny
- MoveOnlyPartialConsumption
- NestedProtocols
- NoncopyableGenerics
- TransferringArgsAndResults
- VariadicGenerics
- FullTypedThrows
- InternalImportsByDefault

All code must maintain strict concurrency checking and Swift 6 compatibility.

## Platform Requirements

- **Apple Platforms**: iOS 17+, macOS 14+, tvOS 17+, watchOS 10+, visionOS 1+
- **Linux**: Ubuntu 20.04+ with Swift 6.0+
- **Swift**: 6.0 minimum
- **Xcode**: 16.0 minimum

## Code Style Guidelines

From `.swiftlint.yml` and `.swift-format`:
- Use explicit access control (`explicit_acl`, `explicit_top_level_acl`)
- File length limit: 225 lines (warning), 300 lines (error)
- Function body length: 50 lines (warning), 76 lines (error)
- Cyclomatic complexity: 6 (warning), 12 (error)
- Force unwrapping is opt-in (enabled in SwiftLint rules)
- Implicit returns are allowed
- File names must match type names (error severity)
- All public declarations require documentation (swift-format rule)
- Use `fileprivate` for file-scoped declarations

## Testing Patterns

Test models are in `Tests/DataThespianTests/Support/`:
- `Parent.swift` / `Child.swift` - Related entities for relationship testing
- `TestingDatabase.swift` - Test database utilities
- `SwiftDataIsAvailable.swift` - Platform capability checks

Tests use in-memory ModelContainer configurations for isolation.

## CI/CD

GitHub Actions workflow (`.github/workflows/DataThespian.yml`):
- Builds on Ubuntu (noble, jammy) with Swift 6.0, 6.1, 6.2
- Builds on macOS with multiple Xcode versions (16.1, 16.3, 26.0)
- Runs on iOS, watchOS, and visionOS simulators
- Coverage uploaded to Codecov
- Linting runs after successful builds
- Skip CI with `[ci skip]` in commit message
