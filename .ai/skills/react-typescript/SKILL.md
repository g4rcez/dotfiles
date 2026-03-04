---
name: react-typescript-frontend
description: >
  Comprehensive guide for building React + TypeScript frontend applications with community best practices.
  Use this skill whenever the user asks to create, refactor, or review React components, hooks, pages,
  or any frontend code involving React and TypeScript. Also trigger when the user mentions: component architecture,
  React patterns, TypeScript typing for React, state management setup, frontend project structure,
  TailwindCSS component styling, frontend testing, accessibility in React, or asks to scaffold a new feature.
  This skill adapts to the project's existing conventions by reading config files before applying rules.
  Even if the user doesn't explicitly say "React" — if they mention components, hooks, pages, forms, modals,
  or frontend features, use this skill.
---

# React + TypeScript Frontend Skill

A guide for writing production-grade React + TypeScript code that follows community best practices. This skill is adaptive — it reads the project's configuration before applying rules, so it works across different setups and conventions.

## First Things First: Read the Project

Before writing any code, understand the project you're working in. This is non-negotiable — the project's existing conventions always take precedence over the defaults in this skill.

### Step 1: Check for project-level instructions

Look for these files in the project root (in order of priority):

```bash
# Check for project-specific AI instructions
cat CLAUDE.md 2>/dev/null || cat .cursorrules 2>/dev/null || cat .github/copilot-instructions.md 2>/dev/null
```

If any of these exist, their rules override this skill's defaults. Read them fully before proceeding.

### Step 2: Understand the project's stack

```bash
# Read package.json to detect libraries, test runner, and state management
cat package.json | head -80

# Check TypeScript config
cat tsconfig.json 2>/dev/null || cat tsconfig.app.json 2>/dev/null

# Check Tailwind config for design tokens
cat tailwind.config.ts 2>/dev/null || cat tailwind.config.js 2>/dev/null

# Check path aliases
grep -r "paths" tsconfig.json 2>/dev/null
```

From `package.json`, detect:
- **State management**: Zustand, Jotai, Redux/RTK, use-typed-reducer, or others
- **Server state**: TanStack Query (@tanstack/react-query)
- **Test runner**: Vitest or Jest (check `devDependencies`)
- **Routing**: TanStack Router, React Router, Next.js file-based routing
- **Form handling**: React Hook Form, Formik, or custom
- **Utility libraries**: clsx, cn, tailwind-merge, cva

Use whatever the project already has. Never introduce a new state management library or test runner unless explicitly asked.

### Step 3: Understand the existing file structure

```bash
# Get a feel for the project layout
find src -type f -name "*.tsx" -o -name "*.ts" | head -30
ls -la src/
```

Adapt to the existing patterns. If the project uses `features/` folders, follow that. If it uses `pages/` with co-located components, follow that.

---

## Component Architecture

### Function Declarations Over Arrow Functions for Components

Use plain function declarations for components. They hoist, they're clear, and they don't need `React.FC`.

```typescript
// ✅ Good
function UserProfile({ name, email }: UserProfileProps) {
  return (
    <section>
      <h2>{name}</h2>
      <p>{email}</p>
    </section>
  );
}

export default UserProfile;

// ❌ Avoid: React.FC adds implicit children and extra noise
const UserProfile: React.FC<UserProfileProps> = ({ name, email }) => { ... }

// ❌ Avoid: arrow function component at top level
const UserProfile = ({ name, email }: UserProfileProps) => { ... }
```

Arrow functions are fine for inline callbacks, event handlers, and small utility functions — just not as the primary component declaration.

### Props: Use `type` for Props, `interface` for Contracts

```typescript
// Props for a specific component — use type
type ButtonProps = {
  variant?: "primary" | "secondary" | "ghost";
  size?: "sm" | "md" | "lg";
  isLoading?: boolean;
} & React.ComponentPropsWithoutRef<"button">;

// Contracts that may be extended — use interface
interface Repository {
  findById(id: string): Promise<Entity>;
  create(data: CreateDTO): Promise<Entity>;
}
```

