---
name: sf-symbols-expert
description: Expert guidance for SF Symbols in SwiftUI — symbol selection, rendering modes, animations (symbolEffect), content transitions, variable values, accessibility, and performance. Use when adding icons, animating symbols, choosing rendering modes, or reviewing symbol usage in Apple-platform projects.
---

# SF Symbols Expert Skill

## Overview
Use this skill to select, render, animate, and optimize SF Symbols in SwiftUI. Covers rendering modes, all symbol effects (bounce, pulse, variableColor, scale, appear, disappear, replace, breathe, wiggle, rotate), content transitions, variable values, symbol variants, accessibility, and performance. Prioritizes native APIs and Apple HIG guidance.

## Workflow Decision Tree

### 1) Add a new icon to the UI
- Choose an appropriate SF Symbol name (see `references/symbol-selection.md`)
- Select the correct rendering mode (see `references/rendering-modes.md`)
- Add a meaningful animation if the symbol reflects state (see `references/effects-discrete.md`, `references/effects-indefinite.md`)
- Size with `.font()` or `.imageScale()`, not `.resizable().frame()`
- Verify accessibility (label, reduce motion, see `references/accessibility-performance.md`)

### 2) Animate a symbol for state feedback
- Determine trigger type: one-shot action vs ongoing state vs symbol swap vs view lifecycle
- One-shot action → discrete effect with `value:` (see `references/effects-discrete.md`)
- Ongoing state → indefinite effect with `isActive:` (see `references/effects-indefinite.md`)
- Symbol swap → `.contentTransition(.symbolEffect(.replace))` (see `references/content-transitions.md`)
- View enter/exit → `.transition(.symbolEffect(.appear/.disappear))` (see `references/content-transitions.md`)
- Add `options:` for speed/repeat control (see `references/effect-options.md`)

### 3) Review existing symbol usage
- Check rendering mode matches context (see `references/rendering-modes.md`)
- Verify animations use the correct trigger mechanism (value vs isActive)
- Ensure `.contentTransition(.symbolEffect(.replace))` for toggled symbols
- Check accessibility: reduce motion respected, labels provided
- Check performance: no indefinite effects in list rows, no stacked effects

### 4) Display progress or variable state
- Use `Image(systemName:variableValue:)` for level indicators (see `references/variable-values-variants.md`)
- Use `.symbolVariant()` for fill/circle/slash variants (see `references/variable-values-variants.md`)

## Core Guidelines

### Symbol Selection
- Always use `Image(systemName:)` — never custom icon assets or emoji
- Use the SF Symbols app to browse and preview symbols
- Prefer symbols with semantic meaning matching the action
- Check symbol availability per platform version

### Rendering Modes
- **Monochrome** (default): Single color, all layers. Best for toolbars and minimal UI.
- **Hierarchical**: Single color, varying opacity per layer. Best for sidebar icons — adds depth.
- **Palette**: Independent color per layer. Best for brand-specific or high-contrast needs.
- **Multicolor**: Apple's predefined colors. Best for weather, file types, decorative use.
- Passing multiple styles to `.foregroundStyle()` automatically implies palette mode.

### Animations — Always Add When Meaningful
Every symbol that reflects state should have an animation:
- **Discrete actions** (tap, confirm): `.symbolEffect(.bounce, value:)`
- **Ongoing activity** (loading, recording): `.symbolEffect(.pulse, isActive:)`
- **Scanning/searching**: `.symbolEffect(.variableColor.iterative, isActive:)`
- **Symbol toggle** (play/pause, bell/bell.slash): `.contentTransition(.symbolEffect(.replace))`
- **Alive/active indicator**: `.symbolEffect(.breathe, isActive:)` (macOS 15+)
- **Attention/notification**: `.symbolEffect(.wiggle, value:)` (macOS 15+)
- **Processing/syncing**: `.symbolEffect(.rotate, isActive:)` (macOS 15+)
- **Emphasis**: `.symbolEffect(.scale.up, isActive:)` for selection

### Sizing
- Use `.font(.system(size:))` or `.imageScale()` — not `.resizable().frame()`
- Font-based sizing renders from vector data at the correct resolution

