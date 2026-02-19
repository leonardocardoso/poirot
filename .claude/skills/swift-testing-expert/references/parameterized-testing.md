# Parameterized Testing

## When to use this reference

Use this file when you have repeated tests with identical logic and only input changes.

## When to parameterize

- Use one parameterized test when behavior is identical and only input changes.
- Replace copy-pasted tests and in-test `for` loops with `@Test(arguments: ...)`.
- Keep one responsibility per parameterized test to preserve clarity.

### Before -> after

```swift
// Before: multiple near-duplicate tests.
// @Test func freeFeatureA() { ... }
// @Test func freeFeatureB() { ... }

import Testing

enum Feature: CaseIterable {
 case recording, darkMode, networkMonitor
 var isPremium: Bool { self == .networkMonitor }
}

@Test("Free features are not premium", arguments: [Feature.recording, .darkMode])
func freeFeatures(_ feature: Feature) {
 #expect(feature.isPremium == false)
}
```

## Single input collection

- Pass any sendable collection (arrays, ranges, dictionaries, etc.) as arguments.
- Each argument becomes its own independent test case with separate diagnostics.
- Individual failing arguments can be rerun without rerunning all inputs.

### Range-based arguments example

```swift
import Testing

func isValidAge(_ value: Int) -> Bool { (18...120).contains(value) }

@Test(arguments: 18...21)
func validAges(_ age: Int) {
 #expect(isValidAge(age))
}
```

## Multiple inputs

- Swift Testing supports up to two argument collections directly.
- Two collections generate all combinations (cartesian product).
- Control explosion by:
  - reducing argument sets
  - splitting tests by concern
  - pairing related values via `zip(...)`

### Cartesian product example

```swift
import Testing

enum Region { case eu, us }
enum Plan { case free, pro }

func canUseVATInvoice(region: Region, plan: Plan) -> Bool {
 region == .eu && plan == .pro
}

@Test(arguments: [Region.eu, .us], [Plan.free, .pro])
func vatInvoiceAccess(region: Region, plan: Plan) {
 let allowed = canUseVATInvoice(region: region, plan: plan)
 #expect((region == .eu && plan == .pro) == allowed)
}
```

## `zip` for paired scenarios

- Use `zip` when input A must pair with a corresponding input B.
- Prefer `zip` over full combinations when you need aligned tuples only.
- Keep tuples readable and intentional.

### `zip` example

```swift
import Testing

enum Tier { case basic, premium }
func freeTries(for tier: Tier) -> Int { tier == .basic ? 3 : 10 }

@Test(arguments: zip([Tier.basic, .premium], [3, 10]))
func freeTryLimits(_ tier: Tier, expected: Int) {
 #expect(freeTries(for: tier) == expected)
}
```

## Naming and output quality

- Use meaningful parameter labels and display names.
- Ensure argument types are readable in output; provide custom test description if noisy.
- Keep argument lists easy to scan (multi-line formatting is recommended).

## Common pitfalls

- Using in-test `for` loops instead of parameterized arguments (worse diagnostics).
- Passing huge argument sets that explode combinations and slow CI.
- Mixing multiple concerns into one parameterized function.

## Review checklist

- Repetitive tests are consolidated into one parameterized test.
- Arguments reflect domain vocabulary and produce readable failures.
- `zip` is used where pairwise matching is required.
