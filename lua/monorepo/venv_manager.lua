local utils = require("monorepo.utils")
local config = require("monorepo.config")

local M = {}

-- Get possible virtual environment folder names from config
function M.get_venv_folder_names()
  local conf = config.get()
  return conf.match_venv or { ".venv", ".venv", ".virtualenv" }
end

-- Check if a directory is a valid virtual environment
local function is_valid_venv(venv_path)
  -- Check for common venv indicators
  local indicators = {
    "bin/python",          -- Unix-like systems
    "Scripts/python.exe",  -- Windows
    "bin/activate",        -- Unix activation script
    "Scripts/activate.bat" -- Windows activation script
  }

  for _, indicator in ipairs(indicators) do
    if utils.file_exists(venv_path .. "/" .. indicator) then
      return true
    end
  end
  return false
end

-- Find virtual environment directory in project root
function M.find_venv_in_project(project_path)
  local venv_names = M.get_venv_folder_names()

  for _, venv_name in ipairs(venv_names) do
    local venv_path = project_path .. "/" .. venv_name

    -- Check if directory exists and is a valid venv
    if vim.fn.isdirectory(venv_path) == 1 and is_valid_venv(venv_path) then
      return venv_path
    end
  end

  return nil
end

-- Get the appropriate Python executable path from venv
local function get_python_executable(venv_path)
  -- Try Unix-like path first
  local unix_python = venv_path .. "/bin/python"
  if utils.file_exists(unix_python) then
    return unix_python
  end

  -- Try Windows path
  local windows_python = venv_path .. "/Scripts/python.exe"
  if utils.file_exists(windows_python) then
    return windows_python
  end

  return nil
end

-- Get the appropriate activation script path
local function get_activation_script(venv_path)
  -- Try Unix-like activation script
  local unix_activate = venv_path .. "/bin/activate"
  if utils.file_exists(unix_activate) then
    return unix_activate
  end

  -- Try Windows activation script
  local windows_activate = venv_path .. "/Scripts/activate.bat"
  if utils.file_exists(windows_activate) then
    return windows_activate
  end

  return nil
end

-- Activate virtual environment for the current session
function M.activate_venv(venv_path)
  local python_exe = get_python_executable(venv_path)
  local activate_script = get_activation_script(venv_path)

  if not python_exe then
    vim.notify("Could not find Python executable in venv: " .. venv_path, vim.log.levels.ERROR)
    return false
  end

  -- Set environment variables
  vim.env.VIRTUAL_ENV = venv_path
  vim.env.VIRTUAL_ENV_PROMPT = vim.fn.fnamemodify(venv_path, ":t")

  -- Update PATH to include venv binaries
  local bin_dir = vim.fn.fnamemodify(python_exe, ":h")
  local current_path = vim.env.PATH or ""
  vim.env.PATH = bin_dir .. ":" .. current_path

  -- Set Python path for LSP and other tools
  vim.g.python3_host_prog = python_exe

  vim.notify("🐍 Activated virtual environment: " .. venv_path, vim.log.levels.INFO)
  return true
end

-- Deactivate current virtual environment
function M.deactivate_venv()
  if not vim.env.VIRTUAL_ENV then
    vim.notify("No virtual environment is currently active", vim.log.levels.WARN)
    return false
  end

  local venv_path = vim.env.VIRTUAL_ENV

  -- Remove venv bin directory from PATH
  local python_exe = get_python_executable(venv_path)
  if python_exe then
    local bin_dir = vim.fn.fnamemodify(python_exe, ":h")
    local current_path = vim.env.PATH or ""
    vim.env.PATH = current_path:gsub("^" .. vim.pesc(bin_dir) .. ":", "")
  end

  -- Clear environment variables
  vim.env.VIRTUAL_ENV = nil
  vim.env.VIRTUAL_ENV_PROMPT = nil
  vim.g.python3_host_prog = nil

  vim.notify("🐍 Deactivated virtual environment: " .. venv_path, vim.log.levels.INFO)
  return true
end

-- Check if project is Python and activate venv if found
function M.handle_python_project(project)
  -- Only handle Python projects
  if not project or project.type ~= "python" then
    return false
  end

  local venv_path = M.find_venv_in_project(project.path)

  if not venv_path then
    vim.notify("🐍 No virtual environment found for project: " .. project.name, vim.log.levels.INFO)
    return false
  end

  -- Deactivate current venv if any
  if vim.env.VIRTUAL_ENV then
    M.deactivate_venv()
  end

  -- Activate the found venv
  local success = M.activate_venv(venv_path)

  if success then
    -- Restart LSP to pick up the new Python environment
    vim.schedule(function()
      vim.cmd("LspRestart")
    end)

    vim.notify("🐍 Virtual environment activated and LSP restarted for project: " .. project.name, vim.log.levels.INFO)
  end

  return success
end

-- Auto-activate venv when changing to a Python project directory
function M.auto_activate_on_cd()
  local current_dir = vim.fn.getcwd()
  local scanner = require("monorepo.scanner")
  local projects = scanner.get_projects()

  -- Find if current directory matches any Python project
  for _, project in ipairs(projects) do
    if project.path == current_dir and project.type == "python" then
      M.handle_python_project(project)
      break
    end
  end
end

-- Setup autocommands for automatic venv activation
function M.setup_autocommands()
  local group = vim.api.nvim_create_augroup("MonorepoVenvManager", { clear = true })

  -- Auto-activate when changing directories
  vim.api.nvim_create_autocmd("DirChanged", {
    group = group,
    callback = function()
      M.auto_activate_on_cd()
    end,
  })
end

-- Get status information about current venv
function M.get_venv_status()
  local venv_path = vim.env.VIRTUAL_ENV
  if not venv_path then
    return {
      active = false,
      path = nil,
      name = nil,
      python = nil,
    }
  end

  return {
    active = true,
    path = venv_path,
    name = vim.fn.fnamemodify(venv_path, ":t"),
    python = get_python_executable(venv_path),
  }
end

return M
