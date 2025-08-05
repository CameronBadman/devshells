-- =============================================================================
-- python/init.lua - Python Neovim Profile
-- =============================================================================

-- Python language profile - only LSP, completion, and treesitter
local api = _G.profile_api

if not api then
  vim.notify('Profile API not available', vim.log.levels.ERROR)
  return
end

print("🐍 Loading Python profile...")
vim.notify('Python profile: Starting initialization', vim.log.levels.INFO)

-- =============================================================================
-- LSP CONFIGURATION
-- =============================================================================

-- Register Python LSP server (pyright)
api.lsp.register_server('pyright', {
  root_dir = function(fname)
    local util = require('lspconfig.util')
    return util.root_pattern(
      'pyproject.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
      'pyrightconfig.json',
      '.git'
    )(fname)
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'workspace',
        useLibraryCodeForTypes = true,
        typeCheckingMode = 'basic',
      }
    }
  }
})

print("🔧 Python profile: Registered pyright LSP server")
vim.notify('Python profile: pyright LSP server registered', vim.log.levels.INFO)

-- =============================================================================
-- TREESITTER CONFIGURATION
-- =============================================================================

-- Register Python treesitter parser
api.treesitter.add_parser('python')

print("🌳 Python profile: Added treesitter parser")
vim.notify('Python profile: treesitter parser added', vim.log.levels.INFO)

-- =============================================================================
-- COMPLETION SOURCES
-- =============================================================================

-- Add Python-specific completion sources
api.cmp.add_source({
  name = 'nvim_lsp',
  priority = 1000,
  keyword_length = 1,
})

print("💬 Python profile: Added LSP completion source")

-- Python buffer completion (only from Python files)
api.cmp.add_source({
  name = 'buffer',
  priority = 500,
  keyword_length = 3,
  option = {
    get_bufnrs = function()
      local bufs = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and 
           vim.bo[buf].filetype == 'python' then
          table.insert(bufs, buf)
        end
      end
      return bufs
    end,
  },
})

print("📝 Python profile: Added Python buffer completion")
vim.notify('Python profile: Completion sources configured', vim.log.levels.INFO)

print("✅ Python profile loaded successfully!")
vim.notify('🐍 Python development environment ready', vim.log.levels.INFO)
