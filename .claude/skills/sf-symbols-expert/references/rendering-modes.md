# SF Symbols Rendering Modes

How to control the coloring of multi-layer SF Symbols.

## Table of Contents
- [Overview](#overview)
- [Monochrome](#monochrome)
- [Hierarchical](#hierarchical)
- [Palette](#palette)
- [Multicolor](#multicolor)
- [Setting Rendering Mode](#setting-rendering-mode)
- [Context Recommendations](#context-recommendations)

---

## Overview

SF Symbols can have up to three visual layers. Rendering modes control how these layers are colored. Available on iOS 15+ / macOS 12+.

**Key rule:** Not all symbols support every mode. Symbols with fewer layers may look identical across modes.

---

## Monochrome

All layers rendered in a single uniform color. This is the **default** behavior.

```swift
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.monochrome)
    .foregroundStyle(.blue)
```

**When to use:** Toolbars, tab bars, minimal UI. Clean and simple.

---

## Hierarchical

Layers rendered with varying opacities of a single color, providing depth.

```swift
// Single color, automatic opacity per layer
Image(systemName: "heart.circle.fill")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.red)

// Works great for sidebar icons
Image(systemName: "rectangle.stack")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.primary)
```

**When to use:** Sidebar icons, status indicators, decorative elements. Adds visual depth without requiring multiple colors. **Recommended for LUMNO's sidebar and toolbar icons.**

---

## Palette

Each layer gets its own independent color. Supports up to three foreground styles.

```swift
// Two layers
Image(systemName: "heart.circle.fill")
    .symbolRenderingMode(.palette)
    .foregroundStyle(.red, .yellow)

// Three layers
Image(systemName: "cloud.sun.rain.fill")
    .symbolRenderingMode(.palette)
    .foregroundStyle(.gray, .yellow, .blue)
```

**Shortcut:** Passing multiple styles to `.foregroundStyle()` automatically implies palette mode — no need to explicitly set `.symbolRenderingMode(.palette)`.

```swift
// These are equivalent:
Image(systemName: "heart.circle.fill")
    .foregroundStyle(.red, .yellow)

Image(systemName: "heart.circle.fill")
    .symbolRenderingMode(.palette)
    .foregroundStyle(.red, .yellow)
```

**When to use:** Brand-specific coloring, custom themes, high contrast between symbol parts.

---

## Multicolor

Renders with Apple's predefined, built-in colors. `.foregroundStyle()` has no effect.

```swift
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.multicolor)
    .font(.system(size: 32))
```

**When to use:** Weather symbols, file type icons. Polished results with zero configuration.

---

## Setting Rendering Mode

### Per-Symbol

```swift
Image(systemName: "heart.circle.fill")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.red)
```

### Container-Wide (via Environment)

```swift
VStack {
    Image(systemName: "heart.circle.fill")
    Image(systemName: "star.circle.fill")
    Image(systemName: "bell.circle.fill")
}
.symbolRenderingMode(.hierarchical)
.foregroundStyle(.accentColor)
```

---

## Context Recommendations

| Context | Mode | Rationale |
|---------|------|-----------|
| Sidebar navigation | Hierarchical | Depth with single tint color |
| Toolbar actions | Monochrome | Clean, minimal |
| Tab bar | Monochrome | Standard platform convention |
| Status indicators | Hierarchical | Visual emphasis on primary layer |
| Config cards (LUMNO) | Palette | Match card icon tint colors |
| Weather / system icons | Multicolor | Apple's curated colors |
| Active/selected state | Monochrome + accent | Clear selection feedback |

### LUMNO-Specific Patterns

```swift
// Sidebar nav items — hierarchical with accent
Image(systemName: "rectangle.stack")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(isActive ? Color.accentColor : .secondary)

// Config card icons — palette matching card tint
Image(systemName: "bolt.circle.fill")
    .foregroundStyle(.accent, .accent.opacity(0.15))

// Status bar indicators — monochrome, small
Image(systemName: "circle.fill")
    .font(.system(size: 6))
    .foregroundStyle(isConnected ? .green : .tertiary)
```
