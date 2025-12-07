# TypeScript - Code Styles and Guidelines

## Version Requirements

- Target TypeScript version: **5.0+**
- Use modern TypeScript features including:
  - Type parameter constraints with `const` type parameters
  - Decorators (Stage 3)
  - Enhanced template literal types
  - Improved type inference

## TypeScript Configuration

### Always Use Strict Mode

Your `tsconfig.json` should include these strict settings:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true
  }
}
```

## Type System Best Practices

### Avoid Type Assertions

Type assertions (`as` keyword) should be **avoided** unless absolutely necessary. They bypass TypeScript's type checking and can lead to runtime errors.

#### ❌ Bad: Using Type Assertions

```typescript
// DON'T: Overriding type system
const user = JSON.parse(userJson) as User;

// DON'T: Asserting when type is unclear
const element = document.getElementById("myId") as HTMLInputElement;

// DON'T: Using double assertion
const value = unknownValue as any as string;

// DON'T: Non-null assertion when not guaranteed
function processUser(user?: User) {
  console.log(user!.name); // Dangerous!
}
```

#### ✅ Good: Type-Safe Alternatives

```typescript
// DO: Use type guards and validation
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === "object" &&
    obj !== null &&
    "id" in obj &&
    "name" in obj &&
    typeof (obj as any).id === "string" &&
    typeof (obj as any).name === "string"
  );
}

const parsed: unknown = JSON.parse(userJson);
if (isUser(parsed)) {
  // Now TypeScript knows it's a User
  console.log(parsed.name);
}

// DO: Use type narrowing with proper checks
const element = document.getElementById("myId");
if (element instanceof HTMLInputElement) {
  console.log(element.value);
}

// DO: Handle null/undefined explicitly
function processUser(user?: User) {
  if (!user) {
    throw new Error("User is required");
  }
  console.log(user.name); // Safe!
}

// DO: Use optional chaining
function getUserName(user?: User): string | undefined {
  return user?.name;
}
```

### When Type Assertions Are Acceptable

Type assertions should **only** be used in these specific scenarios:

1. **When you have more information than TypeScript** (rare):

```typescript
// Acceptable: You know the API returns a specific subtype
interface Animal {
  type: string;
}
interface Dog extends Animal {
  type: "dog";
  bark(): void;
}
interface Cat extends Animal {
  type: "cat";
  meow(): void;
}

function getAnimal(): Animal {
  return { type: "dog", bark: () => console.log("Woof!") };
}

const animal = getAnimal();
if (animal.type === "dog") {
  // Acceptable: We've narrowed the type with a runtime check
  const dog = animal as Dog;
  dog.bark();
}
```

2. **Working with third-party libraries with poor types**:

```typescript
// Acceptable: Library has incorrect types, and you've verified the actual behavior
import { poorlyTypedFunction } from "legacy-lib";

// Add a comment explaining why the assertion is needed
const result = poorlyTypedFunction() as CorrectType; // Library types are wrong, returns CorrectType
```

3. **Const assertions** (these are safe):

```typescript
// DO: Use const assertions to narrow types
const config = {
  apiUrl: "https://api.example.com",
  timeout: 5000,
} as const;

type Config = typeof config;
// config is now { readonly apiUrl: 'https://api.example.com'; readonly timeout: 5000 }

// DO: Const assertions for literal arrays
const colors = ["red", "green", "blue"] as const;
type Color = (typeof colors)[number]; // 'red' | 'green' | 'blue'
```

### Type Inference vs Explicit Types

Prefer type inference when TypeScript can correctly infer the type, but be explicit when needed for clarity and safety.

#### ✅ Let TypeScript Infer

```typescript
// DO: Inference works well here
const count = 42; // number
const name = "Alice"; // string
const users = []; // any[] - but see below for better approach

// DO: Inference from return type
function getUser() {
  return { id: 1, name: "Alice" };
}
const user = getUser(); // { id: number; name: string }
```

#### ✅ Be Explicit When Needed

```typescript
// DO: Be explicit for function parameters
function greet(name: string, age: number): string {
  return `Hello ${name}, you are ${age} years old`;
}

