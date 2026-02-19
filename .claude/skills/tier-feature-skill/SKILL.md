---
name: tier-feature
description: Manage subscription tier features - add, move, or remove features across all documentation and code locations.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Tier Feature Management Skill

Automate adding, moving, or removing subscription tier features while ensuring consistency across all documentation and code locations.

## When to Use

Use this skill when:
- User wants to add a new feature to a subscription tier
- User wants to move a feature between tiers (e.g., from Pro to Plus)
- User wants to remove a feature from the tier system
- User mentions "tier feature", "add feature to tier", "move feature"

## Operations

| Operation | Description |
|-----------|-------------|
| `add` | Add a new feature to a tier |
| `move` | Move a feature from one tier to another |
| `remove` | Remove a feature from the tier system |

## Files to Update

When adding/moving/removing a tier feature, update ALL of these files:

| Category | File | What to Update |
|----------|------|----------------|
| **Plan (Source of Truth)** | `docs/PLANS/IN-PROGRESS/2026_01_22_SUBSCRIPTION_TIER_SYSTEM_PLAN.md` | Feature matrix table, `TIER_FEATURES` config, `TierFeature` enum, `INTENT_TO_FEATURE` map |
| **Feature Docs** | `docs/FEATURES.md` | Tiers Overview table, Feature Availability table |
| **Subscription Docs** | `docs/FEATURES/SUBSCRIPTION-TIERS.md` | Tier definitions, Feature Matrix table |
| **Business Logic** | `docs/BUSINESS_LOGIC.md` | Section 14.3 Feature Access Matrix (if exists) |
| **i18n (PT-BR)** | `packages/i18n/src/locales/pt.ts` | `subscription.feature.*` messages |
| **i18n (EN-US)** | `packages/i18n/src/locales/en.ts` | `subscription.feature.*` messages |
| **i18n Types** | `packages/i18n/src/types.ts` | Translation key types |
| **Tier Config** | `packages/shared/src/subscription/tier-config.ts` | `TIER_FEATURES`, `TierFeature` enum, `INTENT_TO_FEATURE` |
| **Prisma Schema** | `packages/database/prisma/schema.prisma` | `TierFeature` enum |

## Tier Hierarchy

```
FREE < PLUS < PRO
```

Features available in a lower tier are automatically available in higher tiers.

| Tier | Price (BRL) | Price (USD) | Price (EUR) |
|------|-------------|-------------|-------------|
| FREE | R$0 | $0 | €0 |
| PLUS | R$14.90 | $7.99 | €7.99 |
| PRO | R$24.90 | $12.99 | €12.99 |

## Current Features

| Feature | Enum Value | FREE | PLUS | PRO |
|---------|------------|------|-----------|-----|
| Create Transaction | `CREATE_TRANSACTION` | ✅ (30/mo limit) | ✅ | ✅ |
| Voice Notes | `VOICE_NOTES` | ✅ | ✅ | ✅ |
| Custom Categories | `CUSTOM_CATEGORIES` | ❌ | ✅ | ✅ |
| Custom Payment Methods | `CUSTOM_PAYMENT_METHODS` | ❌ | ✅ | ✅ |
| Basic Queries | `BASIC_QUERIES` | ❌ | ✅ | ✅ |
| Recurring Transactions | `RECURRING_TRANSACTIONS` | ❌ | ✅ | ✅ |
| Receipt Scanning (OCR) | `RECEIPT_SCANNING` | ❌ | ❌ | ✅ |
| Payment Reminders | `PAYMENT_REMINDERS` | ❌ | ❌ | ✅ |
| Installments | `INSTALLMENTS` | ❌ | ❌ | ✅ |
| Advanced Queries | `ADVANCED_QUERIES` | ❌ | ❌ | ✅ |

## Step-by-Step Process

### Adding a New Feature

1. **Gather information:**
   - Feature name (human-readable)
   - Enum value (SCREAMING_SNAKE_CASE)
   - Target tier (FREE, PLUS, or PRO)
   - Associated intent (if applicable)
   - Description for i18n messages

2. **Update Prisma schema** (`packages/database/prisma/schema.prisma`):
   ```prisma
   enum TierFeature {
     // ... existing features
     NEW_FEATURE
   }
   ```

3. **Update tier config** (`packages/shared/src/subscription/tier-config.ts`):
   - Add to `TierFeature` enum
   - Add to `TIER_FEATURES` for each tier
   - Add to `INTENT_TO_FEATURE` if applicable

