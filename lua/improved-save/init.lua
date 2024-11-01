-- Function to check for errors in a specific buffer
local function check_errors(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()  -- Use the current buffer if none is provided

  -- Check if there is an LSP client attached to the buffer
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  if #clients == 0 then
    return false  -- No LSP attached, no errors to check
  end

  local diagnostics = vim.diagnostic.get(bufnr)

  for _, diag in ipairs(diagnostics) do
    if diag.severity == vim.diagnostic.severity.ERROR then
      return true  -- Errors found
    end
  end
  return false  -- No errors
end

-- Command to save and check for errors in all buffers
function _G.save_and_check_all()
  local has_errors = false
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if check_errors(bufnr) then
      has_errors = true
      break
    end
  end

  if not has_errors then
    vim.cmd("wqa")
  else
    vim.cmd("Trouble diagnostics  win.position=right  focus=true filter.severity=vim.diagnostic.severity.ERROR")
  end
end

-- Command to save and check for errors in the current buffer
function _G.save_and_check_current()
  if not check_errors() then
    vim.cmd("w")
  else
    vim.cmd("Trouble diagnostics  win.position=right focus=true filter.severity=vim.diagnostic.severity.ERROR")
  end
end

-- Set up commands
local function setup_commands()
  vim.api.nvim_create_user_command("SaveAndCheckAll", save_and_check_all, {})
  vim.api.nvim_create_user_command("SaveAndCheckCurrent", save_and_check_current, {})
end

-- Autocommand to notify on leaving insert mode
local function setup_autocmds()
  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      if check_errors() then
        vim.cmd("Trouble diagnostics focus=true  win.position=right  filter.severity=vim.diagnostic.severity.ERROR")
      end
    end,
  })
end

-- Plugin setup function
local function setup()
  setup_commands()
  setup_autocmds()
end

return {
  setup = setup,
}
