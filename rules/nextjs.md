# Next JS Project - Code Styles and Guidelines

## Project Overview

This is a Next.js 15 application using:

- React 19
- TypeScript (strict mode)
- Tailwind CSS v4
- Next.js 15, using the App Router
- Path aliases: `@/*` maps to `./src/*`

## Code Styles

### TypeScript

- Always use TypeScript strict mode
- Prefer type inference where possible, but be explicit for function parameters and return types
- Use `Readonly<>` for props interfaces
- Use `type` for unions/intersections, `interface` for object shapes that may be extended
- Never use `any` - use `unknown` if type is truly unknown

### React/Next.js

- Use Server Components by default (no "use client" unless needed)
- Use async/await for Server Components that fetch data
- Prefer function components over class components
- Use descriptive component names (PascalCase)
- Export components as default exports
- Place client components in `lib/components/` directory
- Use Next.js Image component for all images
- Use `aria-hidden` for decorative images

### Naming Conventions

- Components: PascalCase (`UserProfile/index.tsx`)
- Directory: Match component name
- Files: Use kebab-case for utilities (helpers, constants, types) when needed
- Functions/variables: camelCase
- Constants: UPPER_SNAKE_CASE
- Types/Interfaces: PascalCase

### Tailwind CSS

- Use Tailwind utility classes, not custom CSS
- Group related classes logically (layout, spacing, colors, etc.)
- Use responsive prefixes: `sm:`, `md:`, `lg:`, `xl:`, `2xl:`
- Prefer Tailwind's design tokens over arbitrary values
- Use `dark:` prefix for dark mode styles

### Code Organization

- Keep components small and focused (single responsibility)
- Extract reusable logic into custom hooks
- Place utilities in `src/lib/` or `src/utils/` - Infer what makes sense
- Use barrel exports (`index.ts`) for cleaner imports

### Documentation

- Add JSDoc comments for public functions/components
- Document complex logic with inline comments
- Include type information in JSDoc
- Keep comments concise and explain "why", not "what"

### Error Handling

- Use error boundaries for React error handling
- Handle async errors with try/catch
- Provide meaningful error messages
- Never silently fail - log errors appropriately

### Performance

- Use Next.js Image optimization
- Implement proper loading states
- Use React.memo() for expensive components when needed
- Lazy load components when appropriate
- Prefer Server Components for better performance

### Accessibility

- Always include alt text for images
- Use semantic HTML elements
- Ensure keyboard navigation works
- Maintain proper heading hierarchy
- Use ARIA labels when needed

### Import Organization

1. React/Next.js imports
2. Third-party libraries
3. Internal components
4. Utilities/helpers
5. Types
6. Styles

### Git Commit Messages

- Use conventional commits format
- Be descriptive and specific
- Reference issues/PRs when applicable

### Coding Standards

- **TypeScript:**
  - Use strict typing, interfaces, and types for all props, state, and API data.
- **React/Next JS**
  - Prefer functional components and React hooks.
  - Every component must live in it's own directory; Where the name of the folder matches the name of the component.
    - Use PascalCase when naming a component. The component must be placed inside an `index.tsx` file.
  - Use JSX syntax and self-closing tags where appropriate.
  - Use ES6+ features (arrow functions, destructuring, template literals).
  - Use hooks for side effects and data loading.
  - Use custom hooks to encapsulate repeated logic.
- **State Management:**
  - Use RTK Query for data fetching and caching when client side requests are needed.
  - Use Redux Toolkit for state management; avoid unnecessary duplication of data.
- **Styling:**
  - Create tailwind components using `tailwind-styled-components`.
  - The `styles.tsx` file holds any tailwind components needed in a component.
  - Use Tailwind for utility-first styling.
- **Testing:**
  - Write Playwright tests for critical user flows.
- **Linting/Formatting:**
  - Use ESLint and Prettier; follow the project’s config.
  - Run `yarn lint` and `yarn prettier` before committing.

### UI Guidelines

- **Responsiveness:**
  - Use Tailwind’s responsive classes and media queries.
  - Test on mobile, tablet, and desktop breakpoints.
- **Accessibility:**
  - Use semantic HTML elements and ARIA attributes where appropriate.
  - Ensure keyboard navigation and screen reader support.
- **Component Design:**
  - Keep components small and focused.
  - Use prop types and default values.
  - Prefer composition over inheritance.
- **Error Handling:**
  - Handle API and async errors gracefully in the UI.
  - Show user-friendly error messages.

## Patterns to Follow

### Component Structure

- All components should be created inside the `src/lib/components/` directory.
- Components must be created as new directories: `src/lib/components/MyComponent/index.tsx`.
- `index.tsx` exports the component as default and holds the component code.
- One component per file.
- Component directories can also have files like `styles.tsx`, or `helpers.ts`, or `contstants.ts` when these relate only to the component in question.

```tsx
import type { ComponentProps } from 'react';

interface ComponentProps {
  // props definition
}

export default function Component({ prop }: ComponentProps) {
  // component logic
  return (
    // JSX
  );
}
```

### Server Component Data Fetching

```tsx
async function Component() {
  const data = await fetchData();
  return <div>{/* render data */}</div>;
}
```

## Patterns to Avoid

- Don't use `console.log` in production code
- Don't commit commented-out code
- Don't use inline styles (use Tailwind classes)
- Don't use `var` declarations (use `const` or `let`)
- Don't create unnecessary wrapper components
- Don't mix async/await with `.then()` chains
- Don't use `setTimeout` or `setInterval` inside react component.
- Don't create multiple components in one file, or within another component.

## Testing (when implemented)

- Write unit tests for utilities and hooks
- Write integration tests for critical user flows
- Use descriptive test names that explain what is being tested

## Additional Context

- Project uses Next.js App Router exclusively
- Follow Next.js 15 and React 19 best practices
- Prioritize performance and accessibility
- Maintain consistency with existing codebase patterns
- Use `yarn` commands over `npm` commands when possible.

## Folder Structure

```sh
...
src/
  app/              # Where the Next JS app lives.
  lib/
    components/     # React components
    hooks/
    store/
    utils/
    ...
```
