local M = {}

-- Utility function to read file content
function M.read_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil
  end

  local content = file:read("*all")
  file:close()

  return content
end

-- Extract project name from file content using pattern
function M.extract_name(content, pattern)
  if not content or not pattern then
    return nil
  end

  return content:match(pattern)
end

-- Check if directory should be excluded
function M.is_excluded_dir(dir, exclude_dirs)
  local basename = vim.fn.fnamemodify(dir, ":t")
  for _, excluded in ipairs(exclude_dirs) do
    if basename == excluded then
      return true
    end
  end
  return false
end

-- Check if file exists and is readable
function M.file_exists(filepath)
  return vim.fn.filereadable(filepath) == 1
end

-- Format project display name with emoji
function M.format_project_display(project)
  local config = require("monorepo.config").get()
  local project_type = config.project_types[project.type]
  local emoji = project_type and project_type.emoji or "📁"

  return emoji .. " " .. project.name .. " (" .. project.type .. ") - " .. project.path
end

-- Get relative path from root directory
function M.get_relative_path(path, root_dir)
  if path:sub(1, #root_dir) == root_dir then
    local relative = path:sub(#root_dir + 1)
    return relative:gsub("^/", "") -- Remove leading slash
  end
  return path
end

return M
