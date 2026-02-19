---
name: env-variable
description: Add environment variables to the Ignio monorepo consistently across all configuration files.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, TodoWrite
---

# Environment Variable Skill

Add new environment variables to the Ignio monorepo following the established patterns and ensuring consistency across all configuration files.

## When to Use

Use this skill when:
- User wants to add a new environment variable
- User mentions "add env", "new env var", "environment variable"
- User needs to add configuration for a new feature
- User wants to add a feature flag

## Files to Update

| File | Purpose | Always Required |
|------|---------|-----------------|
| `packages/config/src/env.ts` | Variable definition, validation, accessor functions | Yes |
| `packages/config/src/environments.ts` | Feature flag defaults per environment | Only for feature flags |
| `.env.example` | Documentation for local development | Yes |
| `.env.staging.example` | Staging environment template | Yes |
| `.env.production.example` | Production environment template | Yes |
| `scripts/setup.sh` | Interactive setup wizard | **Yes** if `required: true` |

> **IMPORTANT:** If a variable has `required: true` in env.ts, it **MUST** be added to `scripts/setup.sh`. The setup wizard is the primary way users configure their environment, and missing required variables will cause the application to fail on startup.

## Environment Variable Categories

When adding a variable to `packages/config/src/env.ts`, use one of these categories:

| Category | Purpose |
|----------|---------|
| Core | Always required (DATABASE_URL, JWT_SECRET, REDIS_URL) |
| Localization | Language and currency settings |
| WhatsApp | WhatsApp Business API integration |
| Storage | S3/R2 object storage configuration |
| Google OAuth | Calendar integration OAuth |
| Email Auth | Gmail API for authentication |
| LLM | AI provider configuration |
| Dashboard | Web dashboard configuration |

## Patterns

### 1. Simple Optional Variable

```typescript
// In packages/config/src/env.ts - ENV_VARS array
{
  name: 'VARIABLE_NAME',
  required: false,
  description: 'Clear description of what this variable does',
  category: 'CategoryName',
},
```

### 2. Required Variable

**IMPORTANT:** Required variables (`required: true`) **MUST** also be added to `scripts/setup.sh` so users can configure them during initial setup. Missing required variables will cause application startup failures.

```typescript
{
  name: 'VARIABLE_NAME',
  required: true,
  description: 'Clear description of what this variable does',
  category: 'Core', // Required vars usually go in Core
},
```

After adding to env.ts, also add to `scripts/setup.sh` (see "Setup Wizard Integration" section below).

### 3. Feature Flag Variable

```typescript
// 1. In packages/config/src/env.ts - ENV_VARS array
{
  name: 'ENABLE_FEATURE_NAME',
  required: false,
  description: 'Enable/disable feature (true/false)',
  category: 'Feature',
},

// 2. In packages/config/src/environments.ts - featureDefaults object
ENABLE_FEATURE_NAME: {
  local: true,      // Usually enabled for development
  staging: true,    // Usually enabled for testing
  production: false, // Usually disabled until ready
},

// 3. Accessor function in packages/config/src/env.ts
export function isFeatureEnabled(): boolean {
  return getOptionalEnvBoolean('ENABLE_FEATURE_NAME', false);
}
```

### 4. Variable with Accessor Function

```typescript
// Add accessor function after the validation section in packages/config/src/env.ts

/**
 * Gets the variable value from environment.
 * Falls back to default if not set.
 *
 * @returns The variable value
 */
export function getVariableName(): string {
  return getOptionalEnv('VARIABLE_NAME', 'default-value');
}

// For numbers:
export function getVariableCount(): number {
  return getOptionalEnvNumber('VARIABLE_COUNT', 10);
}

// For booleans:
export function isVariableEnabled(): boolean {
  return getOptionalEnvBoolean('VARIABLE_ENABLED', false);
}
```

### 5. Feature Group (All-or-Nothing)

When multiple variables are interdependent:

```typescript
// In packages/config/src/env.ts - FEATURE_GROUPS object
'Feature Name': [
  'FEATURE_VAR_1',
  'FEATURE_VAR_2',
  'FEATURE_VAR_3',
],
```

## .env.example Format

Use consistent formatting with clear sections:

```bash
# -----------------------------------------------------------------------------
# Feature Name
# -----------------------------------------------------------------------------
# Clear description of this feature and when to use it.
# Additional context or links to documentation.
VARIABLE_NAME=default-value
ANOTHER_VARIABLE=

# Optional: More detailed variable with example
# Format: protocol://host:port/path
DATABASE_URL=postgresql://user:pass@localhost:5432/db
```

## Step-by-Step Process

### Adding a Simple Variable

