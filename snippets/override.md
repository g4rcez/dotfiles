---
title: override
tags:
  - typescript
description: Override properties in A using B type
shortcut: override
---

```typescript
export type Override<Source, New> = Omit<Source, keyof New> & New;
```
