# Discrete Symbol Effects (Value-Triggered)

One-shot animations that fire each time a value changes. Use for confirming user actions.

## Table of Contents
- [Overview](#overview)
- [Bounce](#bounce)
- [Pulse (Discrete)](#pulse-discrete)
- [Variable Color (Discrete)](#variable-color-discrete)
- [Wiggle (Discrete)](#wiggle-discrete)
- [Common Patterns](#common-patterns)

---

## Overview

Discrete effects play once per value change. They use the `value:` parameter:

```swift
func symbolEffect<T: DiscreteSymbolEffect>(
    _ effect: T,
    options: SymbolEffectOptions = .default,
    value: some Equatable
) -> some View
```

**Trigger mechanism:** The animation fires every time the `value` changes. Use a counter (`Int`) or toggle (`Bool`) as the value.

---

## Bounce

A one-shot vertical spring animation. The most common discrete effect.

**Availability:** macOS 14+ (Sonoma) / iOS 17+

```swift
// Basic bounce on tap
@State private var tapCount = 0

Image(systemName: "arrow.down.circle")
    .symbolEffect(.bounce, value: tapCount)
    .onTapGesture { tapCount += 1 }
```

### Direction

```swift
// Bounce up (default for most symbols)
Image(systemName: "star.fill")
    .symbolEffect(.bounce.up, value: count)

// Bounce down
Image(systemName: "arrow.down.circle")
    .symbolEffect(.bounce.down, value: count)
```

### Layer Animation

```swift
// Animate layers individually (staggered)
Image(systemName: "star.fill")
    .symbolEffect(.bounce.byLayer, value: count)

// Animate entire symbol as one unit
Image(systemName: "star.fill")
    .symbolEffect(.bounce.wholeSymbol, value: count)
```

### With Options

```swift
// Fast bounce, 3 times
Image(systemName: "star.fill")
    .symbolEffect(.bounce, options: .speed(3).repeat(3), value: count)
```

### When to Use
- User taps a button (favorite, download, bookmark)
- Action completes successfully (checkmark bounce)
- Item added/removed from a list

---

## Pulse (Discrete)

Varies layer opacity in a one-shot pattern.

**Availability:** macOS 14+ / iOS 17+

```swift
// Pulse 3 times on value change
Image(systemName: "bell.fill")
    .symbolEffect(.pulse, options: .repeat(3), value: notificationCount)
```

### When to Use
- New notification arrives (pulse the bell)
- Warning state triggered

---

## Variable Color (Discrete)

Progressively highlights layers in a one-shot sequence.

**Availability:** macOS 14+ / iOS 17+

```swift
// Iterative: one layer at a time
Image(systemName: "wifi")
    .symbolEffect(.variableColor.iterative, options: .repeat(3), value: scanTrigger)

// Cumulative: each layer adds to previous
Image(systemName: "wifi")
    .symbolEffect(.variableColor.cumulative, options: .repeat(2), value: scanTrigger)

// Reversing: forward then backward
Image(systemName: "wifi")
    .symbolEffect(.variableColor.reversing.iterative, value: scanTrigger)
```

### When to Use
- One-shot scan/search animation
- Signal strength check

---

## Wiggle (Discrete)

Short oscillating movement. Draws attention.

**Availability:** macOS 15+ (Sequoia) / iOS 18+

```swift
// Basic wiggle
Image(systemName: "bell.circle")
    .symbolEffect(.wiggle, value: notificationCount)

// Directional
Image(systemName: "arrow.left")
    .symbolEffect(.wiggle.left, value: trigger)

Image(systemName: "arrow.right")
    .symbolEffect(.wiggle.right, value: trigger)

// Rotational
Image(systemName: "bell")
    .symbolEffect(.wiggle.clockwise, value: trigger)

// Custom angle
Image(systemName: "translate")
    .symbolEffect(.wiggle.custom(angle: 45), options: .repeat(2), value: count)
```

### Direction Options
`.left`, `.right`, `.up`, `.down`, `.forward`, `.backward`, `.clockwise`, `.counterClockwise`, `.custom(angle:)`

### When to Use
- New notification or badge appears
- Call-to-action needs attention
- Reinforcing what the symbol represents (bell wiggling)

---

## Common Patterns

### Favorite Button

```swift
@State private var isFavorite = false
@State private var bounceValue = 0

Image(systemName: isFavorite ? "heart.fill" : "heart")
    .foregroundStyle(isFavorite ? .red : .secondary)
    .symbolEffect(.bounce, value: bounceValue)
    .contentTransition(.symbolEffect(.replace))
    .onTapGesture {
        isFavorite.toggle()
        bounceValue += 1
    }
```

### Download Complete

```swift
@State private var downloadComplete = 0

Image(systemName: "checkmark.circle.fill")
    .foregroundStyle(.green)
    .symbolEffect(.bounce.up, options: .speed(2), value: downloadComplete)
```

### Notification Badge

```swift
@State private var notificationCount = 0

Image(systemName: "bell.fill")
    .symbolEffect(.wiggle, value: notificationCount)  // macOS 15+
    .symbolEffect(.bounce, value: notificationCount)   // fallback macOS 14
```

### Accessibility-Aware Pattern

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

Image(systemName: "star.fill")
    .symbolEffect(
        .bounce,
        options: reduceMotion ? .nonRepeating : .speed(2).repeat(2),
        value: tapCount
    )
```