1. **Read current files** to understand existing patterns
2. **Add to ENV_VARS** in `packages/config/src/env.ts`
3. **Add accessor function** if the variable will be used programmatically
4. **Update .env.example** with documentation and default value
5. **Verify** the addition doesn't break the build

### Adding a Feature Flag

1. **Add to ENV_VARS** in `packages/config/src/env.ts`
2. **Add to featureDefaults** in `packages/config/src/environments.ts`
3. **Add accessor function** like `isFeatureEnabled()`
4. **Update .env.example** with documentation
5. **Export from index** if the accessor should be publicly available

## Validation Rules

The env validation system (`validateEnv()`) checks:

- **Required variables**: Must be present and non-empty
- **Feature groups**: If any variable in group is set, all should be set (warning)
- **Production security**: JWT_SECRET must be 32+ chars and not default
- **Localization**: DEFAULT_LANGUAGE must be in SUPPORTED_LOCALES
- **Currency**: DEFAULT_CURRENCY must be in SUPPORTED_CURRENCIES

## Example Usage

**User:** "Add an environment variable for the OpenRouter API key"

**Steps:**
1. Add to `packages/config/src/env.ts`:
```typescript
{
  name: 'OPENROUTER_API_KEY',
  required: false,
  description: 'OpenRouter API key for LLM routing',
  category: 'LLM',
},
```

2. Add accessor function:
```typescript
export function getOpenRouterApiKey(): string | undefined {
  return process.env['OPENROUTER_API_KEY'];
}
```

3. Update `.env.example`:
```bash
# OpenRouter API (alternative LLM routing)
# Get key from: https://openrouter.ai/
OPENROUTER_API_KEY=
```

4. Export from `packages/config/src/index.ts` if needed.

## Setup Wizard Integration

The `scripts/setup.sh` is an interactive setup wizard that helps users configure their environment. When adding user-facing variables that should be configurable during setup, update this script.

### Setup Wizard Sections

| Section | Variables | When to Add |
|---------|-----------|-------------|
| Essential Configuration | PORT, LOG_LEVEL, DATABASE_URL, REDIS_URL, JWT_SECRET, DEFAULT_LANGUAGE, DEFAULT_CURRENCY | Core variables needed to run |
| LLM Configuration | OPENAI_API_KEY, GOOGLE_CLOUD_CREDENTIALS | AI provider keys |
| WhatsApp Configuration | WHATSAPP_* variables | WhatsApp integration |
| R2 Storage Configuration | R2_*, S3_* variables | Object storage |
| Google OAuth Configuration | GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET | Calendar/OAuth |

### Adding a Variable to Setup Wizard

1. **Identify the section** where the variable belongs
2. **Add prompting code** using existing helpers:

```bash
# For simple values with defaults
local current_value new_value
current_value=$(get_env_value "VARIABLE_NAME" "$ENV_FILE")
new_value=$(prompt_env_value "VARIABLE_NAME" "Description of the variable" "${current_value:-default}")
update_env_value "VARIABLE_NAME" "$new_value" "$ENV_FILE"

# For sensitive values (API keys, secrets)
local current_secret new_secret
current_secret=$(get_env_value "SECRET_NAME" "$ENV_FILE")
new_secret=$(prompt_sensitive_value "SECRET_NAME" "Description" "$current_secret")
update_env_value "SECRET_NAME" "$new_secret" "$ENV_FILE"
```

3. **Add validation** if needed (see `validate_database_url`, `validate_redis_url`, `validate_jwt_secret` for examples)

### When to Update Setup Wizard

- **DO update** for: API keys, connection URLs, ports, feature flags users need to configure
- **DON'T update** for: Internal configuration, derived values, environment-specific defaults

### Helper Functions Available

| Function | Purpose |
|----------|---------|
| `prompt_env_value` | Prompt for value with default, auto-detects secrets |
| `prompt_sensitive_value` | Prompt for secrets, hides current value |
| `update_env_value` | Update or add value in .env file |
| `get_env_value` | Read current value from .env file |
| `validate_database_url` | Validate PostgreSQL URL format |
| `validate_redis_url` | Validate Redis URL format |
| `validate_jwt_secret` | Validate JWT secret length |

## Common Mistakes to Avoid

- **Don't** add the same variable to multiple categories
- **Don't** mark a feature flag as required
- **Don't** forget to add to .env.example
- **Don't** use different variable names between files
- **Don't** forget to update setup.sh for user-configurable variables
- **Don't** mark a variable as `required: true` without adding it to `scripts/setup.sh` - this will cause startup failures for users who run the setup wizard
- **Do** use SCREAMING_SNAKE_CASE for variable names
- **Do** provide clear, actionable descriptions
- **Do** include setup instructions in .env.example comments
- **Do** use `prompt_sensitive_value` for API keys and secrets
- **Do** ALWAYS add required variables to `scripts/setup.sh`
