return {
  -- add onenord
  { "maxmx03/solarized.nvim" },

  -- Configure LazyVim to load onenord
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized",
    },
  },
}
