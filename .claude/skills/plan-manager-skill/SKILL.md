---
name: plan-manager
description: Create and manage implementation plans in docs/PLANS. Create new plans, move between folders, and list existing plans.
allowed-tools: Bash, Read, Write, Glob, Grep, TodoWrite
---

# Plan Manager Skill

Create, manage, and organize implementation plans in the `docs/PLANS/` folder structure.

## When to Use

Use this skill when:
- User wants to create a new plan
- User mentions "create plan", "new plan", "add plan"
- User wants to move a plan (start, complete, archive)
- User asks to list or show plans
- User wants to check plan status

## Folder Structure

| Folder | Purpose | When to Use |
|--------|---------|-------------|
| `docs/PLANS/TO-DO/` | Planned features waiting | New plans start here |
| `docs/PLANS/IN-PROGRESS/` | Currently being implemented | Move here when work starts |
| `docs/PLANS/COMPLETED/` | Finished implementations | Archive when done |

## Naming Convention

**Format:** `YYYY_MM_DD_FEATURE_NAME_PLAN.md`

**Examples:**
- `2025_12_18_INSTALLMENTS_PLAN.md`
- `2025_12_18_MVP_EXPENSE_BUSINESS_LOGIC_PLAN.md`
- `2025_12_19_WEBHOOK_RETRY_PLAN.md`

## Plan Template

When creating a new plan, use this structure:

