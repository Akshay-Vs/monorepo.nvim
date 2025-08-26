local config = require("monorepo.config")
local telescope = require("monorepo.telescope")
local scanner = require("monorepo.scanner")

require("monorepo.venv_manager").setup_autocommands()

local M = {}

-- Setup function
function M.setup(opts)
  config.setup(opts)

  -- Create user command
  vim.api.nvim_create_user_command("MonorepoProjects", telescope.show_projects, {
    desc = "Show monorepo projects in Telescope",
  })

  -- Optional: Create keybinding
  vim.keymap.set("n", "<leader>mp", telescope.show_projects, {
    desc = "Show monorepo projects",
  })
end

-- Export public functions
M.show_projects = telescope.show_projects
M.get_projects = scanner.get_projects
M.get_projects_with_metadata = scanner.get_projects_with_metadata

return M
