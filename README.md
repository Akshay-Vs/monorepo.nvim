# monorepo.nvim

monorepo.nvim is a Neovim plugin for navigating and managing multiple projects within a monorepo setup. It integrates with Telescope for project selection and Neo-tree for project navigation.

## Features

- Scans the file system to detect projects using configuration files like `package.json` and `pyproject.toml`
- Displays discovered projects in a Telescope picker
- Opens selected projects in Neo-tree
- Allows switching to the directory of a selected project
- Configurable search depth and directory exclusions
- Supports adding custom project types and match patterns

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

The plugin supports basic configuration through the `setup` function (optional):

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
  project_types = {
    nodejs = {
      emoji = "",
      config_file = "package.json",
      name_pattern = '"name"%s*:%s*"([^"]+)"'
    },
    python = {
      emoji = "",
      config_file = "pyproject.toml",
      name_pattern = 'name%s*=%s*"([^"]+)"'
    }
  }
})
```

* `root_dir`: the directory to start searching from
* `exclude_dirs`: directories to ignore while scanning
* `max_depth`: how many directory levels deep to search
* `project_types`: defines how to recognize different types of projects

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

```
