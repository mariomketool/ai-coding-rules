# React - Code Styles and Guidelines

## Project Overview

This is a React application using:

- React 18+
- TypeScript (strict mode)
- Redux Toolkit for state management
- RTK Query for client-side data fetching
- Tailwind CSS for styling
- Function components only (no class components)

## Core Principles

### Component Architecture

- **Function Components Only**: Never use class components. Always use function components with hooks.
- **TypeScript**: All components must be written in TypeScript with proper type definitions.
- **Component Structure**: Every component lives in its own directory. The directory name must match the component name (PascalCase).
- **Index Exports**: Components are always exported from an `index.tsx` file within their directory.

### State Management

- **Redux Toolkit**: Use Redux Toolkit for all global state management.
- **RTK Query**: Use RTK Query for all client-side API requests and data caching.
- **Local State**: Use `useState` for component-local state that doesn't need to be shared.

### Styling

- **Tailwind CSS**: Use Tailwind utility classes for all styling.
- **No Inline Styles**: Never use inline style attributes.
- **No Custom CSS**: Avoid writing custom CSS files; leverage Tailwind's utility classes.

## TypeScript Configuration

Your `tsconfig.json` should include strict settings:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "jsx": "react-jsx",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

## Component Patterns

### Component Directory Structure

Every component must follow this structure:

```
src/
  components/
    Button/
      index.tsx          # Main component file
      Button.types.ts    # Type definitions (if complex)
      Button.test.tsx    # Tests
      styles.ts          # Styled components (if needed)
    UserProfile/
      index.tsx
      UserProfile.types.ts
    Modal/
      index.tsx
```

### ❌ Bad: Single File Components or Class Components

```typescript
// DON'T: Class component
class Button extends React.Component {
  render() {
    return <button>{this.props.children}</button>;
  }
}

// DON'T: Component not in its own directory
// src/components/Button.tsx
export function Button() {
  return <button>Click me</button>;
}

// DON'T: Multiple components in one file
export function Button() {
  return <button>Click me</button>;
}

export function Link() {
  return <a href="#">Link</a>;
}
```

### ✅ Good: Function Components in Directories

```typescript
// src/components/Button/index.tsx
import type { ButtonProps } from "./Button.types";

export default function Button({
  children,
  variant = "primary",
  onClick,
  disabled = false,
}: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`
        px-4 py-2 rounded-lg font-medium transition-colors
        ${
          variant === "primary"
            ? "bg-blue-600 text-white hover:bg-blue-700"
            : "bg-gray-200 text-gray-800 hover:bg-gray-300"
        }
        ${disabled ? "opacity-50 cursor-not-allowed" : "cursor-pointer"}
      `}
    >
      {children}
    </button>
  );
}

// src/components/Button/Button.types.ts
export interface ButtonProps {
  children: React.ReactNode;
  variant?: "primary" | "secondary";
  onClick?: () => void;
  disabled?: boolean;
}
```

### Component Props

- Always define prop types using TypeScript interfaces
- Use `interface` for props that might be extended
- Make props readonly when appropriate
- Provide default values for optional props

```typescript
// ✅ Good
interface UserCardProps {
  user: {
    id: string;
    name: string;
    email: string;
    avatar?: string;
  };
  onSelect?: (userId: string) => void;
  variant?: "compact" | "detailed";
}

export default function UserCard({
  user,
  onSelect,
  variant = "compact",
}: UserCardProps) {
  // component logic
}
```

## React Hooks Best Practices

### useState

```typescript
// ✅ Good: Proper typing and initialization
const [count, setCount] = useState<number>(0);
const [user, setUser] = useState<User | null>(null);
const [isLoading, setIsLoading] = useState<boolean>(false);

// ✅ Good: Using functional updates
setCount((prev) => prev + 1);

// ❌ Bad: Direct state mutation
const [items, setItems] = useState<string[]>([]);
items.push("new"); // DON'T mutate state directly
```

### useEffect