// DO: Be explicit for complex object shapes
interface User {
  id: string;
  name: string;
  email: string;
}

const user: User = {
  id: "123",
  name: "Alice",
  email: "alice@example.com",
};

// DO: Be explicit for empty arrays
const users: User[] = [];
const numbers: number[] = [];

// DO: Be explicit for return types of exported functions
export function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

## Type Definitions

### Use `type` vs `interface` Appropriately

**Use `type` for:**

- Unions and intersections
- Mapped types
- Conditional types
- Primitive aliases
- Tuples
- Function types

**Use `interface` for:**

- Object shapes that may be extended
- Class contracts
- Declaration merging scenarios
- Public API definitions

```typescript
// DO: Use type for unions
type Status = "pending" | "approved" | "rejected";

// DO: Use type for intersections
type Employee = Person & { employeeId: string };

// DO: Use type for mapped types
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};

// DO: Use interface for object shapes
interface User {
  id: string;
  name: string;
  email: string;
}

// DO: Use interface for extensibility
interface BaseUser {
  id: string;
  name: string;
}

interface AdminUser extends BaseUser {
  permissions: string[];
}

// DO: Use interface for classes
interface Serializable {
  serialize(): string;
  deserialize(data: string): void;
}

class DataModel implements Serializable {
  serialize(): string {
    return JSON.stringify(this);
  }
  deserialize(data: string): void {
    Object.assign(this, JSON.parse(data));
  }
}
```

## Type Guards and Narrowing

Type guards are essential for type-safe code without assertions.

```typescript
// DO: Use typeof guards for primitives
function processValue(value: string | number): string {
  if (typeof value === "string") {
    return value.toUpperCase();
  }
  return value.toFixed(2);
}

// DO: Use instanceof for class instances
class HttpError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message);
  }
}

function handleError(error: Error | HttpError): void {
  if (error instanceof HttpError) {
    console.error(`HTTP Error ${error.statusCode}: ${error.message}`);
  } else {
    console.error(`Error: ${error.message}`);
  }
}

// DO: Use 'in' operator for property checks
interface Dog {
  bark(): void;
}

interface Cat {
  meow(): void;
}

function makeSound(animal: Dog | Cat): void {
  if ("bark" in animal) {
    animal.bark();
  } else {
    animal.meow();
  }
}

// DO: Create custom type guards
interface User {
  id: string;
  name: string;
  email: string;
}

function isUser(value: unknown): value is User {
  return (
    typeof value === "object" &&
    value !== null &&
    "id" in value &&
    "name" in value &&
    "email" in value &&
    typeof (value as User).id === "string" &&
    typeof (value as User).name === "string" &&
    typeof (value as User).email === "string"
  );
}

// DO: Use discriminated unions
type Result<T> = { success: true; data: T } | { success: false; error: string };

function handleResult<T>(result: Result<T>): void {
  if (result.success) {
    console.log("Data:", result.data);
  } else {
    console.error("Error:", result.error);
  }
}
```

## Null and Undefined Handling

With `strictNullChecks` enabled, handle null and undefined explicitly.

```typescript
// DO: Use optional chaining
interface User {
  name: string;
  address?: {
    street: string;
    city: string;
  };
}

function getUserCity(user: User): string | undefined {
  return user.address?.city;
}

// DO: Use nullish coalescing
function getDisplayName(name: string | null | undefined): string {
  return name ?? "Anonymous";
}

// DO: Explicitly check for null/undefined
function processUser(user: User | null): void {
  if (user === null) {
    console.log("No user provided");
    return;
  }
  console.log(user.name);
}

// DO: Use type guards for complex checks
function hasAddress(
  user: User
): user is User & { address: NonNullable<User["address"]> } {
  return user.address !== undefined;
}

function printAddress(user: User): void {
  if (hasAddress(user)) {
    console.log(`${user.address.street}, ${user.address.city}`);
  }
}

// DON'T: Use non-null assertion unless absolutely certain
// ❌ user!.address!.city
// ✅ user?.address?.city
```

