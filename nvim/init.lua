require('plugins')
require('telescope_config')
require('keymaps')

-- Comments
require('Comment').setup()

-- lualine
require('lualine').setup()

-- File Explorer
require('nvim-tree').setup()

-- Treesitter
require('nvim-treesitter.configs').setup{highlight={enable=true}}

vim.g.coc_global_extensions = {'coc-emmet', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier', 'coc-tsserver', 'coc-cmake', 'coc-discord', 'coc-elixir', 'coc-erlang_ls', 'coc-eslint', 'coc-flutter', 'coc-go', 'coc-rust-analyzer', 'coc-sh', 'coc-swagger'}

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

vim.cmd [[
  syntax enable
  colorscheme onenord
]]

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.number = true

-- open new split panes to right and below
vim.opt.splitright = true
vim.opt.splitbelow = true

-- open nvim-tree on startup
local function open_nvim_tree(data)

  -- buffer is a directory
  local directory = vim.fn.isdirectory(data.file) == 1

  if not directory then
    return
  end

  -- change to the directory
  vim.cmd.cd(data.file)

  -- open the tree
  require('nvim-tree.api').tree.open()
end

vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = open_nvim_tree })
