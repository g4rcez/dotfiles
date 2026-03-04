---
description: Review TypeScript code for strong typing, precise inference, and type safety best practices
argument-hint: <file-or-pattern>
---

# TypeScript Master

Review these files for compliance: $ARGUMENTS

Read files, check against rules below. Output concise but comprehensive—sacrifice grammar for brevity. High signal-to-noise.

## Rules

### Type Primitives

- Never use `any` — always replaceable with a constrained generic or precise literal type
- Never use `unknown` as a parameter — use constrained generics instead
- Never use `never` as a workaround — if reached unexpectedly, restructure the types; it signals a type logic flaw
- Prefer `type` over `interface` for all declarations
- Use `satisfies` to validate a value matches a type without widening its literal types

### Functions

- Always `const` arrow functions — never `function` keyword for utilities/helpers
- Generic functions must constrain every type parameter: `<T extends SomeType>` — never bare `<T>`
- Use `infer` inside conditional types to extract and reuse subtypes from generic shapes

```ts
// Constrained generics
const pick = <T extends object, K extends keyof T>(obj: T, keys: K[]): Pick<T, K> => { ... }

// infer for extraction
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never
type Awaited<T> = T extends Promise<infer U> ? U : T
```

### Conditional Types

- Use for type-level if/else branching instead of overloads or `any`
- `T extends Foo ? A : B` distributes over unions by default
- Use `[T] extends [Foo]` to prevent distribution when needed
- Combine `infer` + conditional types to extract shaped subtypes

```ts
type ElementOf<T> = T extends (infer E)[] ? E : never
type IsArray<T> = [T] extends [unknown[]] ? true : false

// Chained conditions
type Flatten<T> =
  T extends (infer E)[]
    ? Flatten<E>
    : T extends Promise<infer U>
      ? Flatten<U>
      : T
```

### Template Literal Types

- Any string manipulation at type level → template literal types
- Combine with `Capitalize<T>`, `Uppercase<T>`, `Lowercase<T>`, `Uncapitalize<T>` intrinsics
- Use `infer` to extract segments from literal string patterns

```ts
type EventName<T extends string> = `on${Capitalize<T>}`
// EventName<"click"> → "onClick"

type PathParam<T extends string> =
  T extends `${string}:${infer Param}/${infer Rest}`
    ? Param | PathParam<`/${Rest}`>
    : T extends `${string}:${infer Param}`
      ? Param
      : never
// PathParam<"/users/:id/posts/:postId"> → "id" | "postId"
```

### Deep Inference

- `as const` on arrays/objects to preserve literal types; `typeof arr[number]` for union of elements
- `satisfies` + `as const` for config objects that must match a type but keep literal inference
- `F.Narrow` from `ts-toolbelt` for deep literal inference in generic functions

```ts
import type { F } from "ts-toolbelt"

// Without F.Narrow — T infers as string[], literals widened
const useRoutes = <T extends string[]>(routes: T) => routes

// With F.Narrow — literals preserved
const useRoutes = <T extends string[]>(routes: F.Narrow<T>) => routes

useRoutes(["/home", "/about"]) // T = ["/home", "/about"], not string[]

// satisfies + as const
const config = {
  env: "production",
  port: 3000,
} as const satisfies { env: "development" | "production"; port: number }
```

### Error Diagnosis

- Read errors bottom-up — root cause is at the bottom of the chain
- `Type 'X' is not assignable to 'Y'` → missing props, incompatible types, or literal vs widened — check `as const`
- `Property 'X' does not exist on type 'Y'` → wrong type; add `in` / `typeof` type guard
- `Type 'X' cannot be used to index type 'Y'` → constrain with `K extends keyof T`
- Generic constraint errors → add `T extends SomeType`
- Break complex chains into intermediate type aliases to isolate mismatches
- `// @ts-expect-error` to confirm expected errors (unused directive = valid code)

### Anti-patterns

- `any` — never acceptable
- `unknown` parameter — use constrained generic instead
- `never` as a workaround — restructure types
- Bare unconstrained `<T>` generic
- `interface` — use `type`
- `function` keyword for utilities — use `const` arrow
- Unguarded index access without `K extends keyof T`
- String branching without template literal types
- `as SomeType` assertion to silence errors — fix the types
- Mutable arrays when `as const` readonly would preserve literals

## Output Format

Group by file. Use `file:line` format (VS Code clickable). Terse findings.

```text
## src/utils.ts

src/utils.ts:12 - `any` return type → infer from generic
src/utils.ts:34 - bare `<T>` generic → constrain with `T extends object`
src/utils.ts:58 - `interface Foo` → `type Foo`
src/utils.ts:71 - `function helper(` → `const helper = (`

## src/routes.ts

src/routes.ts:5 - string literal widened → add `as const`
src/routes.ts:19 - `as RouteConfig` assertion → use `satisfies`

## src/api.ts

✓ pass
```

State issue + location. Skip explanation unless fix non-obvious. No preamble.
