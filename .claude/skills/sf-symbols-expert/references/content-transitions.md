# Content Transitions & View Transitions

Animated symbol swaps and view lifecycle animations.

## Table of Contents
- [Content Transition (Symbol Swap)](#content-transition-symbol-swap)
- [Magic Replace](#magic-replace)
- [Replace Directions](#replace-directions)
- [View Transitions (Appear / Disappear)](#view-transitions)
- [Common Patterns](#common-patterns)

---

## Content Transition (Symbol Swap)

Use `.contentTransition(.symbolEffect(.replace))` to animate between different symbol names on the same `Image` view.

**Availability:** macOS 14+ / iOS 17+

```swift
@State private var isMuted = false

Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
    .contentTransition(.symbolEffect(.replace))
    .onTapGesture { isMuted.toggle() }
```

**How it works:** SwiftUI detects the `systemName` change and animates the transition between old and new symbols.

---

## Magic Replace

On macOS 15+ / iOS 18+, **Magic Replace** is the default behavior for related symbols. It animates the shared geometry while smoothly transitioning differences (slashes, badges, wave indicators).

```swift
// Magic Replace is automatic for related symbols on macOS 15+
Image(systemName: isEnabled ? "bell" : "bell.slash")
    .contentTransition(.symbolEffect(.replace))

// Explicit magic replace with fallback for unrelated symbols
Image(systemName: isEnabled ? "bell" : "bell.slash")
    .contentTransition(.symbolEffect(.replace.magic(fallback: .replace)))
```

### Related Symbol Pairs (Magic Replace works best)
- `bell` ↔ `bell.slash`
- `mic` ↔ `mic.slash`
- `speaker.wave.2.fill` ↔ `speaker.slash.fill`
- `play.fill` ↔ `pause.fill`
- `lock` ↔ `lock.open`
- `eye` ↔ `eye.slash`
- `wifi` ↔ `wifi.slash`

For unrelated symbols, standard replace crossfade is used.

---

## Replace Directions

Control the direction of the replace animation:

```swift
// Up-up: both old and new move up
.contentTransition(.symbolEffect(.replace.upUp))

// Off-up: old fades out, new comes up
.contentTransition(.symbolEffect(.replace.offUp))

// Down-up: old goes down, new comes up
.contentTransition(.symbolEffect(.replace.downUp))
```

### With Options

```swift
.contentTransition(.symbolEffect(.replace, options: .speed(2)))
```

---

## View Transitions

For symbols entering or exiting the view hierarchy.

### Appear

**Availability:** macOS 14+ / iOS 17+

```swift
if showCheck {
    Image(systemName: "checkmark.circle.fill")
        .foregroundStyle(.green)
        .transition(.symbolEffect(.appear))
}
```

### Disappear

```swift
if isVisible {
    Image(systemName: "xmark.circle")
        .transition(.symbolEffect(.disappear))
}
```

### Layer Options

```swift
// Staggered per-layer animation
.transition(.symbolEffect(.appear.byLayer))

// All at once
.transition(.symbolEffect(.appear.wholeSymbol))
```

### Important
Transitions require an animation context. Either wrap the state change in `withAnimation` or use `.animation()`:

```swift
Button("Toggle") {
    withAnimation(.spring) {
        showCheck.toggle()
    }
}
```

---

## Common Patterns

### Play/Pause Toggle (LUMNO Session)

```swift
@State private var isPlaying = false

Button {
    isPlaying.toggle()
} label: {
    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
        .contentTransition(.symbolEffect(.replace))
}
```

### Notification Bell Toggle

```swift
@State private var notificationsEnabled = true

Image(systemName: notificationsEnabled ? "bell.fill" : "bell.slash.fill")
    .symbolRenderingMode(.hierarchical)
    .contentTransition(.symbolEffect(.replace))
    .onTapGesture {
        withAnimation { notificationsEnabled.toggle() }
    }
```

### Session Status Indicator

```swift
@State private var isConnected = false

HStack(spacing: 5) {
    if isConnected {
        Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(.green)
            .transition(.symbolEffect(.appear))
    } else {
        Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.red)
            .transition(.symbolEffect(.appear))
    }
    Text(isConnected ? "Connected" : "Disconnected")
}
.animation(.default, value: isConnected)
```

### Expand/Collapse Chevron

```swift
@State private var isExpanded = false

Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
    .contentTransition(.symbolEffect(.replace))
    .onTapGesture {
        withAnimation { isExpanded.toggle() }
    }
```