Extend native HTML props to keep components flexible:

```typescript
// ✅ Extends native button — users can pass onClick, disabled, etc.
type ButtonProps = {
  variant?: "primary" | "secondary";
} & React.ComponentPropsWithoutRef<"button">;

// ✅ For components that accept refs
type InputProps = {
  label: string;
  error?: string;
} & React.ComponentPropsWithRef<"input">;
```

### Composition Over Prop Drilling

When data needs to travel through multiple layers, restructure the component tree instead of passing props through intermediaries. This is the most important architectural principle in React.

```typescript
// ❌ Prop drilling — Header doesn't use `user`, just forwards it
function App() {
  const user = useUser();
  return <Header user={user} />;
}

function Header({ user }: { user: User }) {
  return <Avatar user={user} />;
}

// ✅ Composition — pass the consuming component directly
function App() {
  const user = useUser();
  return <Header avatar={<Avatar user={user} />} />;
}

function Header({ avatar }: { avatar: React.ReactNode }) {
  return <nav>{avatar}</nav>;
}
```

For compound components (like a Card with Header, Body, Footer), use composition through children and named sub-components:

```typescript
function Card({ children, className }: CardProps) {
  return <div className={cn("rounded-lg border bg-card p-4", className)}>{children}</div>;
}

function CardHeader({ children }: { children: React.ReactNode }) {
  return <div className="mb-4 border-b pb-2">{children}</div>;
}

Card.Header = CardHeader;
// ... Card.Body, Card.Footer
```

### forwardRef — Only for Reusable/Library Components

Use `forwardRef` when building reusable components that wrap native elements (inputs, buttons, etc.) that consumers might need to attach a ref to. Don't use it on every component.

```typescript
import { forwardRef } from "react";

const Input = forwardRef<HTMLInputElement, InputProps>(
  function Input({ label, error, className, ...props }, ref) {
    return (
      <div>
        <label className="text-sm font-medium">{label}</label>
        <input
          ref={ref}
          className={cn(
            "w-full rounded-md border px-3 py-2",
            error && "border-red-500",
            className
          )}
          {...props}
        />
        {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
      </div>
    );
  }
);
```

---

## TypeScript Best Practices

For detailed TypeScript patterns (generics, utility types, discriminated unions, type narrowing), see `references/typescript-patterns.md`.

### Core Rules

1. **Never use `any`**. Use `unknown` when the type is truly unknown, then narrow it.
2. **Avoid type assertions** (`as`). If you need to assert, it's a sign the types are wrong. Fix the types instead.
3. **Let TypeScript infer** when it's obvious. Don't annotate what the compiler already knows.
4. **Use `satisfies`** to validate a value matches a type without widening it.

```typescript
// ✅ satisfies — validates without losing literal types
const config = {
  theme: "dark",
  locale: "pt-BR",
} satisfies AppConfig;

// ✅ Inference — no need to annotate
const [count, setCount] = useState(0);

// ✅ Annotate when inference can't help
const [user, setUser] = useState<User | null>(null);

// ❌ Never
const data = response as any;
const value: any = getData();
```

---

## State Management

### The Decision Tree

Don't reach for global state by default. Most state is local.

1. **UI state** (toggles, form inputs, local loading) → `useState` / `useReducer` / `use-typed-reducer`
2. **Server state** (API data, cache) → TanStack Query (or whatever the project uses)
3. **Shared client state** (theme, auth, cart) → Use whatever the project has installed (Zustand, Jotai, Redux/RTK)
4. **Avoid React Context for frequently changing values** — it re-renders all consumers on every change

Always check `package.json` first. Use what's already there. If the project has Zustand, use Zustand. If it has Jotai, use Jotai. Never introduce a new state library without explicit instruction.

### Server State with TanStack Query

When the project uses TanStack Query, follow these patterns:

