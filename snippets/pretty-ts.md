---
title: pretty-ts
description: Merge types in a beautiful way
shortcut: merge
tags:
  - typescript
---

```typescript
type Merge<T> = { [K in keyof T]: T[K] } & {};
```
