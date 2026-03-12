---
description: Review TypeScript code for strong typing, precise inference, and type safety best practices
argument-hint: <file-or-pattern>
---

# TypeScript Master

Review these files for compliance: $ARGUMENTS

Read files, check against rules below. Output concise but comprehensive—sacrifice grammar for brevity. High signal-to-noise.

## Rules

### Type Primitives

- Never `any` — use constrained generics or precise literal types
- Never `unknown` as parameter — use constrained generics
- Never `never` as workaround — restructure the types
- `type` over `interface` for all declarations
- `satisfies` to validate a value without widening its literal types

### Functions

- Always `const` arrow functions — never `function` keyword
- Constrain every type parameter: `<T extends SomeType>` — never bare `<T>`
- Use `infer` inside conditional types to extract subtypes from generic shapes

```ts
// Constrained generics
const pick = <T extends object, K extends keyof T>(obj: T, keys: K[]): Pick<T, K> => { ... }

// infer for extraction
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never
type Awaited<T> = T extends Promise<infer U> ? U : T
```

### Conditional Types

- Type-level if/else branching instead of overloads or `any`
- `T extends Foo ? A : B` distributes over unions by default; use `[T] extends [Foo]` to prevent
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

- String manipulation at type level → template literal types; use `Capitalize<T>`, `Uppercase<T>`, etc.
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

- Read errors bottom-up — root cause is at the bottom
- `Type 'X' is not assignable to 'Y'` → missing props, incompatible types, or literal vs widened (`as const`)
- `Property 'X' does not exist on 'Y'` → add `in` / `typeof` type guard
- `Type 'X' cannot index 'Y'` → constrain with `K extends keyof T`
- Generic constraint errors → add `T extends SomeType`
- Break complex chains into intermediate aliases to isolate mismatches
- `// @ts-expect-error` to confirm expected errors (unused directive = valid code)

### Anti-patterns

- `any` · `unknown` parameter · `never` as workaround
- Bare `<T>` generic · `interface` · `function` keyword
- Unguarded index access without `K extends keyof T`
- String branching without template literal types
- `as SomeType` to silence errors · mutable arrays where `as const` preserves literals

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
