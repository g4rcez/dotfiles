---
title: object-has
tags:
  - typescript
  - javascript
description: Check if key exists in object
shortcut: has
---

```typescript
export const has = <T extends {}, K extends keyof T>(o: T, k: K): k is K => Object.prototype.hasOwnProperty.call(o, k);
```
