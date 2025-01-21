---
title: override
description: Override properties in A using B type
shortcut: override
tags:
  - typescript
---

```typescript
export type Override<Source, New> = Omit<Source, keyof New> & New;
```
