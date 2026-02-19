# Indefinite Symbol Effects (isActive-Triggered)

Continuous animations that run while a boolean condition is true. Use for ongoing states.

## Table of Contents
- [Overview](#overview)
- [Pulse (Indefinite)](#pulse-indefinite)
- [Variable Color (Indefinite)](#variable-color-indefinite)
- [Scale](#scale)
- [Breathe](#breathe)
- [Rotate](#rotate)
- [Wiggle (Indefinite)](#wiggle-indefinite)
- [Common Patterns](#common-patterns)

---

## Overview

Indefinite effects run continuously while `isActive` is `true` and stop when `false`:

```swift
func symbolEffect<T: IndefiniteSymbolEffect>(
    _ effect: T,
    options: SymbolEffectOptions = .default,
    isActive: Bool = true
) -> some View
```

**Default:** `isActive` defaults to `true` — omitting it starts the animation immediately.

---

## Pulse (Indefinite)

Continuous opacity modulation across layers.

**Availability:** macOS 14+ / iOS 17+

```swift
// Continuous pulse while recording
Image(systemName: "record.circle")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.red)
    .symbolEffect(.pulse, isActive: isRecording)
```

### When to Use
- Recording/listening state
- Subtle activity indicator
- Waiting for input

---

## Variable Color (Indefinite)

Continuously cycles through layers. Multiple iteration modes.

**Availability:** macOS 14+ / iOS 17+

```swift
// Iterative: one layer at a time, repeating
Image(systemName: "wifi")
    .symbolEffect(.variableColor.iterative, isActive: isSearching)

// Cumulative: layers build up, repeating
Image(systemName: "wifi")
    .symbolEffect(.variableColor.cumulative, isActive: isSearching)

// Reversing iterative: forward then backward
Image(systemName: "wifi")
    .symbolEffect(.variableColor.reversing.iterative, isActive: isSearching)

// Reversing cumulative
Image(systemName: "wifi")
    .symbolEffect(.variableColor.reversing.cumulative, isActive: isSearching)
```

### When to Use
- Wi-Fi/signal scanning
- Searching/indexing
- Progressive loading states

---

## Scale

Scales the symbol up or down while active.

**Availability:** macOS 14+ / iOS 17+

```swift
// Scale up when selected
Image(systemName: "star.fill")
    .symbolEffect(.scale.up, isActive: isSelected)

// Scale down when muted
Image(systemName: "mic.fill")
    .symbolEffect(.scale.down, isActive: isMuted)
```

### When to Use
- Selection emphasis
- Active/inactive toggle (subtle)
- Muted/disabled state

---

## Breathe

Smooth scale + opacity modulation. More prominent than pulse.

**Availability:** macOS 15+ (Sequoia) / iOS 18+

```swift
// Default breathe (scale + opacity)
Image(systemName: "heart.fill")
    .symbolEffect(.breathe, isActive: isAlive)

// Plain breathe (scale only, no opacity change)
Image(systemName: "circle.fill")
    .symbolEffect(.breathe.plain, isActive: isActive)
```

### Variants
- `.breathe` — scale and opacity modulation (default)
- `.breathe.plain` — scale only, no opacity

### When to Use
- "Alive" or "active" indicators
- Ambient status (connected, synced)
- More visible than pulse, less distracting than wiggle

---

## Rotate

Continuous rotation of the symbol or specific layers.

**Availability:** macOS 15+ (Sequoia) / iOS 18+

```swift
// Clockwise rotation (default)
Image(systemName: "gear")
    .symbolEffect(.rotate, isActive: isProcessing)

// Counter-clockwise
Image(systemName: "arrow.trianglehead.2.counterclockwise")
    .symbolEffect(.rotate.counterClockwise, isActive: isSyncing)

// By layer (only specific layers spin)
Image(systemName: "fan.desk")
    .symbolEffect(.rotate.byLayer, isActive: isFanOn)
```

### Direction Options
- `.clockwise` (default)
- `.counterClockwise`

### Layer Options
- `.byLayer` — only animatable layers rotate (e.g., fan blades)
- `.wholeSymbol` — entire symbol rotates

### When to Use
- Processing/syncing indicators
- Loading states (gear spinning)
- Refresh actions

---

## Wiggle (Indefinite)

Continuous oscillating movement with periodic delay.

**Availability:** macOS 15+ (Sequoia) / iOS 18+

```swift
// Continuous wiggle with periodic pause
Image(systemName: "bell.circle")
    .symbolEffect(.wiggle, options: .repeat(.periodic(delay: 2)), isActive: hasNotifications)
```

### When to Use
- Persistent attention indicator
- Ongoing alert state

---

## Common Patterns

### Claude Code Status Indicator (LUMNO)

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

HStack(spacing: 5) {
    Circle()
        .fill(isActive ? Color.green : Color(.tertiaryLabelColor))
        .frame(width: 6, height: 6)

    Text(isActive ? "Claude Code active" : "Idle")
        .font(.system(size: 11))
        .foregroundStyle(.tertiary)
}
```

### Loading / Processing

```swift
Image(systemName: "gear")
    .symbolRenderingMode(.hierarchical)
    .symbolEffect(.rotate, isActive: isProcessing)
    .foregroundStyle(.secondary)
```

### MCP Server Connected

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

Image(systemName: "bolt.circle.fill")
    .symbolRenderingMode(.hierarchical)
    .symbolEffect(.breathe, isActive: isConnected && !reduceMotion)
    .foregroundStyle(isConnected ? .green : .secondary)
```

### Search/Scan in Progress

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

Image(systemName: "magnifyingglass")
    .symbolEffect(
        .variableColor.iterative.reversing,
        isActive: isSearching && !reduceMotion
    )
```

### Accessibility Gate Pattern

Always use this pattern for indefinite effects:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

Image(systemName: "wifi")
    .symbolEffect(.variableColor.iterative, isActive: isSearching && !reduceMotion)
```