```markdown
# Feature Name

> **Status:** TODO | IN-PROGRESS | COMPLETED
> **Created:** YYYY-MM-DD
> **Depends on:** (optional) Other features

## Summary

Brief description of what this feature does and why it's needed.

---

## Scope

### IN SCOPE
- Feature 1
- Feature 2

### OUT OF SCOPE
- Deferred feature 1
- Not part of this implementation

---

## 1. Database Schema

(If applicable)

```prisma
model Example {
  // Schema here
}
```

---

## 2. Business Logic

Describe the core logic, flows, algorithms.

---

## 3. API Endpoints

(If applicable)

```
GET    /v1/resource
POST   /v1/resource
```

---

## 4. Implementation Order

### Step 1: First Step
- [ ] Task 1
- [ ] Task 2

### Step 2: Second Step
- [ ] Task 3
- [ ] Task 4

---

## 5. Application Scope (Monorepo)

**IMPORTANT:** This project is a Turborepo monorepo with the following structure:

| Package/App | Path | Purpose |
|-------------|------|---------|
| `@ignio/api` | `apps/api/` | Fastify API server (api.ignio.app) |
| `@ignio/worker` | `apps/worker/` | BullMQ job processors |
| `@ignio/dashboard` | `apps/dashboard/` | Next.js 15 web dashboard (my.ignio.app) |
| `@ignio/database` | `packages/database/` | Prisma schema and client |
| `@ignio/config` | `packages/config/` | Environment configuration |
| `@ignio/i18n` | `packages/i18n/` | Internationalization |
| `@ignio/lib` | `packages/lib/` | Shared utilities (redis, logger, etc.) |
| `@ignio/shared` | `packages/shared/` | Constants, types, utilities |

**Specify which application(s) this feature affects:**
- [ ] API only (`apps/api/`)
- [ ] Worker only (`apps/worker/`)
- [ ] Dashboard only (`apps/dashboard/`)
- [ ] API + Worker (shared business logic)
- [ ] Shared packages (affects all apps)

---

## 6. Files to Create

| File | Purpose |
|------|---------|
| `apps/api/src/services/example.service.ts` | Service layer (API) |
| `apps/api/src/routes/example.routes.ts` | API endpoints |
| `apps/worker/src/services/example.service.ts` | Service layer (Worker) |
| `apps/dashboard/src/components/Example.tsx` | Dashboard component |
| `packages/shared/src/types/example.ts` | Shared types |

## 7. Files to Modify

| File | Changes |
|------|---------|
| `packages/database/prisma/schema.prisma` | Add new models |
| `packages/config/src/environments.ts` | Add feature flags |

---

## 8. Pipeline Integration

**IMPORTANT:** For features that involve processing user messages or media (OCR, ASR, etc.), remember to update BOTH pipelines:

### Playground Pipeline (for CLI testing)
- `apps/api/src/playground/runners/*.runner.ts` - Update runner to pass new hints/data

### Worker Pipeline (for production WhatsApp)
- `apps/worker/src/workers/agent.processor.ts` - Extract and build hints from stored data
- `apps/worker/src/services/agent-pipeline.service.ts` - Update types and pass data to agents

Example:
```typescript
// apps/worker/src/workers/agent.processor.ts - Build hints from OCR text
const fiscalResult = detectFiscalDocument(combinedText);
const totalAmount = extractTotalAmount(combinedText);
receiptHints = {
  isReceipt: true,
  ...(totalAmount ? { total: `R$ ${totalAmount.toFixed(2)}` } : {}),
  ...(fiscalResult.isFiscalDocument ? { fiscalDocument } : {}),
};

// apps/worker/src/services/agent-pipeline.service.ts - Pass to Transaction Agent
receiptHints: input.receiptHints ? {
  counterparty: input.receiptHints.vendor,
  total: input.receiptHints.total,
  fiscalDocument: input.receiptHints.fiscalDocument,
} : undefined,
```

---

## 9. Test Cases

- Test case 1
- Test case 2
- Edge case 1

---

## 10. Internationalization (i18n)

**IMPORTANT:** All user-facing strings MUST use the i18n system. Never use inline translations.

### Package Location
The i18n package is at `packages/i18n/`. Both API and Worker apps have local copies for now.

### Pattern
```typescript
// In apps/api/ or apps/worker/
import { t } from '../i18n/index.js';
import type { TranslationKey } from '../i18n/types.js';

// Use t() for all user-facing strings
const message = t('feature.success.created', { name: entityName }, context.locale);

// For dynamic keys (e.g., enum values)
const key = `featureType.${type}` as TranslationKey;
const label = t(key, undefined, locale);
```

### Checklist
- [ ] Add translation keys to `packages/i18n/src/locales/en.ts`
- [ ] Add translation keys to `packages/i18n/src/locales/pt.ts`
- [ ] Add key types to `packages/i18n/src/types.ts` (TranslationKey union)
- [ ] Copy to app-local i18n if needed: `apps/api/src/i18n/` and `apps/worker/src/i18n/`
- [ ] Use `t(key, params?, locale?)` in all agents/services
- [ ] Never use inline conditional translations like `isPtBr ? 'texto' : 'text'`
- [ ] Use lowercase for labels that appear mid-sentence (e.g., "credit card" not "Credit Card")

### Key Naming Convention
```
feature.action.context
feature.error.errorType
feature.clarification.questionType
featureType.ENUM_VALUE
```

---

## 11. Agent Clarification Flow

**IMPORTANT:** When an agent detects user intent but required information is missing, use the clarification pattern.

### Pattern

```typescript
import { t, normalizeLocale } from '../i18n/index.js';

// In agent's parseResponse or execute method:
const locale = normalizeLocale(response.inputLanguage);

// Validate required fields
if (!amount || amount <= 0) {
  return {
    success: false,
    inputLanguage: response.inputLanguage,
    needsClarification: true,
    clarificationQuestion: t('clarification.amount.question', undefined, locale),
  };
}

// Feature-specific validation (e.g., installments)
if (response.installment?.isInstallment) {
  if (!response.installment.totalInstallments) {
    return {
      success: false,
      inputLanguage: response.inputLanguage,
      needsClarification: true,
      clarificationQuestion: t('installment.clarification.howMany', undefined, locale),
    };
  }
}
```

### Translation Keys Required

For each clarification, add keys to both locale files:

**packages/i18n/src/locales/en.ts:**
```typescript
'feature.clarification.fieldName': "What is the field value?",
```

**packages/i18n/src/locales/pt.ts:**
```typescript
'feature.clarification.fieldName': "Qual é o valor do campo?",
```

**packages/i18n/src/types.ts:**
```typescript
| 'feature.clarification.fieldName'
```

### Common Clarification Types

| Field | English Key | Portuguese Key |
|-------|-------------|----------------|
| Amount | `clarification.amount.question` | `Qual foi o valor?` |
| Counterparty | `clarification.counterparty.question` | `Onde foi essa despesa?` |
| Installments | `installment.clarification.howMany` | `Em quantas vezes?` |
| Category | `clarification.category.question` | `Qual categoria devo usar?` |

### Validation Order

1. Check for explicit `needsClarification: true` from LLM
2. Validate required fields (amount, etc.)
3. Validate feature-specific fields (installments, recurrence, etc.)
4. Validate field bounds/constraints (e.g., installments 2-48)

---

## 12. Feedback & Reply Integration

**CRITICAL:** When implementing features that create or modify transaction/entity data, you MUST update the feedback and reply flows.

### Feedback Flow (User Confirmation)

When new fields are added to transactions or entities, update the feedback system:

**Files to modify:**
- `apps/api/src/services/feedback-blocks.service.ts` - Add field to `TransactionFeedbackData` interface
- `apps/api/src/services/agent-pipeline.service.ts` - Pass new data to feedback generator
- `apps/worker/src/services/feedback-blocks.service.ts` - Same for worker
- `apps/worker/src/services/agent-pipeline.service.ts` - Same for worker

**Pattern:**
```typescript
// 1. Add to TransactionFeedbackData interface
export interface TransactionFeedbackData {
  // ... existing fields
  /** New feature data */
  newFeature?: {
    field1: string;
    field2: number;
  };
}