## Generics

Use generics to write reusable, type-safe code.

```typescript
// DO: Use generics for flexible, type-safe functions
function first<T>(array: T[]): T | undefined {
  return array[0];
}

const numFirst = first([1, 2, 3]); // number | undefined
const strFirst = first(["a", "b", "c"]); // string | undefined

// DO: Use generic constraints
interface HasId {
  id: string;
}

function findById<T extends HasId>(items: T[], id: string): T | undefined {
  return items.find((item) => item.id === id);
}

// DO: Use multiple type parameters
function merge<T, U>(obj1: T, obj2: U): T & U {
  return { ...obj1, ...obj2 };
}

// DO: Use default type parameters
function createArray<T = string>(length: number, value: T): T[] {
  return Array(length).fill(value);
}

const strings = createArray(3, "hello"); // string[]
const numbers = createArray<number>(3, 42); // number[]

// DO: Use generic classes
class DataStore<T> {
  private data: T[] = [];

  add(item: T): void {
    this.data.push(item);
  }

  getAll(): readonly T[] {
    return this.data;
  }

  findBy(predicate: (item: T) => boolean): T | undefined {
    return this.data.find(predicate);
  }
}

const userStore = new DataStore<User>();
userStore.add({ id: "1", name: "Alice", email: "alice@example.com" });
```

## Utility Types

TypeScript provides powerful built-in utility types. Use them!

```typescript
interface User {
  id: string;
  name: string;
  email: string;
  password: string;
  createdAt: Date;
}

// DO: Use Partial for optional properties
type UserUpdate = Partial<User>;

function updateUser(id: string, updates: UserUpdate): void {
  // All properties are optional
}

// DO: Use Pick to select specific properties
type UserPreview = Pick<User, "id" | "name">;

// DO: Use Omit to exclude properties
type UserPublic = Omit<User, "password">;

// DO: Use Readonly for immutable types
type ImmutableUser = Readonly<User>;

// DO: Use Record for dynamic key-value pairs
type UserMap = Record<string, User>;

const users: UserMap = {
  user1: {
    id: "1",
    name: "Alice",
    email: "alice@example.com",
    password: "xxx",
    createdAt: new Date(),
  },
};

// DO: Use Required to make all properties required
type UserRequired = Required<User>;

// DO: Use NonNullable to remove null/undefined
type Name = string | null | undefined;
type DefiniteName = NonNullable<Name>; // string

// DO: Use ReturnType to extract return type
function getUser() {
  return { id: "1", name: "Alice" };
}
type User = ReturnType<typeof getUser>;

// DO: Use Parameters to extract parameter types
function createUser(name: string, email: string, age: number): User {
  return { id: "1", name, email, password: "", createdAt: new Date() };
}
type CreateUserParams = Parameters<typeof createUser>; // [string, string, number]

// DO: Create custom utility types
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};

type Nullable<T> = T | null;

type ValueOf<T> = T[keyof T];
```

## Async/Await and Promises

Always properly type async operations.

```typescript
// DO: Type async functions properly
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) {
    throw new Error("Failed to fetch user");
  }
  const data: unknown = await response.json();
  if (!isUser(data)) {
    throw new Error("Invalid user data");
  }
  return data;
}

// DO: Use Promise.all with proper typing
async function fetchMultipleUsers(ids: string[]): Promise<User[]> {
  const promises = ids.map((id) => fetchUser(id));
  return Promise.all(promises);
}

// DO: Handle errors with proper types
async function safeUserFetch(id: string): Promise<Result<User>> {
  try {
    const user = await fetchUser(id);
    return { success: true, data: user };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return { success: false, error: message };
  }
}

// DO: Type Promise return values
function delayedValue<T>(value: T, ms: number): Promise<T> {
  return new Promise((resolve) => {
    setTimeout(() => resolve(value), ms);
  });
}
```

## Enums vs Union Types

