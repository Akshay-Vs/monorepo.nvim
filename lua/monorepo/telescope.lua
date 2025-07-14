local utils = require("monorepo.utils")
local scanner = require("monorepo.scanner")

local M = {}

-- Open project in neotree
local function open_project(project)
  -- Change to project directory
  vim.cmd("cd " .. vim.fn.fnameescape(project.path))

  -- Open neotree
  vim.cmd("Neotree show")

  -- Show notification with emoji
  local config = require("monorepo.config").get()
  local project_type = config.project_types[project.type]
  local emoji = project_type and project_type.emoji or "📁"

  vim.notify(emoji .. " Opened project: " .. project.name .. " (" .. project.type .. ")")
end

-- Create telescope picker for projects
function M.show_projects()
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    vim.notify("Telescope is not installed", vim.log.levels.ERROR)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local projects = scanner.get_projects_with_metadata()

  if #projects == 0 then
    vim.notify("No projects found in monorepo", vim.log.levels.WARN)
    return
  end

  -- Sort projects by name
  table.sort(projects, function(a, b)
    return a.name < b.name
  end)

  pickers
      .new({}, {
        prompt_title = "📁 Monorepo Projects",
        finder = finders.new_table({
          results = projects,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.display_name,
              ordinal = entry.name .. " " .. entry.type .. " " .. entry.relative_path,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              open_project(selection.value)
            end
          end)

          -- Add additional mappings
          map("i", "<C-o>", function()
            local selection = action_state.get_selected_entry()
            if selection then
              actions.close(prompt_bufnr)
              -- Open project in current buffer instead of neotree
              vim.cmd("cd " .. vim.fn.fnameescape(selection.value.path))
              vim.notify("📁 Changed to project: " .. selection.value.name)
            end
          end)

          return true
        end,
      })
      :find()
end

return M
