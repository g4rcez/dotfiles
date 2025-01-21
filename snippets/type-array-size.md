---
title: type-array-size
description: Create a utility type that limit the size of array
shortcut: arrs
tags:
  - typescript
  - hacks
---

```typescript
type ArraySize<T, Size extends number, A extends T[] = []> = A["length"] extends Size ? A : ArraySize<T, Size, [...A, T]>;
```