```typescript
// ✅ Good: Clean up side effects
useEffect(() => {
  const subscription = subscribe();

  return () => {
    subscription.unsubscribe();
  };
}, [dependency]);

// ✅ Good: Proper dependency array
useEffect(() => {
  fetchData(userId);
}, [userId]);

// ❌ Bad: Missing dependencies
useEffect(() => {
  fetchData(userId); // userId should be in dependencies
}, []);

// ❌ Bad: Using async directly in useEffect
useEffect(async () => {
  // DON'T
  await fetchData();
}, []);

// ✅ Good: Async in useEffect
useEffect(() => {
  const loadData = async () => {
    const data = await fetchData();
    setData(data);
  };

  loadData();
}, []);
```

### Custom Hooks

Extract reusable logic into custom hooks:

```typescript
// src/hooks/useLocalStorage/index.ts
export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });

  const setValue = (value: T) => {
    try {
      setStoredValue(value);
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue];
}
```

## Redux Toolkit

### Store Setup

```typescript
// src/store/index.ts
import { configureStore } from "@reduxjs/toolkit";
import { setupListeners } from "@reduxjs/toolkit/query";
import { api } from "./api";
import userReducer from "./slices/userSlice";

export const store = configureStore({
  reducer: {
    [api.reducerPath]: api.reducer,
    user: userReducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(api.middleware),
});

setupListeners(store.dispatch);

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

### Typed Hooks

```typescript
// src/store/hooks.ts
import { TypedUseSelectorHook, useDispatch, useSelector } from "react-redux";
import type { RootState, AppDispatch } from "./index";

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

### Creating Slices

```typescript
// src/store/slices/userSlice.ts
import { createSlice, PayloadAction } from "@reduxjs/toolkit";

interface UserState {
  currentUser: User | null;
  theme: "light" | "dark";
  preferences: UserPreferences;
}

const initialState: UserState = {
  currentUser: null,
  theme: "light",
  preferences: {},
};

const userSlice = createSlice({
  name: "user",
  initialState,
  reducers: {
    setUser: (state, action: PayloadAction<User>) => {
      state.currentUser = action.payload;
    },
    setTheme: (state, action: PayloadAction<"light" | "dark">) => {
      state.theme = action.payload;
    },
    updatePreferences: (
      state,
      action: PayloadAction<Partial<UserPreferences>>
    ) => {
      state.preferences = { ...state.preferences, ...action.payload };
    },
    clearUser: (state) => {
      state.currentUser = null;
    },
  },
});

export const { setUser, setTheme, updatePreferences, clearUser } =
  userSlice.actions;
export default userSlice.reducer;
```

### Using Redux State in Components

```typescript
// src/components/UserProfile/index.tsx
import { useAppSelector, useAppDispatch } from "@/store/hooks";
import { setTheme } from "@/store/slices/userSlice";

export default function UserProfile() {
  const dispatch = useAppDispatch();
  const { currentUser, theme } = useAppSelector((state) => state.user);

  const handleThemeToggle = () => {
    dispatch(setTheme(theme === "light" ? "dark" : "light"));
  };

  if (!currentUser) {
    return <div>Please log in</div>;
  }

  return (
    <div className="p-4">
      <h2 className="text-2xl font-bold">{currentUser.name}</h2>
      <button
        onClick={handleThemeToggle}
        className="mt-4 px-4 py-2 bg-blue-600 text-white rounded"
      >
        Toggle Theme
      </button>
    </div>
  );
}
```

## RTK Query

### API Setup