Prefer union types over enums in most cases.

```typescript
// ❌ DON'T: Use enums (they generate runtime code)
enum Status {
  Pending = "PENDING",
  Approved = "APPROVED",
  Rejected = "REJECTED",
}

// ✅ DO: Use union types (zero runtime cost)
type Status = "pending" | "approved" | "rejected";

const status: Status = "pending";

// ✅ DO: Use const objects for grouped constants
const STATUS = {
  PENDING: "pending",
  APPROVED: "approved",
  REJECTED: "rejected",
} as const;

type Status = (typeof STATUS)[keyof typeof STATUS];

// Exception: Numeric enums can be useful
enum HttpStatus {
  OK = 200,
  BadRequest = 400,
  Unauthorized = 401,
  NotFound = 404,
  ServerError = 500,
}
```

## Function Overloads

Use function overloads for complex function signatures.

```typescript
// DO: Use overloads for different parameter combinations
function createElement(tag: "div"): HTMLDivElement;
function createElement(tag: "span"): HTMLSpanElement;
function createElement(tag: "input"): HTMLInputElement;
function createElement(tag: string): HTMLElement;
function createElement(tag: string): HTMLElement {
  return document.createElement(tag);
}

const div = createElement("div"); // HTMLDivElement
const input = createElement("input"); // HTMLInputElement

// DO: Use overloads for different return types based on parameters
function getData(id: string): Promise<User>;
function getData(id: string[]): Promise<User[]>;
function getData(id: string | string[]): Promise<User | User[]> {
  if (Array.isArray(id)) {
    return Promise.all(id.map((i) => fetchUser(i)));
  }
  return fetchUser(id);
}
```

## Naming Conventions

### General Rules

- **Types and Interfaces**: PascalCase
- **Variables and Functions**: camelCase
- **Constants**: UPPER_SNAKE_CASE
- **Private properties**: prefix with `_` or use `#` (private fields)
- **Type parameters**: Single capital letter or PascalCase (T, K, V, TItem, TResult)

```typescript
// DO: Follow naming conventions
interface UserProfile {
  id: string;
  displayName: string;
}

type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";

const MAX_RETRY_ATTEMPTS = 3;
const API_BASE_URL = "https://api.example.com";

function calculateTotalPrice(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

class UserService {
  private _cache: Map<string, User> = new Map();
  #apiKey: string; // Private field (ES2022)

  constructor(apiKey: string) {
    this.#apiKey = apiKey;
  }
}

// DO: Use descriptive names
function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// DON'T: Use abbreviations or unclear names
function valEm(e: string): boolean {
  // ❌
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e);
}
```

## Error Handling

Write type-safe error handling code.

```typescript
// DO: Create custom error classes
class ValidationError extends Error {
  constructor(message: string, public field: string, public value: unknown) {
    super(message);
    this.name = "ValidationError";
  }
}

class ApiError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public response?: unknown
  ) {
    super(message);
    this.name = "ApiError";
  }
}

// DO: Handle errors with proper type checking
function handleError(error: unknown): string {
  if (error instanceof ValidationError) {
    return `Validation failed for ${error.field}: ${error.message}`;
  }

  if (error instanceof ApiError) {
    return `API Error (${error.statusCode}): ${error.message}`;
  }

  if (error instanceof Error) {
    return `Error: ${error.message}`;
  }

  return "An unknown error occurred";
}

// DO: Use Result types for expected failures
type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E };

function parseJson<T>(json: string): Result<T> {
  try {
    const value = JSON.parse(json) as T;
    return { ok: true, value };
  } catch (error) {
    const errorMessage =
      error instanceof Error ? error : new Error("Unknown parsing error");
    return { ok: false, error: errorMessage };
  }
}

// Usage
const result = parseJson<User>('{"id":"1","name":"Alice"}');
if (result.ok) {
  console.log(result.value.name);
} else {
  console.error(result.error.message);
}
```

## Import/Export Organization

Organize imports for readability and maintainability.

