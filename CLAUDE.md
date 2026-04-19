# Project Guidelines

## Stack

React
- TailwindCSS
- Zustand/Jotai/React Context
- TanStack Query
- Vite
- Vitest
- Eslint
- Prettier

## Commands

```sh
pnpm dev          # start dev server
pnpm build        # production build
pnpm test         # run tests
pnpm test:watch   # watch mode
pnpm lint         # biome lint
pnpm format       # biome format
```

## Project Structure

```
src/
  pages/     # domain-scoped modules (auth/, cart/, products/…)
  components/   # shared, reusable UI components
  hooks/        # shared custom hooks
  stores/       # stage manager stores - zustand/jotai/context
  services/     # API layer + query options
  lib/          # utilities, helpers, cn()
tests/
  # reflect the stucture of src
```

## General Rules

- `pnpm` only
- kebab-case for all filenames (`user-card.tsx`, `use-auth.ts`)
- No barrel files — no `index.ts` that re-exports siblings
- Always import directly from source (`../../components/button`, not `../../components`)
- Check if the `tsconfig.json` has configuration about the imports like `@/components`

## TypeScript

- No `any` — use `unknown` + type narrowing, only when necessary
- No `as` type assertions — fix the types instead
- Let inference work; only annotate `useState<T>` when the initial value is ambiguous
- Prefer `satisfies` over casting when validating object shapes
- Use `as const` to arrays and objects used as configuration or map
- `type` for component props and local shapes; `interface` for contracts and extensible shapes

## React

- Function declarations for components, not arrow functions
  ```tsx
  // good
  export function UserCard({ name }: UserCardProps) { … }

  // bad
  export const UserCard = ({ name }: UserCardProps) => { … }
  ```
- Never use `React.FC` or `React.FunctionComponent`, prefer `PropsWithChildren<T>` or simple props when don't need a children
- Extend native HTML props via `ComponentProps<"button">` when wrapping elements
- To library elements, always expose as forwardRef
- Composition over prop drilling
- No class components

## TailwindCSS

- Use `cn()` (clsx + tailwind-merge) for all conditional class logic
- Mobile-first: base classes target mobile, `lg:` and up target larger screens
- No arbitrary values (`w-[347px]`) unless truly unavoidable — use design tokens
- No inline `style` props for layout or visual properties
- Class order: layout → spacing → sizing → visual → typography → responsive → conditional
- Design tokens only — no hardcoded colors or sizes outside `tailwind.config`

  ```tsx
  // good
  <div className={cn("flex gap-4 w-full bg-surface text-sm md:gap-6", isActive && "ring-2")} />
  ```


## State manager - Zustand

- One store per domain: `useAuthStore`, `useCartStore`, etc.
- Export granular selectors — never subscribe to the entire store object
  ```ts
  // good
  const user = useAuthStore((s) => s.user)

  // bad
  const { user, logout } = useAuthStore()
  ```
- Wrap all mutations in named actions defined inside the store
- Enable devtools in development:
  ```ts
  import { devtools } from "zustand/middleware"
  export const useAuthStore = create<AuthStore>()(devtools(…, { name: "auth" }))
  ```
- Use `set` for simple updates, `get()` to read current state inside actions
- Do not store server state in Zustand — use React Query for data that comes from an API

## React Query (TanStack Query)

- Always create the query as separated hooks
- Use `queryOptions()` factory for all queries — enables type-safe reuse across components
  ```ts
  // src/services/users.ts
  export const userQueries = {
    detail: (id: string) =>
      queryOptions({
        queryKey: ["users", id],
        queryFn: () => fetchUser(id),
        staleTime: 5 * 60 * 1000,
      }),
  }
  ```
- Query key structure: `[resource, id?, filters?]` — e.g. `["users", userId]`, `["products", { category }]`
- Co-locate query options with the service/API layer in `src/services/`
- Never `useEffect` to fetch data — always `useQuery` or `useInfiniteQuery`
- Set `staleTime` explicitly per query — do not rely on the default `0`
- Mutations use `useMutation` with `onSuccess` invalidation:
  ```ts
  const { mutate } = useMutation({
    mutationFn: updateUser,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["users"] }),
  })
  ```
- Handle loading/error states at the query level — no manual `isLoading` boolean state

## Anti-Patterns

Avoid these at all times:

- `useEffect` for data fetching — use `useQuery`
- `any` or `as` type assertions — fix the types
- `React.FC` — use plain function declarations
- Barrel files (`index.ts` re-exports) — import directly
- `<div onClick={…}>` — use `<button>` or the appropriate semantic element
- Prop drilling past 2 levels — restructure, lift state, or use a store/context
- Storing server state in Zustand — that belongs in React Query cache
- Hardcoded colors or spacing values outside of `tailwind.config`
- `useEffect` for derived state — compute inline or with `useMemo`
