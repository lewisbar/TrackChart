# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

TrackChart is an iOS app that lets users track numerical data over time and displays it in charts. The app supports iCloud sync and is localized for English and German.

## Development Commands

### Building & Testing

```bash
# Build and test all modules (CI configuration)
xcodebuild test \
  -project TrackChart.xcodeproj \
  -scheme CI_macOS \
  -testPlan CI_macOS \
  -destination 'platform=macOS,arch=arm64' \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES

# Test a specific module
xcodebuild test \
  -project TrackChart.xcodeproj \
  -scheme DataProcessing \
  -testPlan DataProcessing \
  -destination 'platform=macOS,arch=arm64'

# Build the iOS app (for testing in simulator)
xcodebuild build \
  -project TrackChart.xcodeproj \
  -scheme TrackChartiOS \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Available Schemes and Test Plans

**Schemes:** TrackChartiOS, Persistence, DataProcessing, Presentation, CI_macOS

**Test Plans:** CI_macOS.xctestplan (runs all tests), Persistence.xctestplan, DataProcessing.xctestplan, Presentation.xctestplan

## Architecture

### Three-Layer Architecture

The codebase is organized into three distinct layers, each as a separate module:

**1. Persistence Layer** (SwiftData)
- `TopicEntity`: Main data model representing a tracking topic (e.g., "Weight", "Push-ups")
- `EntryEntity`: Individual data entries with values and timestamps
- Uses SwiftData for persistence with automatic iCloud sync support
- Entities contain business logic for data manipulation (submit, update, delete entries)

**2. DataProcessing Layer** (Pure Logic)
- `ChartDataProvider`: Aggregates raw entries into processed data for visualization
- Provides multiple aggregation strategies: daily/weekly/monthly/yearly, sum/average
- `TimeSpan`: Represents chart time spans (week, month, year)
- `Aggregator`: Defines aggregation methods (sum, average)
- Zero-filling support for missing data periods
- All types are `Sendable` for safe concurrent usage

**3. Presentation Layer** (UI Models)
- `ViewTopic`, `ViewEntry`: UI-friendly immutable value types
- `SettingsTopic`: Settings screen model
- `Palette`: Color palettes for topics
- `ViewAggregator`, `ViewTimeSpan`: Presentation-layer enums
- View models for SwiftUI views (e.g., `SwiftDataTopicListViewModel`, `DecimalInputViewModel`)

### Adapter Pattern

The layers are connected through mappers in `Presentation/Adapter/`:

- `TopicEntityMapping.swift`: Converts between `TopicEntity` (persistence) and `ViewTopic`/`SettingsTopic` (presentation)
- `AggregatorMapping.swift`: Maps between `Aggregator` (data processing) and `ViewAggregator` (presentation)
- `ViewTimeSpanAdapter.swift`: Converts between time span representations
- `ChartPageMapping.swift`: Maps chart page data

This design keeps persistence entities, business logic, and UI concerns separate while allowing clean data flow between layers.

### App Composition

The iOS app (`TrackChartiOS/`) uses:
- SwiftUI with NavigationStack for navigation
- SwiftData `ModelContainer` for data management
- "SwiftData Wrapper Views" that bridge between SwiftData's `@Query` and pure SwiftUI views
- Dependency injection pattern for view models (functions passed as closures)

## Testing Approach

Tests use Swift Testing framework (not XCTest). Test files follow the pattern:
- `DataProcessingTests/`: Unit tests for aggregation logic
- `PersistenceTests/`: Tests for SwiftData entities
- `PresentationTests/`: Tests for view models and mappings

Tests use `@Test` macro and `#expect` for assertions. Helper functions like `defaultCalendar()` provide consistent test environments.

## Key Design Patterns

- **Value types for presentation**: UI models are immutable structs for predictable behavior
- **Sendable conformance**: Data processing types support concurrent access
- **Explicit mapping**: Clear boundaries between layers via adapter extensions
- **Functional processing**: `ChartDataProvider` uses closures for processing strategies
- **Dependency injection**: View models receive functions as parameters rather than direct dependencies
