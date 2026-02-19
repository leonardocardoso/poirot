# Accessibility & Performance

Best practices for accessible symbol usage and animation performance.

## Table of Contents
- [Reduce Motion](#reduce-motion)
- [Accessibility Labels](#accessibility-labels)
- [Symbol Sizing](#symbol-sizing)
- [Performance Guidelines](#performance-guidelines)
- [Common Anti-Patterns](#common-anti-patterns)

---

## Reduce Motion

Always respect the user's accessibility preference for reduced motion.

### Reading the Environment Value

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
```

### Gating Indefinite Effects

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

Image(systemName: "wifi")
    .symbolEffect(.variableColor.iterative, isActive: isSearching && !reduceMotion)
```

### Fallback for Discrete Effects

For discrete effects, consider reducing repetitions instead of disabling entirely:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

Image(systemName: "star.fill")
    .symbolEffect(
        .bounce,
        options: reduceMotion ? .nonRepeating : .speed(2).repeat(2),
        value: tapCount
    )
```

### Content Transitions

Content transitions (`.replace`) are generally safe even with reduce motion — they're brief and functional. No need to gate them.

---

## Accessibility Labels

### Icon-Only Symbols

When a symbol is used without accompanying text, always provide a label:

```swift
// BAD — no label for screen readers
Button {
    refresh()
} label: {
    Image(systemName: "arrow.clockwise")
}

// GOOD — accessible
Button {
    refresh()
} label: {
    Image(systemName: "arrow.clockwise")
        .accessibilityLabel("Refresh")
}
```

### Symbols with Text

When a symbol is paired with text, the text provides the label. No extra label needed:

```swift
// The "Sessions" text provides the accessible name
Label("Sessions", systemImage: "rectangle.stack")
```

### Decorative Symbols

For purely decorative symbols that add no information:

```swift
Image(systemName: "sparkle")
    .accessibilityHidden(true)
```

---

## Symbol Sizing

### Preferred: Font-Based Sizing

```swift
// GOOD — renders from vector data at correct resolution
Image(systemName: "star.fill")
    .font(.system(size: 24))

// GOOD — relative sizing
Image(systemName: "star.fill")
    .imageScale(.large)

// GOOD — matches text size in labels
Label("Favorites", systemImage: "star.fill")
    .font(.headline)
```

### Avoid: Frame-Based Sizing

```swift
// BAD — renders at default size then scales the image
Image(systemName: "star.fill")
    .resizable()
    .frame(width: 24, height: 24)
```

**Why:** `.font()` generates the symbol at the exact size from vector data, ensuring crisp rendering. `.resizable().frame()` renders at a default size and then scales the bitmap, which can appear blurry.

### Exception: Aspect Ratio Constraints

If you need to match a specific aspect ratio container, `.resizable()` is acceptable:

```swift
Image(systemName: "star.fill")
    .resizable()
    .scaledToFit()
    .frame(width: 32, height: 32)
```

---

## Performance Guidelines

### Avoid Indefinite Effects in Lists

Each animated symbol incurs per-frame rendering overhead:

```swift
// BAD — every row animates continuously
List(servers) { server in
    HStack {
        Image(systemName: "circle.fill")
            .symbolEffect(.breathe, isActive: true)  // Expensive in a list!
        Text(server.name)
    }
}

// GOOD — only the visible selected item animates
List(servers) { server in
    HStack {
        Image(systemName: "circle.fill")
            .symbolEffect(.breathe, isActive: server.id == selectedID)
        Text(server.name)
    }
}
```

### Don't Stack Multiple Effects

```swift
// BAD — multiple effects compound rendering cost
Image(systemName: "star.fill")
    .symbolEffect(.bounce, value: count)
    .symbolEffect(.pulse, isActive: isActive)
    .symbolEffect(.scale.up, isActive: isSelected)

// GOOD — choose the most meaningful single effect
Image(systemName: "star.fill")
    .symbolEffect(.bounce, value: count)
```

### Prefer Discrete Over Indefinite

When a one-shot is sufficient, don't use indefinite:

```swift
// Unnecessary — pulse runs forever
Image(systemName: "bell")
    .symbolEffect(.pulse, isActive: true)

// Better — bounce once on notification
Image(systemName: "bell")
    .symbolEffect(.bounce, value: notificationCount)
```

### Rendering Mode Cost

From cheapest to most expensive:
1. Monochrome
2. Hierarchical
3. Palette
4. Multicolor

For symbols in list rows, prefer monochrome or hierarchical.

---

## Common Anti-Patterns

### Animating Static Icons

```swift
// BAD — toolbar icon doesn't change state, no animation needed
Image(systemName: "gear")
    .symbolEffect(.rotate, isActive: true)  // Always spinning gear?

// GOOD — only animate when processing
Image(systemName: "gear")
    .symbolEffect(.rotate, isActive: isProcessing)
```

### Forgetting Reduce Motion

```swift
// BAD — ignores accessibility preference
Image(systemName: "wifi")
    .symbolEffect(.variableColor.iterative, isActive: isSearching)

// GOOD — respects user preference
@Environment(\.accessibilityReduceMotion) private var reduceMotion

Image(systemName: "wifi")
    .symbolEffect(.variableColor.iterative, isActive: isSearching && !reduceMotion)
```

### Wrong Trigger Type

```swift
// BAD — using isActive for a one-shot tap
Image(systemName: "heart")
    .symbolEffect(.bounce, isActive: didTap)  // Bounces forever when true!

// GOOD — use value: for one-shot
Image(systemName: "heart")
    .symbolEffect(.bounce, value: tapCount)
```

### Resizable for Sizing

```swift
// BAD
Image(systemName: "star.fill")
    .resizable()
    .frame(width: 16, height: 16)

// GOOD
Image(systemName: "star.fill")
    .font(.system(size: 16))
```
