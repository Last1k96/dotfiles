return {
  -- Gruvbox Material as default colorscheme
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.gruvbox_material_enable_italic = false
      vim.g.gruvbox_material_disable_italic_comment = 1
      vim.g.gruvbox_material_foreground = "mix"
      vim.g.gruvbox_material_transparent_background = 1
    end,
  },
  -- Tell LazyVim to use gruvbox-material
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "gruvbox-material" },
  },
}
