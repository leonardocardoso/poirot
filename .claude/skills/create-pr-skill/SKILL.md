---
name: create-pr
model: claude-opus-4-6
description: Run quality checks (lint, typecheck, unit tests, integration tests) and create a PR.
allowed-tools: Bash, Read, Glob, Grep, TodoWrite, mcp__github__create_pull_request
---

# Create PR Skill

Run quality checks and create a pull request after all checks pass.

## When to Use

Use this skill when:
- User wants to create a PR
- User mentions "create pr", "make pr", "open pr", "submit pr"
- User says "ready to merge", "prepare for review"
- User wants to run all checks before creating a PR

## Quality Checks

Run the following checks in order. All must pass before creating the PR:

### 1. Linting
```bash
pnpm lint
```
- Checks code style and quality rules
- Must pass with no errors (warnings are acceptable)
- If errors found, fix them before proceeding

### 2. Type Checking
```bash
pnpm typecheck
```
- Runs TypeScript compiler in check mode
- Ensures all types are correct
- Must pass with no errors

### 3. Unit Tests
```bash
pnpm test:unit
```
- Runs Vitest unit test suite
- Must have 100% pass rate
- **Coverage thresholds:** Lines 80%, Functions 80%, Branches 70%, Statements 80%
- If coverage is below threshold, add tests for new/modified code before creating PR
- Check coverage report: `pnpm test:unit --coverage`

### 4. Integration Tests
```bash
pnpm test:integration
```
- Runs integration test suite
- Tests actual service interactions
- Must have 100% pass rate
- **If adding new services/endpoints:** Add corresponding integration tests before creating PR

### 4.5. Test Coverage for New Functionality

Before creating the PR, ensure new functionality has appropriate test coverage:

**Unit Tests (Required):**
- New utility functions (e.g., `extractFirstName()`, `formatAmount()`)
- New service methods or significant logic changes
- Edge cases (null inputs, accented characters, boundary values)
- Mock external dependencies (LLM clients, databases)

**Integration Tests (When Applicable):**
- New API endpoints
- New agent behaviors or intent detection changes
- Database schema changes affecting queries
- External service integrations

**Test File Mapping Patterns:**

| Source File Pattern | Expected Test File Location |
|---------------------|----------------------------|
| `apps/api/src/services/foo.service.ts` | `apps/api/src/__tests__/unit/services/foo.service.test.ts` |
| `apps/api/src/routes/foo.routes.ts` | `apps/api/src/__tests__/integration/routes/foo.routes.test.ts` |
| `apps/api/src/tools/foo.tool.ts` | `apps/api/src/__tests__/unit/tools/foo.tool.test.ts` |
| `apps/api/src/lib/foo.ts` | `apps/api/src/__tests__/unit/lib/foo.test.ts` |
| `apps/worker/src/services/foo.service.ts` | `apps/worker/src/__tests__/unit/services/foo.service.test.ts` |

**How to identify missing tests:**
```bash
# Check which files changed (excluding tests)
git diff main --name-only | grep -E '\.(ts|tsx)$' | grep -v '__tests__' | grep -v '\.test\.'

# For each new/modified source file, check if corresponding test exists
# Example: if apps/api/src/services/tab.service.ts was added
ls apps/api/src/__tests__/unit/services/tab.service.test.ts 2>/dev/null || echo "MISSING"
```

**When to add tests:**
- New exported functions → Add unit tests
- New LLM prompt fields → Add prompt validation tests
- New parameters passed to functions → Add parameter handling tests
- New edge cases discovered → Add regression tests

**Minimum test cases per function:**
1. Happy path (normal successful case)
2. Edge cases (null, empty, boundary values)
3. Error cases (invalid input, failures)

### 4.6. Unit Test Template (Prisma Mocking Pattern)

Use `vi.hoisted()` for mocking Prisma to ensure mocks are defined before imports:

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';

// Define mocks with vi.hoisted() - MUST be before vi.mock()
const mockPrisma = vi.hoisted(() => ({
  model: {
    findMany: vi.fn(),
    findFirst: vi.fn(),
    findUnique: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    count: vi.fn(),
  },
  $transaction: vi.fn((callback) => callback(mockPrisma)),
}));