```typescript
// src/store/api/index.ts
import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

interface User {
  id: string;
  name: string;
  email: string;
}

interface CreateUserRequest {
  name: string;
  email: string;
}

export const api = createApi({
  reducerPath: "api",
  baseQuery: fetchBaseQuery({
    baseUrl: "https://api.example.com",
    prepareHeaders: (headers) => {
      const token = localStorage.getItem("token");
      if (token) {
        headers.set("authorization", `Bearer ${token}`);
      }
      return headers;
    },
  }),
  tagTypes: ["User", "Post"],
  endpoints: (builder) => ({
    getUsers: builder.query<User[], void>({
      query: () => "/users",
      providesTags: ["User"],
    }),
    getUserById: builder.query<User, string>({
      query: (id) => `/users/${id}`,
      providesTags: (result, error, id) => [{ type: "User", id }],
    }),
    createUser: builder.mutation<User, CreateUserRequest>({
      query: (body) => ({
        url: "/users",
        method: "POST",
        body,
      }),
      invalidatesTags: ["User"],
    }),
    updateUser: builder.mutation<User, { id: string; data: Partial<User> }>({
      query: ({ id, data }) => ({
        url: `/users/${id}`,
        method: "PATCH",
        body: data,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: "User", id }],
    }),
    deleteUser: builder.mutation<void, string>({
      query: (id) => ({
        url: `/users/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["User"],
    }),
  }),
});

export const {
  useGetUsersQuery,
  useGetUserByIdQuery,
  useCreateUserMutation,
  useUpdateUserMutation,
  useDeleteUserMutation,
} = api;
```

### Using RTK Query in Components

```typescript
// src/components/UserList/index.tsx
import { useGetUsersQuery, useDeleteUserMutation } from "@/store/api";