// 2. Add enrichment in generateEnrichments()
if (data.newFeature) {
  enrichments.push({
    type: 'new_feature',
    text: t('feedback.enrichment.newFeature', { ... }, locale),
    priority: 1,
  });
}

// 3. Pass data in agent-pipeline.service.ts
const newFeatureData = agentResults.transaction.data.newFeature;
if (newFeatureData) {
  feedbackData.newFeature = { ... };
}
```

### Reply Flow (WhatsApp Responses)

For features requiring structured replies (not just text), update:

**Files to modify:**
- `apps/api/src/services/reply-builder.service.ts` - Build WhatsApp message structures (if exists)
- `apps/worker/src/workers/agent.processor.ts` - Handle reply sending

### i18n Requirements

All new user-facing strings MUST use i18n:

**Checklist:**
- [ ] Add keys to `packages/i18n/src/locales/en.ts`
- [ ] Add keys to `packages/i18n/src/locales/pt.ts`
- [ ] Add types to `packages/i18n/src/types.ts`
- [ ] Copy to app-local i18n if needed: `apps/api/src/i18n/` and `apps/worker/src/i18n/`
- [ ] Use `t(key, params, locale)` in code
- [ ] NEVER use inline translations like `isPtBr ? 'pt' : 'en'`

**Key naming for feedback:**
```
feedback.enrichment.featureName
feedback.confirmation.featureName
feature.label.fieldName
```

---

## 13. Notes

- Important consideration 1
- Important consideration 2
```

## Operations

### Create New Plan

1. Get the feature name from user
2. Generate filename: `YYYY_MM_DD_FEATURE_NAME_PLAN.md`
3. Create in `docs/PLANS/TO-DO/`
4. Set status to `TODO`
5. Fill template with user-provided details

```bash
# Get today's date
date +%Y_%m_%d

# Create file
docs/PLANS/TO-DO/2025_12_19_FEATURE_NAME_PLAN.md
```

### Start Plan (Move to IN-PROGRESS)

1. Find plan in `TO-DO/`
2. Move to `IN-PROGRESS/`
3. Update status to `IN-PROGRESS`

```bash
mv docs/PLANS/TO-DO/plan_file.md docs/PLANS/IN-PROGRESS/
```

### Complete Plan (Move to COMPLETED)

1. Find plan in `IN-PROGRESS/`
2. Move to `COMPLETED/`
3. Update status to `COMPLETED`
4. Add completion date

```bash
mv docs/PLANS/IN-PROGRESS/plan_file.md docs/PLANS/COMPLETED/
```

### List Plans

```bash
# List all plans by folder
echo "=== TO-DO ===" && ls docs/PLANS/TO-DO/
echo "=== IN-PROGRESS ===" && ls docs/PLANS/IN-PROGRESS/
echo "=== COMPLETED ===" && ls docs/PLANS/COMPLETED/
```

## Interactive Flow for New Plan

When user asks to create a plan:

1. **Ask for feature name** (e.g., "Installments", "Webhook Retry")
2. **Ask for brief description**
3. **Ask what's in scope** (bullet points)
4. **Ask about dependencies** (optional)
5. **Generate the plan file**
6. **Show the created plan**
7. **Ask if user wants to add more sections**

## Example Usage

**User:** "Create a plan for webhook retry logic"

**Assistant:**
1. Creates `docs/PLANS/TO-DO/2025_12_19_WEBHOOK_RETRY_PLAN.md`
2. Fills in template with:
   - Feature name
   - Summary
   - Scope
   - Basic structure
3. Shows the plan
4. Offers to add more details

## Error Handling

- If plan with same name exists, ask to overwrite or rename
- If moving plan that doesn't exist, show available plans
- Validate folder structure exists before operations