// Mock the prisma module
vi.mock('@/lib/prisma.js', () => ({
  prisma: mockPrisma,
}));

// Import AFTER mocking
import { functionToTest } from '@/services/example.service.js';

describe('example.service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('functionToTest', () => {
    it('should handle normal case', async () => {
      // Arrange
      mockPrisma.model.findMany.mockResolvedValue([{ id: '1' }]);

      // Act
      const result = await functionToTest('userId');

      // Assert
      expect(result.success).toBe(true);
      expect(mockPrisma.model.findMany).toHaveBeenCalledWith({
        where: { userId: 'userId' },
      });
    });

    it('should handle error case', async () => {
      mockPrisma.model.findMany.mockRejectedValue(new Error('DB error'));

      await expect(functionToTest('userId')).rejects.toThrow('DB error');
    });
  });
});
```

### 4.7. Integration Test Template (Fastify + JWT Auth)

Use `createTestServer()` and `generateTestToken()` for authenticated route testing:

```typescript
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { createTestServer, generateTestToken } from '@/__tests__/helpers/fastify.js';
import type { FastifyInstance } from 'fastify';

describe('example.routes', () => {
  let server: FastifyInstance;
  let authToken: string;
  const TEST_USER_ID = 'test-user-id';

  beforeAll(async () => {
    server = await createTestServer();
    // Generate JWT token for authenticated requests
    authToken = generateTestToken(server, { sub: TEST_USER_ID });
  });

  afterAll(async () => {
    await server.close();
  });

  describe('GET /api/v1/resource', () => {
    it('should return 401 without authentication', async () => {
      const response = await server.inject({
        method: 'GET',
        url: '/api/v1/resource',
      });
      expect(response.statusCode).toBe(401);
    });

    it('should return 200 with valid token', async () => {
      const response = await server.inject({
        method: 'GET',
        url: '/api/v1/resource',
        headers: {
          authorization: `Bearer ${authToken}`,
        },
      });
      expect(response.statusCode).toBe(200);
    });
  });

  describe('POST /api/v1/resource', () => {
    it('should return 400 for invalid payload', async () => {
      const response = await server.inject({
        method: 'POST',
        url: '/api/v1/resource',
        headers: { authorization: `Bearer ${authToken}` },
        payload: { invalid: 'data' },
      });
      expect(response.statusCode).toBe(400);
    });

    it('should return 201 for valid payload', async () => {
      const response = await server.inject({
        method: 'POST',
        url: '/api/v1/resource',
        headers: { authorization: `Bearer ${authToken}` },
        payload: { name: 'Test Resource' },
      });
      expect(response.statusCode).toBe(201);
      expect(response.json()).toHaveProperty('id');
    });
  });
});
```

### 5. Security Review
- Review code changes for potential security vulnerabilities
- Check for OWASP top 10 issues (SQL injection, XSS, command injection, etc.)
- Verify no hardcoded secrets or credentials
- Ensure proper input validation on user-facing endpoints
- Check authentication/authorization is properly enforced

### 6. Migration Validation
If database schema changes are involved:
```bash
# Check if migrations are properly created
pnpm prisma validate
```
- Verify migration files exist for schema changes
- Check migrations are reversible (have proper down migrations)
- Ensure migration names are descriptive
- Verify seed data updates if new tables/columns added

### 7. Feedback & Reply Integration Check

**CRITICAL:** If the PR adds new fields to transactions or entities, verify these integrations are complete:

**Feedback Flow (User Confirmations):**
- [ ] New fields added to `TransactionFeedbackData` interface in `feedback-blocks.service.ts`
- [ ] Enrichment or confirmation text added for new data in `generateEnrichments()` or `generateConfirmation()`
- [ ] Data passed to feedback generator in `agent-pipeline.service.ts`
- [ ] Translation keys added for any new feedback text

**Reply Flow (WhatsApp Structured Replies):**
- [ ] If feature needs structured replies (buttons, lists), update `reply-builder.service.ts`
- [ ] Handle reply in `agent.processor.ts` if needed

**i18n Completeness:**
- [ ] All new user-facing strings use `t(key, params, locale)`
- [ ] Keys added to `src/i18n/locales/en.ts`
- [ ] Keys added to `src/i18n/locales/pt.ts`
- [ ] Types added to `src/i18n/types.ts`
- [ ] NO inline translations like `isPtBr ? 'pt' : 'en'`

**How to check:**
```bash
# Find new fields in agent output schemas
git diff main -- src/schemas/agent.schema.ts | grep -E '^\+.*:'