export default function UserList() {
  const { data: users, isLoading, error, refetch } = useGetUsersQuery();
  const [deleteUser, { isLoading: isDeleting }] = useDeleteUserMutation();

  const handleDelete = async (userId: string) => {
    try {
      await deleteUser(userId).unwrap();
      // Success handling
    } catch (error) {
      console.error("Failed to delete user:", error);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="text-gray-600">Loading users...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 bg-red-50 border border-red-200 rounded">
        <p className="text-red-800">Error loading users</p>
        <button
          onClick={() => refetch()}
          className="mt-2 px-4 py-2 bg-red-600 text-white rounded"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-4 p-4">
      {users?.map((user) => (
        <div
          key={user.id}
          className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-lg"
        >
          <div>
            <h3 className="text-lg font-semibold">{user.name}</h3>
            <p className="text-gray-600">{user.email}</p>
          </div>
          <button
            onClick={() => handleDelete(user.id)}
            disabled={isDeleting}
            className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 disabled:opacity-50"
          >
            {isDeleting ? "Deleting..." : "Delete"}
          </button>
        </div>
      ))}
    </div>
  );
}
```

### RTK Query Best Practices

- Always handle loading and error states
- Use `providesTags` and `invalidatesTags` for automatic cache invalidation
- Use `.unwrap()` with mutations to handle errors properly
- Leverage automatic re-fetching and caching
- Use polling for real-time data when needed

```typescript
// Polling example
const { data } = useGetUsersQuery(undefined, {
  pollingInterval: 30000, // Poll every 30 seconds
});

// Skip query conditionally
const { data } = useGetUserByIdQuery(userId, {
  skip: !userId, // Don't run query if userId is undefined
});
```

## Tailwind CSS Guidelines

### Utility Classes

```typescript
// ✅ Good: Using Tailwind utilities
export default function Card({ children }: { children: React.ReactNode }) {
  return (
    <div
      className="
      bg-white 
      rounded-lg 
      shadow-md 
      p-6 
      border 
      border-gray-200
      hover:shadow-lg 
      transition-shadow
      duration-200
    "
    >
      {children}
    </div>
  );
}

// ❌ Bad: Inline styles
export default function Card({ children }: { children: React.ReactNode }) {
  return (
    <div
      style={{
        backgroundColor: "white",
        borderRadius: "8px",
        boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
        padding: "24px",
      }}
    >
      {children}
    </div>
  );
}
```

### Responsive Design

```typescript
export default function ResponsiveGrid() {
  return (
    <div
      className="
      grid 
      grid-cols-1 
      sm:grid-cols-2 
      md:grid-cols-3 
      lg:grid-cols-4 
      gap-4 
      p-4
    "
    >
      {/* Grid items */}
    </div>
  );
}
```

### Conditional Classes

```typescript
// ✅ Good: Using template literals for conditional classes
interface ButtonProps {
  variant: "primary" | "secondary" | "danger";
  size?: "sm" | "md" | "lg";
  disabled?: boolean;
}

export default function Button({
  variant,
  size = "md",
  disabled = false,
}: ButtonProps) {
  return (
    <button
      disabled={disabled}
      className={`
        font-medium rounded transition-colors
        ${size === "sm" ? "px-3 py-1 text-sm" : ""}
        ${size === "md" ? "px-4 py-2 text-base" : ""}
        ${size === "lg" ? "px-6 py-3 text-lg" : ""}
        ${
          variant === "primary"
            ? "bg-blue-600 text-white hover:bg-blue-700"
            : ""
        }
        ${
          variant === "secondary"
            ? "bg-gray-200 text-gray-800 hover:bg-gray-300"
            : ""
        }
        ${variant === "danger" ? "bg-red-600 text-white hover:bg-red-700" : ""}
        ${disabled ? "opacity-50 cursor-not-allowed" : ""}
      `}
    >
      Click me
    </button>
  );
}

// Alternative: Using a utility library like clsx or classnames
import clsx from "clsx";

export default function Button({
  variant,
  size = "md",
  disabled = false,
}: ButtonProps) {
  return (
    <button
      disabled={disabled}
      className={clsx("font-medium rounded transition-colors", {
        "px-3 py-1 text-sm": size === "sm",
        "px-4 py-2 text-base": size === "md",
        "px-6 py-3 text-lg": size === "lg",
        "bg-blue-600 text-white hover:bg-blue-700": variant === "primary",
        "bg-gray-200 text-gray-800 hover:bg-gray-300": variant === "secondary",
        "bg-red-600 text-white hover:bg-red-700": variant === "danger",
        "opacity-50 cursor-not-allowed": disabled,
      })}
    >
      Click me
    </button>
  );
}
```

## Code Organization

### File Structure

```
src/
  components/          # Reusable UI components
    Button/
      index.tsx
    Card/
      index.tsx
    Modal/
      index.tsx
  features/            # Feature-specific components
    auth/
      Login/
        index.tsx
      Register/
        index.tsx
    dashboard/
      Dashboard/
        index.tsx
  hooks/               # Custom hooks
    useLocalStorage/
      index.ts
    useDebounce/
      index.ts
  store/               # Redux store
    index.ts
    hooks.ts
    api/
      index.ts
    slices/
      userSlice.ts
      appSlice.ts
  utils/               # Utility functions
    formatDate.ts
    validation.ts
  types/               # Shared TypeScript types
    user.ts
    api.ts
  App.tsx
  main.tsx
```

### Import Organization

Organize imports in this order:

```typescript
// 1. React and external libraries
import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";

// 2. Redux/RTK Query
import { useAppSelector, useAppDispatch } from "@/store/hooks";
import { useGetUsersQuery } from "@/store/api";

// 3. Components
import Button from "@/components/Button";
import Modal from "@/components/Modal";

// 4. Hooks
import { useDebounce } from "@/hooks/useDebounce";

// 5. Utils and helpers
import { formatDate } from "@/utils/formatDate";

// 6. Types
import type { User } from "@/types/user";
```

## Error Handling

### Error Boundaries

```typescript
// src/components/ErrorBoundary/index.tsx
import { Component, ErrorInfo, ReactNode } from "react";

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export default class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error("Error caught by boundary:", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div className="flex items-center justify-center min-h-screen bg-gray-50">
            <div className="p-8 bg-white rounded-lg shadow-md max-w-md">
              <h2 className="text-2xl font-bold text-red-600 mb-4">
                Something went wrong
              </h2>
              <p className="text-gray-700 mb-4">
                {this.state.error?.message || "An unexpected error occurred"}
              </p>
              <button
                onClick={() => this.setState({ hasError: false })}
                className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              >
                Try again
              </button>
            </div>
          </div>
        )
      );
    }

    return this.props.children;
  }
}
```

### Async Error Handling

```typescript
// ✅ Good: Proper error handling with try/catch
export default function DataFetcher() {
  const [data, setData] = useState<Data | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const fetchData = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch("/api/data");

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();
      setData(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : "An error occurred");
      console.error("Failed to fetch data:", err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded mb-4">
          <p className="text-red-800">{error}</p>
        </div>
      )}
      {/* Rest of component */}
    </div>
  );
}
```

## Performance Optimization

### React.memo

```typescript
// ✅ Good: Memoize expensive components
import { memo } from "react";

