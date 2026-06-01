return {
  {
    "folke/snacks.nvim",
    opts = {
      animate = { enabled = false },
      scroll = { enabled = false },
      indent = { animate = { enabled = false } },
      -- Don't hijack netrw — `nvim <dir>` should not auto-open the explorer.
      -- The explorer is still available via :lua Snacks.explorer().
      explorer = { replace_netrw = false },
      styles = {
        terminal = {
          wo = {
            winblend = 0,
            winhighlight = "Normal:Normal,NormalFloat:Normal",
          },
        },
      },
    },
  },
}
