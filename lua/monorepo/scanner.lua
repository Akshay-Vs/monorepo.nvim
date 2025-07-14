local utils = require("monorepo.utils")
local config = require("monorepo.config")

local M = {}

-- Detect project type and extract name from directory
local function detect_project(dir)
  local conf = config.get()

  for project_type, type_config in pairs(conf.project_types) do
    local config_file = dir .. "/" .. type_config.config_file

    if utils.file_exists(config_file) then
      local content = utils.read_file(config_file)
      if content then
        local name = utils.extract_name(content, type_config.name_pattern)
        if name then
          return {
            name = name,
            path = dir,
            type = project_type,
            config_file = config_file,
          }
        end
      end
    end
  end

  return nil
end

-- Recursively find projects in directory
local function find_projects_recursive(dir, depth, conf)
  if depth > conf.max_depth then
    return {}
  end

  local projects = {}
  local handle = vim.loop.fs_scandir(dir)

  if not handle then
    return projects
  end

  -- Check if current directory contains a project
  local project = detect_project(dir)
  if project then
    table.insert(projects, project)
  end

  -- Recursively search subdirectories
  while true do
    local entry_name, entry_type = vim.loop.fs_scandir_next(handle)
    if not entry_name then
      break
    end

    if entry_type == "directory" and not utils.is_excluded_dir(entry_name, conf.exclude_dirs) then
      local subdir = dir .. "/" .. entry_name
      local subprojects = find_projects_recursive(subdir, depth + 1, conf)
      for _, subproject in ipairs(subprojects) do
        table.insert(projects, subproject)
      end
    end
  end

  return projects
end

-- Get all projects in monorepo
function M.get_projects()
  local conf = config.get()
  return find_projects_recursive(conf.root_dir, 0, conf)
end

-- Get projects with additional metadata
function M.get_projects_with_metadata()
  local projects = M.get_projects()
  local conf = config.get()

  -- Add relative paths and other metadata
  for _, project in ipairs(projects) do
    project.relative_path = utils.get_relative_path(project.path, conf.root_dir)
    project.display_name = utils.format_project_display(project)
  end

  return projects
end

return M
