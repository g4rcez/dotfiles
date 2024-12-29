---
title: pretty-ts
tags:
  - typescript
description: Merge types in a beautiful way
shortcut: tsmerge
---

```typescript
type Merge<T> = { [K in keyof T]: T[K] } & {}
```