4. **Add i18n messages** (`packages/i18n/src/locales/{pt,en}.ts`):
   ```typescript
   'subscription.feature.newFeature': 'Message explaining the feature is unavailable...',
   ```

5. **Update documentation:**
   - `docs/FEATURES/SUBSCRIPTION-TIERS.md` - Feature matrix
   - `docs/PLANS/IN-PROGRESS/2026_01_22_SUBSCRIPTION_TIER_SYSTEM_PLAN.md` - Plan docs
   - `docs/FEATURES.md` - Main features doc (if applicable)

6. **Create migration** (if enum changed in schema):
   ```bash
   pnpm prisma migrate dev --name add_tier_feature_xxx
   ```

### Moving a Feature Between Tiers

1. **Identify the feature** and current/target tiers

2. **Update tier config** (`packages/shared/src/subscription/tier-config.ts`):
   - Set `feature: false` in old tier
   - Set `feature: true` in new tier

3. **Update i18n messages** - adjust upgrade prompts to reference correct tier

4. **Update documentation** - update all feature matrix tables

### Removing a Feature

1. **Remove from tier config** - set `false` in all tiers or remove entirely

2. **Remove i18n messages** - delete `subscription.feature.xxx` keys

3. **Update documentation** - remove from all feature matrix tables

4. **Consider migration** - if removing from Prisma enum, create migration

## Example: Adding "CSV Export" to PRO

**User:** "Add CSV Export feature to Pro tier"

**Steps:**

1. Update `packages/database/prisma/schema.prisma`:
```prisma
enum TierFeature {
  // ... existing
  CSV_EXPORT
}
```

2. Update `packages/shared/src/subscription/tier-config.ts`:
```typescript
// In TierFeature enum
CSV_EXPORT = 'CSV_EXPORT',

// In TIER_FEATURES
FREE: { features: { csvExport: false, ... } },
PLUS: { features: { csvExport: false, ... } },
PRO: { features: { csvExport: true, ... } },

// In INTENT_TO_FEATURE (if applicable)
EXPORT_CSV: TierFeature.CSV_EXPORT,
```

3. Add i18n messages:
```typescript
// pt.ts
'subscription.feature.csvExport': '📊 A exportação CSV está disponível no plano Pro.\n\n✨ Com o Pro ({{proPrice}}), exporte seus dados a qualquer momento!',

// en.ts
'subscription.feature.csvExport': '📊 CSV export is available on the Pro plan.\n\n✨ With Pro ({{proPrice}}), export your data anytime!',
```

4. Update `docs/FEATURES/SUBSCRIPTION-TIERS.md`:
```markdown
| CSV Export | ❌ | ❌ | ✅ |
```

5. Create migration:
```bash
pnpm prisma migrate dev --name add_csv_export_feature
```

## Example: Moving "Recurring Transactions" from PRO to PLUS

**User:** "Move recurring transactions to Plus tier"

**Steps:**

1. Update `packages/shared/src/subscription/tier-config.ts`:
```typescript
// In TIER_FEATURES
PLUS: { features: { recurringTransactions: true, ... } }, // Changed from false
PRO: { features: { recurringTransactions: true, ... } },       // Keep true
```

2. Update i18n message to reference Plus instead of Pro:
```typescript
'subscription.feature.recurring': '🔄 Transações recorrentes são uma funcionalidade do plano Plus...',
```

3. Update all feature matrix tables in docs.

## Validation Checklist

After making changes, verify:

- [ ] Prisma schema compiles: `pnpm prisma validate`
- [ ] TypeScript compiles: `pnpm typecheck`
- [ ] All feature matrices are consistent across docs
- [ ] i18n messages reference correct tier names and prices
- [ ] Migration created (if schema changed)
- [ ] Tests updated (if applicable)

## Common Mistakes to Avoid

- **Don't** forget to update ALL documentation files
- **Don't** use different feature names in different files
- **Don't** hardcode prices in i18n - use `{{essentialPrice}}` and `{{proPrice}}` placeholders
- **Don't** forget to run `pnpm prisma migrate dev` after schema changes
- **Do** use SCREAMING_SNAKE_CASE for enum values
- **Do** use camelCase for feature keys in `TIER_FEATURES`
- **Do** keep feature availability consistent with tier hierarchy (lower tier features available in higher tiers)
