# monorepo.nvim

monorepo.nvim is a Neovim plugin for navigating and managing multiple projects within a monorepo setup. It integrates with Telescope for project selection and Neo-tree for project navigation.

## Features

- **Project Discovery**: Scans the file system to detect projects using configuration files like package.json and pyproject.toml
- **Telescope Integration:** Displays discovered projects in a Telescope picker with project type emojis and metadata
- **Project Navigation**: Opens selected projects in Neo-tree or switches to the project directory
- **Virtual Environment Management**: Automatically detects and activates Python virtual environments (.venv, venv, virtualenv) when switching to Python projects, with automatic LSP restart
- **Configurable Scanning**: Customizable search depth and directory exclusions to optimize performance
- **Extensible Project Types**: Supports adding custom project types with their own configuration files and name extraction patterns
- **Cross-Platform Support**: Works on both Unix-like systems and Windows environments

## Requirements

- Neovim 0.5 or newer
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [Neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)

## Installation

Example using `lazy.nvim` (mandatory):

```lua
{
  'akshay-vs/monorepo.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-neo-tree/neo-tree.nvim'
  },
  config = function()
    require('monorepo').setup()
  end
}
````
## Configuration

The plugin supports comprehensive configuration through the `setup` function (optional):

```lua
require('monorepo').setup({
  root_dir = vim.fn.getcwd(),
  exclude_dirs = {
    "node_modules",
    ".git",
    "dist",
    "build",
    "__pycache__",
    ".next",
    "coverage"
  },
  max_depth = 5,
  match_venv = { ".venv", ".venv", ".virtualenv" },
  project_types = {
    nodejs = {
      emoji = "📦",
      config_file = "package.json",
      name_pattern = '"name"%s*:%s*"([^"]+)"'
    },
    python = {
      emoji = "🐍",
      config_file = "pyproject.toml",
      name_pattern = 'name%s*=%s*"([^"]+)"'
    },
    rust = {
      emoji = "🦀",
      config_file = "Cargo.toml",
      name_pattern = 'name%s*=%s*"([^"]+)"'
    },
    go = {
      emoji = "🐹",
      config_file = "go.mod",
      name_pattern = 'module%s+([^%s\n]+)'
    }
  }
})
```

### Configuration Options

* **`root_dir`**: The directory to start searching from (defaults to current working directory)
* **`exclude_dirs`**: Array of directory names to ignore while scanning for better performance
* **`max_depth`**: Maximum directory levels deep to search (prevents infinite recursion)
* **`match_venv`**: Array of virtual environment folder names to look for in Python projects
* **`project_types`**: Defines how to recognize and display different types of projects

### Project Type Configuration

Each project type supports:
* **`emoji`**: Display icon for the project type in Telescope picker
* **`config_file`**: File that identifies this project type (e.g., `package.json`)
* **`name_pattern`**: Lua pattern to extract the project name from the config file

### Virtual Environment Support

For Python projects, the plugin will automatically:
1. Search for directories matching names in `match_venv`
2. Validate they contain a proper Python virtual environment
3. Activate the environment and restart LSP when switching to the project
4. Support both Unix-like (`bin/python`) and Windows (`Scripts/python.exe`) environments

### Adding Custom Project Types

You can easily add support for new project types:

```lua
project_types = {
  -- ... existing types
  flutter = {
    emoji = "💙",
    config_file = "pubspec.yaml",
    name_pattern = 'name:%s*([^%s\n]+)'
  },
  docker = {
    emoji = "🐳",
    config_file = "docker-compose.yml",
    name_pattern = 'version:%s*["\']([^"\']+)["\']'
  }
}
```

## Usage

Commands:

* `:MonorepoProjects` — opens the Telescope picker to show discovered projects

Key mappings:

* `<CR>` — open selected project in Neo-tree
* `<C-o>` — change working directory to selected project

Default keymap:

* `<leader>mp` — open project picker

You can rebind this in your keymap config if needed.

## Project Detection

The plugin identifies a project by checking for specific config files. You can define custom project types in the `project_types` table by providing:

* `config_file`: name of the file to check for
* `name_pattern`: Lua pattern to extract the project name

## Contribution

This plugin is under active development. Feel free to open issues or submit pull requests if you want to improve it or request features.

## License

MIT License