```typescript
// ✅ Use queryOptions for type-safe, reusable query configuration
import { queryOptions, useQuery } from "@tanstack/react-query";

const userQueryOptions = (userId: string) =>
  queryOptions({
    queryKey: ["users", userId],
    queryFn: () => fetchUser(userId),
    staleTime: 5 * 60 * 1000,
  });

function UserProfile({ userId }: { userId: string }) {
  const { data, isPending, error } = useQuery(userQueryOptions(userId));

  if (isPending) return <Skeleton />;
  if (error) return <ErrorMessage error={error} />;

  return <ProfileCard user={data} />;
}
```

Never use `useEffect` to fetch data. That's what TanStack Query (or your server state library) is for.

---

## File Structure & Naming

### Naming: kebab-case Everything

Files, folders, everything uses kebab-case. This is the standard in frontend and avoids case-sensitivity issues across operating systems.

```
src/
  components/
    user-avatar/
      user-avatar.tsx
      user-avatar.test.tsx
      user-avatar.types.ts        # only if types are complex enough to separate
  features/
    checkout/
      checkout-page.tsx
      checkout.hooks.ts
      checkout.utils.ts
      checkout.types.ts
      checkout.services.ts
  hooks/
    use-debounce.ts               # generic hooks at top-level
    use-media-query.ts
  utils/
    format-currency.ts            # generic utils at top-level
    date.utils.ts
  types/
    api.types.ts                  # generic/shared types at top-level
```

### Organization Rules

- **Library/reusable components** get their own folder: `button/button.tsx`, `button/button.test.tsx`
- **Feature-specific code** lives inside the feature: `features/checkout/checkout.hooks.ts`
- **Generic/shared utilities** go in top-level folders: `hooks/`, `utils/`, `types/`, `services/`
- **Naming pattern for feature files**: `feature-name.{hooks,utils,types,services}.ts`
- **No barrel files** (`index.ts` re-exports). They break tree-shaking and make import tracing harder. Import directly from the source file.
- **Pages and routes** follow whatever pattern the routing library uses. Analyze the existing structure.

```typescript
// ✅ Direct imports — clear, traceable, tree-shakeable
import { Button } from "@/components/button/button";
import { useDebounce } from "@/hooks/use-debounce";
import { formatCurrency } from "@/utils/format-currency";

// ❌ Barrel imports — breaks tree-shaking, obscures origin
import { Button } from "@/components";
import { useDebounce } from "@/hooks";
```

### Analyze Config for Path Aliases

Check `tsconfig.json` for path aliases before importing:

```bash
grep -A 5 '"paths"' tsconfig.json 2>/dev/null
```

Use whatever alias the project defines (`@/`, `~/`, `#/`, etc.).

---

## Styling with TailwindCSS

### Core Principles

- **Mobile-first**: base classes are for mobile, use breakpoint prefixes to scale up
- **Use design tokens**: use colors, spacing, and sizes from `tailwind.config` — never hardcode values
- **No arbitrary values** unless absolutely necessary: `p-4` not `p-[13px]`
- **Use `cn()` or `clsx()`** for conditional classes (check what the project uses)

```typescript
// ✅ Mobile-first responsive, design tokens, clean ordering
<div className={cn(
  "flex flex-col gap-4 p-4",           // layout
  "rounded-lg border bg-card",          // visual
  "text-sm text-foreground",            // typography
  "md:flex-row md:gap-6 md:p-6",       // responsive
  isActive && "ring-2 ring-primary",    // conditional
  className                             // allow overrides
)} />

// ❌ Arbitrary values, hardcoded colors, inline styles
<div className="p-[13px] bg-[#FF5733]" style={{ marginTop: 10 }} />
```

### Class Ordering Convention

Follow this order for readability: **layout → spacing → sizing → visual → typography → effects → responsive → conditional**

---

## Testing

### Detect the Stack First

```bash
# What test runner?
grep -E "vitest|jest" package.json | head -5

# What testing utilities?
grep -E "@testing-library" package.json | head -5
```