interface ExpensiveComponentProps {
  data: ComplexData[];
  onItemClick: (id: string) => void;
}

const ExpensiveComponent = memo(function ExpensiveComponent({
  data,
  onItemClick,
}: ExpensiveComponentProps) {
  return (
    <div>
      {data.map((item) => (
        <div key={item.id} onClick={() => onItemClick(item.id)}>
          {/* Complex rendering logic */}
        </div>
      ))}
    </div>
  );
});

export default ExpensiveComponent;
```

### useMemo and useCallback

```typescript
import { useMemo, useCallback } from "react";

export default function OptimizedComponent({ items }: { items: Item[] }) {
  // Memoize expensive calculations
  const sortedItems = useMemo(() => {
    return [...items].sort((a, b) => a.name.localeCompare(b.name));
  }, [items]);

  // Memoize callbacks to prevent unnecessary re-renders
  const handleItemClick = useCallback((id: string) => {
    console.log("Clicked item:", id);
  }, []);

  return (
    <div>
      {sortedItems.map((item) => (
        <div key={item.id} onClick={() => handleItemClick(item.id)}>
          {item.name}
        </div>
      ))}
    </div>
  );
}
```

### Lazy Loading

```typescript
import { lazy, Suspense } from "react";

// Lazy load heavy components
const HeavyComponent = lazy(() => import("@/components/HeavyComponent"));

export default function App() {
  return (
    <Suspense
      fallback={
        <div className="flex items-center justify-center p-8">
          <div className="text-gray-600">Loading...</div>
        </div>
      }
    >
      <HeavyComponent />
    </Suspense>
  );
}
```

## Accessibility

### Semantic HTML

```typescript
// ✅ Good: Using semantic elements
export default function Article() {
  return (
    <article className="p-6">
      <header>
        <h1 className="text-3xl font-bold">Article Title</h1>
      </header>
      <section>
        <p>Article content...</p>
      </section>
      <footer className="mt-4 text-gray-600">
        Published on {new Date().toLocaleDateString()}
      </footer>
    </article>
  );
}

// ❌ Bad: Using divs for everything
export default function Article() {
  return (
    <div className="p-6">
      <div>
        <div className="text-3xl font-bold">Article Title</div>
      </div>
      <div>
        <div>Article content...</div>
      </div>
      <div className="mt-4 text-gray-600">
        Published on {new Date().toLocaleDateString()}
      </div>
    </div>
  );
}
```

### ARIA Attributes

```typescript
export default function AccessibleButton() {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <div>
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        aria-expanded={isExpanded}
        aria-controls="content-section"
        className="px-4 py-2 bg-blue-600 text-white rounded"
      >
        Toggle Content
      </button>

      <div
        id="content-section"
        role="region"
        aria-hidden={!isExpanded}
        className={isExpanded ? "block" : "hidden"}
      >
        Content here
      </div>
    </div>
  );
}
```

### Keyboard Navigation

```typescript
export default function KeyboardAccessible() {
  const handleKeyDown = (event: React.KeyboardEvent) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      // Handle action
    }
  };

  return (
    <div
      role="button"
      tabIndex={0}
      onKeyDown={handleKeyDown}
      onClick={() => {
        /* Handle click */
      }}
      className="cursor-pointer p-4 focus:outline-none focus:ring-2 focus:ring-blue-500"
    >
      Click or press Enter/Space
    </div>
  );
}
```

## Testing

### Component Testing

```typescript
// src/components/Button/Button.test.tsx
import { render, screen, fireEvent } from "@testing-library/react";
import Button from "./index";

