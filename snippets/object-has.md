---
title: object-has
description: Check if key exists in object
shortcut: has
tags:
  - typescript
  - javascript
---

```typescript
export const has = <T extends {}, K extends keyof T>(o: T, k: K): k is K => Object.prototype.hasOwnProperty.call(o, k);
```