### Core Testing Principles

Regardless of the test runner (Vitest or Jest), follow these principles:

1. **Test behavior, not implementation** — interact with the component like a user would
2. **Use accessible queries** — `getByRole`, `getByLabelText`, `getByText` over `getByTestId`
3. **One behavior per test** — each test should verify a single aspect
4. **Mock external dependencies** — API calls, third-party libraries, timers
5. **Co-locate tests** — `button.test.tsx` lives next to `button.tsx`

```typescript
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

describe("LoginForm", () => {
  it("submits the form with valid credentials", async () => {
    const onSubmit = vi.fn(); // or jest.fn()
    render(<LoginForm onSubmit={onSubmit} />);

    await userEvent.type(screen.getByLabelText(/email/i), "user@test.com");
    await userEvent.type(screen.getByLabelText(/password/i), "secret123");
    await userEvent.click(screen.getByRole("button", { name: /sign in/i }));

    expect(onSubmit).toHaveBeenCalledWith({
      email: "user@test.com",
      password: "secret123",
    });
  });

  it("shows validation error for empty email", async () => {
    render(<LoginForm onSubmit={vi.fn()} />);

    await userEvent.click(screen.getByRole("button", { name: /sign in/i }));

    expect(screen.getByText(/email is required/i)).toBeInTheDocument();
  });
});
```

### What to Test

- User interactions (clicks, form submissions, keyboard navigation)
- Conditional rendering (loading, error, empty states)
- Accessibility (focus management, ARIA attributes, keyboard nav)
- Edge cases (empty data, error responses, boundary values)

### What NOT to Test

- Implementation details (internal state, private methods)
- Styles or CSS class names
- Third-party library internals

---

## Accessibility (a11y)

Accessibility is not optional. Build it in from the start.

### Every Component Should

- Use **semantic HTML** (`button` not `div onClick`, `nav` not `div`, `main` not `div`)
- Have **proper focus management** (visible focus styles, logical tab order)
- Include **ARIA attributes** where semantic HTML isn't enough
- Support **keyboard navigation** (Enter, Escape, Arrow keys where expected)
- Meet **color contrast** standards (4.5:1 for normal text, 3:1 for large text)
- Provide **screen reader context** via labels, descriptions, and live regions

```typescript
// ✅ Semantic, accessible, keyboard-navigable
<button
  type="button"
  aria-label="Close dialog"
  aria-pressed={isOpen}
  onClick={onClose}
  onKeyDown={(e) => e.key === "Escape" && onClose()}
  className="focus-visible:ring-2 focus-visible:ring-primary"
>
  <XIcon aria-hidden="true" />
</button>

// ❌ Div pretending to be a button — no keyboard support, no role
<div onClick={onClose} className="cursor-pointer">✕</div>
```

### Interactive Elements Checklist

- All clickable things must be `<button>` or `<a>` (never `<div onClick>`)
- Form inputs need associated `<label>` elements
- Images need `alt` text (decorative images: `alt=""` + `aria-hidden="true"`)
- Modals need focus trapping and Escape-to-close
- Toast/notifications need `role="alert"` or `aria-live="polite"`
- Touch targets should be at least 44x44px on mobile

---

## Anti-Patterns — Quick Reference

These are actively prevented by this skill. Each is covered in detail above, but here's the checklist:

1. **`useEffect` for data fetching** → Use TanStack Query or the project's server state lib
2. **`any` type / type assertions (`as`)** → Use `unknown` + type guards, or fix the types
3. **`React.FC`** → Plain function declarations
4. **Prop drilling** → Composition (children, render props, compound components) before Context/state libs
5. **Barrel files** (`index.ts` re-exports) → Direct imports from source files
6. **Inline styles** → TailwindCSS utilities
7. **`<div onClick>`** → Semantic HTML (`<button>`, `<a>`)
8. **Hardcoded color/spacing values** → Design tokens from tailwind config
