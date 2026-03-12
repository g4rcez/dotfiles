---
name: refactor
description: 'Surgical code refactoring to improve maintainability without changing behavior. Covers extracting functions, renaming variables, breaking down god functions, improving type safety, eliminating code smells, and applying design patterns. Less drastic than repo-rebuilder; use for gradual improvements.'
---

## When Invoked

1. Read all files to be modified — never edit from memory
2. Identify specific code smells present (see catalogue)
3. Apply one refactoring at a time — one smell, one commit
4. Never mix refactoring with feature changes in the same pass
5. Verify behavior is preserved after each change (run tests)

## When to Use

When code is hard to modify, functions are too large, duplication exists, or user asks to "clean up", "refactor", "improve readability".

---

## Code Smells

### 1. Long Function

```diff
- async function processOrder(id) { /* 200 lines: fetch, validate, price, notify */ }

+ async function processOrder(id) {
+   const order = await fetchOrder(id);
+   validateOrder(order);
+   return createShipment(order, calculatePricing(order));
+ }
```

### 2. Duplicated Code

```diff
- // discount logic copy-pasted in UserService and OrderProcessor
- if (membership === 'gold') return total * 0.2;

+ const RATES = { gold: 0.2, silver: 0.1 };   // extract shared logic
+ const rate = RATES[membership] ?? 0;
```

### 3. Large Class

```diff
- class UserManager {
-   createUser() {} sendEmail() {} handlePayment() {} generateReport() {}
- }

+ class UserService   { create() {} update() {} delete() {} }
+ class EmailService  { send() {} }
+ class PaymentService { process() {} }
```

### 4. Long Parameter List

```diff
- createUser(email, password, name, age, address, city, country, phone)

+ interface UserData { email: string; password: string; name: string; address?: Address }
+ createUser(data: UserData)
```

### 5. Feature Envy

```diff
- class Order {
-   discount(user) { if (user.membership === 'gold') return this.total * 0.2; }
- }

+ class User  { discountRate() { return this.membership === 'gold' ? 0.2 : 0.1; } }
+ class Order { discount(user) { return this.total * user.discountRate(); } }
```

### 6. Primitive Obsession

```diff
- sendEmail('user@example.com')  // raw string, no validation

+ class Email {
+   static create(v: string) { if (!isValid(v)) throw Error('Invalid email'); return new Email(v); }
+ }
```

### 7. Magic Numbers / Strings

```diff
- if (user.status === 2) setTimeout(cb, 86400000);

+ const UserStatus = { INACTIVE: 2 } as const;
+ const ONE_DAY_MS = 24 * 60 * 60 * 1000;
+ if (user.status === UserStatus.INACTIVE) setTimeout(cb, ONE_DAY_MS);
```

### 8. Nested Conditionals

```diff
- if (order) { if (order.user) { if (order.user.isActive) { return process(order); } } }

+ if (!order)              return { error: 'No order' };
+ if (!order.user)         return { error: 'No user' };
+ if (!order.user.isActive) return { error: 'Inactive' };
+ return process(order);
```

### 9. Dead Code

```diff
- function oldImpl() { /* unused */ }
- const DEPRECATED_VALUE = 5;
- // function commentedOut() { ... }

+ // Delete it — git history preserves it
```

### 10. Inappropriate Intimacy

```diff
- order.user.profile.address.street  // deep chain, breaks encapsulation

+ order.getShippingAddress()  // ask, don't tell
```

---

## Safe Refactoring Process

1. Ensure tests exist; commit current state
2. Pick one smell → make smallest change → run tests → commit
3. Repeat until done

---

## Design Patterns

### Strategy — replace branching on type with polymorphism

```diff
- if (method === 'express')   return total > 100 ? 9.99 : 14.99;
- if (method === 'overnight') return 29.99;
+ interface ShippingStrategy { calculate(order: Order): number }
+ class ExpressShipping   implements ShippingStrategy { calculate(o) { return o.total > 100 ? 9.99 : 14.99; } }
+ class OvernightShipping implements ShippingStrategy { calculate()  { return 29.99; } }
+ calculateShipping(order, strategy)  // caller injects strategy
```

### Null Object — eliminate repeated null checks

```diff
- if (user?.profile?.avatar) showAvatar(user.profile.avatar); else showAvatar(DEFAULT);
+ class GuestUser { get avatar() { return DEFAULT_AVATAR; } }
+ showAvatar(user.avatar)  // always safe
```

### Observer — decouple producers from consumers

```diff
- // save() calls sendEmail(), updateInventory(), logAudit() directly
+ eventBus.emit('order.saved', order);
+ // EmailHandler, InventoryHandler, AuditHandler subscribe independently
```

### Introduce Parameter Object — tame long parameter lists

```diff
- createReport(start, end, userId, format, includeArchived, maxRows)
+ createReport({ dateRange: { start, end }, userId, format, options: { includeArchived, maxRows } })
```

---

## Anti-patterns

- Rename only when unambiguously clearer; extract only when naming a concept
- Add complexity only when it removes more; don't introduce patterns for their own sake
- Test before refactoring; don't delete feature-flag-gated "dead code"
- Don't touch working code without clear benefit; one smell at a time

---

## Checklist

- [ ] Functions < 50 lines · no duplication · descriptive names · no magic numbers
- [ ] Dead code removed · co-located · types on public APIs · no `any`
- [ ] Refactored code is tested · all tests pass

---

## Operations

- Extract Method — fragment deserves a name
- Extract Class — multiple responsibilities
- Extract Interface — callers depend on implementation
- Inline Method — indirection adds no clarity
- Pull Up/Push Down — behavior belongs to super/subclass
- Rename — current name is misleading
- Introduce Parameter Object — 3+ related params
- Replace Conditional with Polymorphism — switch/if grows with new types
- Replace Magic Number with Constant — value has domain meaning
- Replace Nested Conditional with Guard Clauses — 2+ nesting levels
- Introduce Null Object — repeated null checks
- Replace Inheritance with Delegation — subclass uses only part of parent
