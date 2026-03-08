return {
  -- Neogit: in-editor git interface (lazygit is already built into LazyVim)
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    keys = {
      { "<leader>ng", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
    config = true,
  },

  -- Toggle git blame
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      { "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle git blame" },
    },
  },

  -- Custom lazygit keymap (LazyVim default is <leader>gg)
  {
    "LazyVim/LazyVim",
    keys = {
      { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    },
  },
}