# Check if corresponding feedback data exists
grep -n "TransactionFeedbackData" src/services/feedback-blocks.service.ts

# Find any inline translations (should return 0 results)
grep -rn "isPtBr\|isPortuguese\|startsWith('pt')" src/ --include="*.ts"
```

### 8. FAQ Update Check (if applicable)

If the PR adds, modifies, or removes user-facing features, check if the in-app FAQ needs updating:

**When to update FAQ:**
- New feature added → Add to FAQ translations
- Feature behavior changed → Update FAQ examples
- Feature removed → Remove from FAQ

**Files to check:**
- `src/i18n/locales/en.ts` - English FAQ entries (`faq.feature.*` keys)
- `src/i18n/locales/pt.ts` - Portuguese FAQ entries (`faq.feature.*` keys)
- `src/services/faq.service.ts` - Feature list and emojis

**Verify FAQ responses:**
```bash
# Test FAQ in both languages
pnpm playground "What can you do?"
pnpm playground "O que você pode fazer?"
```

**FAQ feature keys:**
- `faq.feature.expense.*` - Expense tracking
- `faq.feature.income.*` - Income tracking
- `faq.feature.calendar.*` - Calendar events
- `faq.feature.query.*` - Data queries
- `faq.feature.category.*` - Category management
- `faq.feature.receipt.*` - Receipt scanning
- `faq.feature.voice.*` - Voice notes

If you add a new feature, ensure you:
1. Add translation keys to `src/i18n/types.ts`
2. Add English translations to `src/i18n/locales/en.ts`
3. Add Portuguese translations to `src/i18n/locales/pt.ts`
4. Add feature to `FEATURE_KEYS` array in `src/services/faq.service.ts`
5. Add emoji to `FEATURE_EMOJIS` object

## Process

1. **Track Progress**: Create todo list with each check
2. **Identify Changed Files**: Find all new/modified source files (excluding tests)
3. **Verify Tests Exist**: Check for corresponding test files using the mapping patterns
4. **CREATE MISSING TESTS**: Write unit and integration tests for new code BEFORE running quality checks
5. **Run Checks Sequentially**: Each check depends on previous passing
6. **Report Issues**: If any check fails, report the specific errors
7. **Fix Issues**: Help fix any failing checks before proceeding
8. **Create PR**: Only after all checks pass AND tests are written

## Plan File Management

After PR is created successfully, move any implementation plan files from IN-PROGRESS to COMPLETED:

```bash
# Check for plan files in IN-PROGRESS that relate to this feature
ls docs/PLANS/IN-PROGRESS/

