# Variable Values & Symbol Variants

Progress-like symbol rendering and visual variant modifiers.

## Table of Contents
- [Variable Value](#variable-value)
- [Symbol Variants](#symbol-variants)
- [Common Patterns](#common-patterns)

---

## Variable Value

Certain SF Symbols adapt their appearance based on a `Double` between 0.0 and 1.0.

**Availability:** macOS 13+ (Ventura) / iOS 16+

```swift
Image(systemName: "speaker.wave.3", variableValue: 0.0)   // No waves
Image(systemName: "speaker.wave.3", variableValue: 0.33)  // One wave
Image(systemName: "speaker.wave.3", variableValue: 0.66)  // Two waves
Image(systemName: "speaker.wave.3", variableValue: 1.0)   // All waves
```

### Dynamic Usage

```swift
@State private var volume: Double = 0.5

VStack {
    Image(systemName: "speaker.wave.3", variableValue: volume)
        .font(.system(size: 32))
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(.blue)

    Slider(value: $volume, in: 0...1)
}
```

### Common Variable-Value Symbols
- `speaker.wave.3` — Volume levels
- `wifi` — Signal strength
- `chart.bar.fill` — Progress/levels
- `cellularbars` — Cellular signal

### Variable Value vs Variable Color Effect
- **Variable value** (`variableValue:`) — Static representation at a given level
- **Variable color** (`.symbolEffect(.variableColor)`) — Animated cycling through layers

They serve different purposes. Use variable value for displaying a fixed level; use variable color for animated activity.

---

## Symbol Variants

The `.symbolVariant()` modifier applies visual variants without changing the symbol name.

**Availability:** macOS 12+ / iOS 15+

### Available Variants

```swift
Image(systemName: "person")
    .symbolVariant(.fill)       // person.fill

Image(systemName: "heart")
    .symbolVariant(.circle)     // heart.circle

Image(systemName: "mic")
    .symbolVariant(.slash)      // mic.slash

Image(systemName: "star")
    .symbolVariant(.square)     // star.square

Image(systemName: "plus")
    .symbolVariant(.rectangle)  // plus.rectangle
```

### Chained Variants

```swift
Image(systemName: "person")
    .symbolVariant(.circle.fill)  // person.circle.fill
```

### Container-Level Application

Applies to all child symbols:

```swift
VStack {
    Image(systemName: "person")
    Image(systemName: "heart")
    Image(systemName: "star")
}
.symbolVariant(.fill)  // All become .fill versions
```

### All Variants
- `.fill` — Solid fill version
- `.circle` — Circular enclosure
- `.square` — Square enclosure
- `.rectangle` — Rectangle enclosure
- `.slash` — Diagonal slash (indicates disabled/unavailable)
- `.none` — Explicit no variant (reset)

---

## Common Patterns

### Selected/Unselected State

```swift
// Fill for selected, outline for unselected
Image(systemName: "heart")
    .symbolVariant(isFavorite ? .fill : .none)
    .foregroundStyle(isFavorite ? .red : .secondary)
```

### Disabled Feature

```swift
Image(systemName: "mic")
    .symbolVariant(isMuted ? .slash : .none)
    .foregroundStyle(isMuted ? .red : .primary)
```

### Tab Bar Convention

```swift
// iOS convention: outline for tabs, fill for selected
TabView {
    SessionsView()
        .tabItem {
            Image(systemName: "rectangle.stack")
            Text("Sessions")
        }
}
// System automatically applies .fill for selected tab
```

### LUMNO Sidebar Navigation

```swift
// Active nav item gets fill variant
Image(systemName: "rectangle.stack")
    .symbolVariant(isActive ? .fill : .none)
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(isActive ? .accent : .secondary)
```
