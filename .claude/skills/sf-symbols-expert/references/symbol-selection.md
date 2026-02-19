# Symbol Selection Guide

How to choose the right SF Symbol for common UI patterns.

## Table of Contents
- [Selection Principles](#selection-principles)
- [LUMNO Symbol Map](#lumno-symbol-map)
- [Common Categories](#common-categories)
- [Platform Availability](#platform-availability)

---

## Selection Principles

1. **Semantic match**: The symbol should visually represent the action or concept
2. **Consistency**: Use the same symbol for the same concept throughout the app
3. **Platform convention**: Follow macOS/iOS conventions where they exist
4. **Availability**: Check the symbol exists on your minimum deployment target
5. **Layer support**: If you need hierarchical/palette rendering, choose symbols with multiple layers

---

## LUMNO Symbol Map

Recommended symbols for LUMNO's UI elements:

### Navigation
| Element | Symbol | Notes |
|---------|--------|-------|
| Sessions | `rectangle.stack` | Stack of cards = session list |
| Commands | `terminal` | Terminal prompt |
| Skills | `bolt.circle` | Lightning = quick actions |
| Configuration | `gearshape` | Standard settings icon |
| Search | `magnifyingglass` | Standard search |
| Back | `chevron.left` | Standard back navigation |

### Session Detail
| Element | Symbol | Notes |
|---------|--------|-------|
| User message avatar | `person.crop.circle` | User identity |
| Claude message avatar | `brain` or custom | AI identity |
| Resume session | `arrow.uturn.forward` | Continue action |
| Re-run command | `arrow.clockwise` | Retry/refresh |
| Copy | `doc.on.doc` | Standard copy |
| Expand/Collapse | `chevron.right` / `chevron.down` | Disclosure |
| Timestamp | `clock` | Time reference |
| Token count | `number` | Numeric data |

### Tool Blocks
| Tool | Symbol | Notes |
|------|--------|-------|
| Read | `doc.text` | Document read |
| Write | `doc.text.fill` | Document write (filled = action) |
| Edit | `pencil` | Editing |
| Bash | `terminal` | Shell command |
| Glob | `magnifyingglass` | File search |
| Grep | `text.magnifyingglass` | Content search |
| Task | `checklist` | Task management |

### Status
| State | Symbol | Effect |
|-------|--------|--------|
| Active/connected | `circle.fill` (6pt, green) | `.breathe` if prominent |
| Idle/disconnected | `circle.fill` (6pt, tertiary) | none |
| Loading | `gear` | `.rotate` |
| Error | `exclamationmark.triangle` | `.bounce` on appear |
| Success | `checkmark.circle.fill` | `.bounce` on appear |

### MCP Servers
| Element | Symbol | Notes |
|---------|--------|-------|
| Connected | `bolt.circle.fill` | Energy = active connection |
| Disconnected | `bolt.slash` | Slash = unavailable |
| Tool count | `wrench.and.screwdriver` | Tools |
| Configure | `slider.horizontal.3` | Settings/tuning |

### Configuration Cards
| Card | Symbol | Notes |
|------|--------|-------|
| Skills | `bolt.circle.fill` | Quick actions |
| Slash Commands | `command` or `slash.circle` | Command prefix |
| MCP Servers | `server.rack` | Infrastructure |
| Models | `brain` | AI model |
| Sub-agents | `person.2` | Multiple agents |
| Output Styles | `waveform` | Audio/output |

---

## Common Categories

### Actions
- Add: `plus`
- Remove: `minus` or `trash`
- Edit: `pencil`
- Share: `square.and.arrow.up`
- Download: `arrow.down.circle`
- Refresh: `arrow.clockwise`
- Settings: `gearshape`

### Content Types
- File: `doc`
- Folder: `folder`
- Code: `chevron.left.forwardslash.chevron.right`
- Image: `photo`
- Text: `doc.text`

### Communication
- Chat: `bubble.left`
- Notification: `bell`
- Info: `info.circle`
- Warning: `exclamationmark.triangle`
- Error: `xmark.circle`

---

## Platform Availability

Check symbol availability using the SF Symbols app. Key thresholds for LUMNO (macOS 15+):

- **macOS 12+**: All basic symbols, rendering modes, variants
- **macOS 13+**: Variable value support
- **macOS 14+**: Symbol effects (bounce, pulse, variableColor, scale, appear, disappear, replace)
- **macOS 15+**: Breathe, wiggle, rotate, Magic Replace

Since LUMNO targets macOS 15+, **all effects are available** without `#available` checks.