# Move completed plan to COMPLETED folder
mv docs/PLANS/IN-PROGRESS/<plan-file>.md docs/PLANS/COMPLETED/
```

- Only move plans that are fully implemented by this PR
- Commit the move as part of the PR or as a follow-up commit
- If the plan spans multiple PRs, leave it in IN-PROGRESS until all work is done

## PR Creation

After all checks pass:

1. **Get Branch Info**:
```bash
git branch --show-current
git log main..HEAD --oneline
git diff main...HEAD --stat
```

2. **Check Remote Status**:
```bash
git status
```

3. **Push If Needed**:
```bash
git push -u origin $(git branch --show-current)
```

4. **Create PR** using GitHub MCP tool or gh CLI.

### PR Title Format

Use conventional commit format with optional issue reference:

```
<type>(<scope>): <description> [#issue]
```

**Examples:**
- `feat(date): add date detection service with 3-level waterfall`
- `feat(duplicate-detection): implement duplicate detection #18`
- `feat(category-taxonomy): implement category management`
- `fix(auth): resolve JWT refresh token race condition #42`
- `refactor(agents): simplify orchestrator intent detection`

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code refactoring (no functional change)
- `docs` - Documentation only
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

### PR Body Template

Use the template at `.github/pull_request_template.md` which includes:
- **Summary** - Bullet points describing what the PR does
- **Changes** - Table of files changed with descriptions
- **Highlights** - Notable implementation details, architectural decisions
- **Playground Demo** - Actual playground output demonstrating the feature
- **Test Plan** - Checklist of quality gates

### 7. Playground Demo

Before creating the PR, run the playground with a relevant test message to demonstrate the feature:

```bash
pnpm playground '<your-test-message>'
```

- Choose a message that exercises the new/modified functionality
- For agent changes: test the agent's intent detection and response
- For category changes: test creating, listing, or using categories
- For expense changes: test logging expenses with various inputs
- Capture the full output to include in the PR

**Example test messages:**
- Category creation: `"criar categoria Almoço de Trabalho"`
- Expense logging: `"Gastei 50 reais no mercado ontem"`
- Calendar: `"agendar reunião amanhã às 14h"`

```bash
gh pr create --title "feat(scope): description" --body "$(cat <<'EOF'
## Summary

- First change
- Second change

## Changes

| File | Description |
|------|-------------|
| `src/path/file.ts` | Description |

## Highlights

- Notable detail or decision

## Playground Demo

\`\`\`
pnpm playground 'your-test-message'
\`\`\`

<details>
<summary>Playground Response</summary>

\`\`\`
<!-- Paste playground output here -->
\`\`\`

</details>

## Test Plan

- [x] Lint passes
- [x] Typecheck passes
- [x] Unit tests pass (N tests)
- [x] Integration tests pass
- [x] Security review completed
- [x] Migrations validated (if applicable)
- [x] Feedback/Reply integration verified (if new fields)
- [x] i18n completeness verified (no inline translations)
- [x] FAQ updated (if feature changes)
- [x] Playground demo included above
EOF
)"
```

## Error Handling

### Lint Errors
- Show the specific errors
- Offer to auto-fix with `pnpm lint --fix` if applicable
- Help fix remaining manual issues

### Type Errors
- Show the specific type errors with file:line
- Help fix type issues
- May need to update interfaces or add type assertions

### Test Failures
- Show which tests failed
- Show the error messages and stack traces
- Help fix the failing tests

### Coverage Failures
- Show current vs required coverage
- Identify uncovered lines
- Help add tests for uncovered code

### Missing Tests (BLOCKER)
- DO NOT proceed without tests for new code
- Create test files following the templates above (4.6, 4.7)
- Ensure at least 3 test cases per new function (happy path, edge case, error case)

## Checklist Before PR

- [ ] All new source files have corresponding test files
- [ ] Unit tests exist for new services/tools/lib functions
- [ ] Integration tests exist for new routes/endpoints
- [ ] Unit test coverage ≥ 80% (lines, functions, statements)
- [ ] All tests pass (unit and integration)
- [ ] Lint passes
- [ ] Typecheck passes
- [ ] No missing mocks (Prisma models, external services)
- [ ] Security review completed
- [ ] Migrations validated (if applicable)

## Example Workflow

**Scenario:** User asks "Create a PR for the tabs feature"

1. **Create todo list** for each quality check
2. **Identify new source files:**
   ```bash
   git diff main --name-only | grep -E '\.(ts|tsx)$' | grep -v '__tests__'
   ```
   Found: `apps/api/src/services/tab.service.ts`, `apps/api/src/routes/tab.routes.ts`

3. **Check for existing tests:**
   ```bash
   ls apps/api/src/__tests__/unit/services/tab.service.test.ts  # MISSING
   ls apps/api/src/__tests__/integration/routes/tab.routes.test.ts  # MISSING
   ```

4. **CREATE missing tests** using templates (4.6, 4.7):
   - Create `tab.service.test.ts` with Prisma mocking pattern
   - Create `tab.routes.test.ts` with Fastify + JWT auth pattern

5. **Run quality checks:**
   - `pnpm lint` → passes
   - `pnpm typecheck` → passes
   - `pnpm test:unit --coverage` → 85% coverage, passes
   - `pnpm test:integration` → all pass

6. **Complete remaining checks:**
   - Security review
   - Migration validation
   - i18n completeness

7. **Push and create PR** with full test plan documenting new test files