```typescript
// DO: Group imports logically
// 1. Node built-ins
import * as fs from "node:fs";
import * as path from "node:path";

// 2. External dependencies
import express from "express";
import { z } from "zod";

// 3. Internal modules (absolute imports)
import { UserService } from "@/services/user";
import { Database } from "@/lib/database";

// 4. Relative imports
import { validateUser } from "./validators";
import type { User, UserRole } from "./types";

// DO: Use named exports (preferred)
export function createUser(data: UserData): User {
  // ...
}

export class UserRepository {
  // ...
}

// DO: Use type exports explicitly
export type { User, UserRole, UserPermissions };

// DON'T: Use default exports (they make refactoring harder)
// ❌ export default function createUser() { }

// Exception: Default exports are okay for React components
// ✅ export default function UserProfile() { }
```

## Documentation

Write helpful JSDoc comments with proper types.

````typescript
/**
 * Fetches a user by their ID from the database.
 *
 * @param id - The unique identifier of the user
 * @returns A promise that resolves to the user object
 * @throws {NotFoundError} When the user doesn't exist
 * @throws {DatabaseError} When database connection fails
 *
 * @example
 * ```typescript
 * const user = await fetchUser('user-123');
 * console.log(user.name);
 * ```
 */
export async function fetchUser(id: string): Promise<User> {
  // Implementation
}

/**
 * Configuration options for the API client.
 */
interface ApiConfig {
  /** Base URL for API requests */
  baseUrl: string;

  /** Request timeout in milliseconds */
  timeout: number;

  /** API authentication token */
  apiToken?: string;

  /** Enable request/response logging */
  debug?: boolean;
}

// DO: Document complex types
/**
 * Represents the result of a validation operation.
 *
 * @typeParam T - The type of the value being validated
 */
type ValidationResult<T> =
  | { valid: true; value: T }
  | { valid: false; errors: string[] };
````

## Best Practices Summary

### ✅ DO

1. **Always enable strict mode** in tsconfig.json
2. **Avoid type assertions** - use type guards and narrowing instead
3. **Be explicit with function signatures** - parameters and return types
4. **Use type inference** for local variables when type is obvious
5. **Handle null/undefined explicitly** with optional chaining and nullish coalescing
6. **Prefer union types** over enums
7. **Use utility types** to transform existing types
8. **Create custom type guards** for runtime validation
9. **Use discriminated unions** for complex state
10. **Type async operations properly** with Promise<T>
11. **Use const assertions** for literal types
12. **Document public APIs** with JSDoc comments

### ❌ DON'T

1. **Don't use `any`** - use `unknown` if type is truly unknown
2. **Don't use type assertions** unless absolutely necessary
3. **Don't use non-null assertion (`!`)** without being certain
4. **Don't use enums** (prefer union types)
5. **Don't leave implicit `any`** types
6. **Don't ignore compiler errors** - fix them
7. **Don't use `@ts-ignore` or `@ts-nocheck`** - fix the type issue
8. **Don't use `Object`, `Function`, `String`, `Number`, `Boolean`** types - use lowercase versions
9. **Don't create overly complex type gymnastics** - keep types readable
10. **Don't export mutable objects** without `readonly`

## Code Review Checklist

When reviewing TypeScript code, check for:

- [ ] Strict mode is enabled
- [ ] No type assertions (`as`) without justification
- [ ] No `any` types
- [ ] No `@ts-ignore` comments
- [ ] All function parameters and return types are typed
- [ ] Proper null/undefined handling
- [ ] Type guards used instead of assertions
- [ ] Consistent naming conventions
- [ ] Appropriate use of `type` vs `interface`
- [ ] No unused variables or parameters
- [ ] Proper error handling
- [ ] JSDoc comments for public APIs
- [ ] No implicit `any` from missing type definitions

## Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [TypeScript Deep Dive](https://basarat.gitbook.io/typescript/)
- [Effective TypeScript](https://effectivetypescript.com/)
- [Type Challenges](https://github.com/type-challenges/type-challenges)