describe("Button", () => {
  it("renders with children", () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText("Click me")).toBeInTheDocument();
  });

  it("calls onClick when clicked", () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);

    fireEvent.click(screen.getByText("Click me"));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it("is disabled when disabled prop is true", () => {
    render(<Button disabled>Click me</Button>);
    expect(screen.getByText("Click me")).toBeDisabled();
  });
});
```

### Testing with RTK Query

```typescript
import { renderHook, waitFor } from "@testing-library/react";
import { Provider } from "react-redux";
import { store } from "@/store";
import { useGetUsersQuery } from "@/store/api";

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <Provider store={store}>{children}</Provider>
);

describe("useGetUsersQuery", () => {
  it("fetches users successfully", async () => {
    const { result } = renderHook(() => useGetUsersQuery(), { wrapper });

    await waitFor(() => {
      expect(result.current.isSuccess).toBe(true);
    });

    expect(result.current.data).toBeDefined();
  });
});
```

## Patterns to Follow

### ✅ DO

- Use function components exclusively
- Define proper TypeScript types for all props and state
- Use Redux Toolkit for global state management
- Use RTK Query for all API requests
- Use Tailwind utility classes for styling
- Keep components in their own directories with index.tsx
- Extract reusable logic into custom hooks
- Handle loading and error states properly
- Use semantic HTML elements
- Implement proper error boundaries
- Memoize expensive computations and components when needed
- Write tests for critical functionality

### ❌ DON'T

- Never use class components
- Don't use inline styles
- Don't write custom CSS files
- Don't put multiple components in one file
- Don't mutate state directly
- Don't use `any` type in TypeScript
- Don't ignore loading and error states
- Don't fetch data without proper error handling
- Don't skip accessibility attributes
- Don't use non-semantic HTML (divs everywhere)
- Don't commit commented-out code
- Don't use `console.log` in production code

## Additional Best Practices

### Environment Variables

```typescript
// ✅ Good: Using environment variables
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";

// In .env file:
// VITE_API_URL=https://api.production.com
```

### Constants

```typescript
// src/constants/index.ts
export const API_ENDPOINTS = {
  USERS: "/users",
  POSTS: "/posts",
  COMMENTS: "/comments",
} as const;

export const ROUTES = {
  HOME: "/",
  DASHBOARD: "/dashboard",
  PROFILE: "/profile",
  LOGIN: "/login",
} as const;
```

### Type Safety

```typescript
// ✅ Good: Proper type definitions
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}

interface User {
  id: string;
  name: string;
  email: string;
  role: "admin" | "user" | "guest";
}

// Type guard
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === "object" &&
    obj !== null &&
    "id" in obj &&
    "name" in obj &&
    "email" in obj &&
    typeof (obj as User).id === "string"
  );
}
```

## Documentation

### Component Documentation

````typescript
/**
 * A reusable button component with multiple variants and sizes.
 *
 * @component
 * @example
 * ```tsx
 * <Button variant="primary" size="lg" onClick={handleClick}>
 *   Click me
 * </Button>
 * ```
 */
interface ButtonProps {
  /** The button's visual style variant */
  variant?: "primary" | "secondary" | "danger";
  /** The size of the button */
  size?: "sm" | "md" | "lg";
  /** Click handler */
  onClick?: () => void;
  /** Whether the button is disabled */
  disabled?: boolean;
  /** Button content */
  children: React.ReactNode;
}

export default function Button({
  variant = "primary",
  size = "md",
  onClick,
  disabled = false,
  children,
}: ButtonProps) {
  // Implementation
}
````

## Summary

This React project follows these core principles:

1. **Function components only** - No class components
2. **TypeScript everywhere** - Strict typing for all code
3. **Redux Toolkit** - Global state management
4. **RTK Query** - All client-side API requests
5. **Tailwind CSS** - All styling with utility classes
6. **Directory structure** - Each component in its own folder with index.tsx
7. **Best practices** - Performance, accessibility, and maintainability

Follow these guidelines to maintain a consistent, type-safe, and maintainable React codebase.
