vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'lmburns/kimbox'
  use 'neovim/nvim-lspconfig'
  use 'nvim-tree/nvim-web-devicons'
  use 'nvim-tree/nvim-tree.lua'
  use 'nvim-lua/plenary.nvim'
  use 'mfussenegger/nvim-dap'
  use 'rcarriga/nvim-dap-ui'
  use 'numToStr/Comment.nvim'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use 'simrat39/rust-tools.nvim'
  use 'tpope/vim-fugitive'
  use 'romgrk/barbar.nvim'
  use 'famiu/bufdelete.nvim'
  use 'nvim-lualine/lualine.nvim'
  use 'tveskag/nvim-blame-line'
  use { 'mg979/vim-visual-multi', branch = 'master' }
  use 'wakatime/vim-wakatime'

end)
