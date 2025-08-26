local M = {}

-- Default configuration
M.defaults = {
  root_dir = vim.fn.getcwd(), -- Default to current working directory
  exclude_dirs = { "node_modules", ".git", "dist", "build", "__pycache__", ".next", "coverage" },
  match_venv = { ".venv", ".venv", ".virtualenv" },
  max_depth = 5,
  project_types = {
    nodejs = {
      emoji = "📦",
      config_file = "package.json",
      name_pattern = '"name"%s*:%s*"([^"]+)"',
    },
    python = {
      emoji = "🐍",
      config_file = "pyproject.toml",
      name_pattern = 'name%s*=%s*"([^"]+)"',
    },
  },
}

-- Current configuration
M.config = {}

-- Setup configuration
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

-- Get current configuration
function M.get()
  return M.config
end

return M
