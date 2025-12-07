# AI Coding Rules

A collection of AI coding guidelines and best practices for various frameworks and languages. These rules can be deployed to Cursor IDE and GitHub Copilot to guide AI-assisted code generation.

## Overview

This project maintains modular AI coding rules that can be combined and deployed to:
- **Cursor IDE** (`.cursorrules` file)
- **GitHub Copilot** (`.github/copilot-instructions.md`)

## Available Rules

- **`nextjs.md`** - Next.js 15 with React 19, TypeScript, and Tailwind CSS v4
- **`python.md`** - Python 3.12+ with modern type hints and best practices

## Quick Start

### Deploy Single Rule Set

```bash
./deploy-rules.sh nextjs
```

### Deploy Multiple Rule Sets

Combine multiple rule files into a single deployment:

```bash
./deploy-rules.sh nextjs python
```

This creates:
- `dist/.cursorrules` - For Cursor IDE
- `dist/.github/copilot-instructions.md` - For GitHub Copilot

## Usage

### For Cursor IDE

1. Deploy your desired rules:
   ```bash
   ./deploy-rules.sh nextjs
   ```

2. Copy the generated `.cursorrules` file to your project root:
   ```bash
   cp dist/.cursorrules /path/to/your/project/
   ```

### For GitHub Copilot

1. Deploy your desired rules:
   ```bash
   ./deploy-rules.sh python
   ```

2. Copy the generated instructions to your project:
   ```bash
   cp -r dist/.github /path/to/your/project/
   ```

## Project Structure

```
ai-rules/
├── rules/              # Source rule files
│   ├── nextjs.md      # Next.js coding guidelines
│   └── python.md      # Python coding guidelines
├── dist/              # Generated output (created by deploy script)
│   ├── .cursorrules
│   └── .github/
│       └── copilot-instructions.md
├── deploy-rules.sh    # Deployment script
└── README.md
```

## Adding New Rules

1. Create a new markdown file in the `rules/` directory:
   ```bash
   touch rules/react-native.md
   ```

2. Write your coding guidelines in the new file

3. Deploy it:
   ```bash
   ./deploy-rules.sh react-native
   ```

4. Or combine it with existing rules:
   ```bash
   ./deploy-rules.sh react-native typescript
   ```

## Deployment Script

The `deploy-rules.sh` script:
- Accepts one or more rule file names (without `.md` extension)
- Concatenates multiple files with `---` separators
- Creates both Cursor and GitHub Copilot compatible outputs
- Validates that all specified files exist
- Clears and recreates the `dist/` directory on each run

### Error Handling

The script will exit with an error if:
- No filename arguments are provided
- Any specified rule file doesn't exist

## Contributing

To add new rule sets:

1. Follow the existing format in `rules/nextjs.md` or `rules/python.md`
2. Use clear markdown headers and code examples
3. Focus on actionable, specific guidelines
4. Test the deployment to ensure proper formatting

## License

[Add your license here]

## Author

[Add your name/organization here]

