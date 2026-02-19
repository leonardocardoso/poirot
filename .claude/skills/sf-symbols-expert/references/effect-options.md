# SymbolEffectOptions

Control repeat behavior, speed, and timing of symbol effects.

## Table of Contents
- [Overview](#overview)
- [Default](#default)
- [Non-Repeating](#non-repeating)
- [Fixed Repeat Count](#fixed-repeat-count)
- [Continuous](#continuous)
- [Periodic](#periodic)
- [Speed](#speed)
- [Chaining Options](#chaining-options)

---

## Overview

`SymbolEffectOptions` is passed via the `options:` parameter on any `symbolEffect` modifier:

```swift
.symbolEffect(.bounce, options: .speed(2).repeat(3), value: count)
```

---

## Default

Plays once for discrete effects. Plays continuously for indefinite effects.

```swift
.symbolEffect(.bounce, options: .default, value: count)
```

---

## Non-Repeating

Ensures the effect plays exactly once, even for effects that might otherwise loop.

```swift
.symbolEffect(.bounce, options: .nonRepeating, value: count)
```

---

## Fixed Repeat Count

```swift
// Repeat 3 times
.symbolEffect(.bounce, options: .repeat(3), value: count)

// Repeat 5 times
.symbolEffect(.pulse, options: .repeat(5), value: trigger)
```

---

## Continuous

Infinite looping. Mainly for indefinite effects.

```swift
.symbolEffect(.wiggle, options: .repeat(.continuous), isActive: isActive)
```

---

## Periodic

Repeats with a delay between iterations. Great for attention-drawing effects that shouldn't be constant.

```swift
// Continuous with 2-second pauses
.symbolEffect(.wiggle, options: .repeat(.periodic(delay: 2)), isActive: isActive)

// Fixed count with delays
.symbolEffect(.wiggle, options: .repeat(.periodic(3, delay: 1.5)), isActive: isActive)
```

---

## Speed

Multiplier for animation speed. Default is 1.0.

```swift
// 2x speed
.symbolEffect(.bounce, options: .speed(2), value: count)

// Slow (0.5x)
.symbolEffect(.breathe, options: .speed(0.5), isActive: isAlive)

// 3x speed
.symbolEffect(.variableColor.iterative, options: .speed(3), isActive: isSearching)
```

---

## Chaining Options

Options are chainable:

```swift
// Fast bounce, 3 times
.symbolEffect(.bounce, options: .speed(3).repeat(3), value: count)

// Slow continuous wiggle
.symbolEffect(.wiggle, options: .speed(0.5).repeat(.continuous), isActive: isActive)

// Fast periodic
.symbolEffect(.wiggle, options: .speed(2).repeat(.periodic(delay: 1)), isActive: isActive)
```

---

## Practical Guidelines

| Scenario | Recommended Options |
|----------|-------------------|
| Tap feedback | `.default` or `.speed(2)` |
| Notification arrival | `.speed(2).repeat(2)` |
| Ongoing loading | (omit — default indefinite) |
| Periodic attention | `.repeat(.periodic(delay: 2))` |
| Confirmation | `.speed(2).repeat(1)` |
| Accessibility: reduce motion | `.nonRepeating` |