### Accessibility
- Always respect `@Environment(\.accessibilityReduceMotion)` — disable or minimize effects when true
- Provide `accessibilityLabel` for symbols that aren't paired with text
- Use `.symbolVariant(.fill)` for selected states (iOS convention)

### Performance
- Avoid indefinite effects in `List` / `LazyVStack` rows
- Prefer discrete over indefinite when a one-shot suffices
- Don't stack multiple effects on one symbol
- `.monochrome` is cheapest; `.multicolor` with gradients is most expensive

## Quick Reference

### Effect Trigger Selection
| Scenario | Trigger | Example |
|----------|---------|---------|
| User taps a button | `value:` (discrete) | `.symbolEffect(.bounce, value: tapCount)` |
| Feature is active/loading | `isActive:` (indefinite) | `.symbolEffect(.pulse, isActive: isLoading)` |
| Toggle between two symbols | `.contentTransition` | `.contentTransition(.symbolEffect(.replace))` |
| Symbol enters the view | `.transition` | `.transition(.symbolEffect(.appear))` |

### All Effects at a Glance
| Effect | Discrete | Indefinite | Transition | Content | macOS |
|--------|----------|------------|------------|---------|-------|
| `.bounce` | Yes | Yes | — | — | 14+ |
| `.pulse` | Yes | Yes | — | — | 14+ |
| `.variableColor` | Yes | Yes | — | — | 14+ |
| `.scale` | — | Yes | — | — | 14+ |
| `.appear` | — | — | Yes | — | 14+ |
| `.disappear` | — | — | Yes | — | 14+ |
| `.replace` | — | — | — | Yes | 14+ |
| `.breathe` | — | Yes | — | — | 15+ |
| `.wiggle` | Yes | Yes | — | — | 15+ |
| `.rotate` | — | Yes | — | — | 15+ |

### Rendering Mode Selection
| Context | Recommended Mode |
|---------|-----------------|
| Toolbar / tab bar | Monochrome |
| Sidebar icons | Hierarchical |
| Status indicators with depth | Hierarchical |
| Brand-colored icons | Palette |
| Weather / file type icons | Multicolor |
| Custom theme needing layer control | Palette |

## Review Checklist

### Symbol Selection
- [ ] Using `Image(systemName:)` — no custom assets or emoji
- [ ] Symbol semantically matches its purpose
- [ ] Platform availability checked for target OS

### Rendering
- [ ] Rendering mode appropriate for context
- [ ] Using `.font(.system(size:))` for sizing (not `.resizable().frame()`)
- [ ] Hierarchical mode used for sidebar/toolbar icons where depth helps

### Animations
- [ ] State-reflecting symbols have a `symbolEffect`
- [ ] Correct trigger: `value:` for one-shot, `isActive:` for ongoing
- [ ] Symbol toggles use `.contentTransition(.symbolEffect(.replace))`
- [ ] View enter/exit uses `.transition(.symbolEffect(.appear/.disappear))`
- [ ] Options used for speed/repeat where needed

### Accessibility & Performance
- [ ] `@Environment(\.accessibilityReduceMotion)` respected
- [ ] `accessibilityLabel` on icon-only symbols
- [ ] No indefinite effects in scrollable list rows
- [ ] No stacked effects on a single symbol
- [ ] `.symbolVariant(.fill)` for selected states

## References
- `references/rendering-modes.md` — Monochrome, hierarchical, palette, multicolor with examples
- `references/effects-discrete.md` — Bounce, pulse, variableColor, wiggle (value-triggered)
- `references/effects-indefinite.md` — Pulse, variableColor, scale, breathe, rotate, wiggle (isActive-triggered)
- `references/content-transitions.md` — Replace, Magic Replace, appear, disappear transitions
- `references/effect-options.md` — SymbolEffectOptions: speed, repeat, periodic, chaining
- `references/variable-values-variants.md` — variableValue for progress, symbolVariant for fill/circle/slash
- `references/accessibility-performance.md` — Reduce motion, labels, sizing, performance patterns
