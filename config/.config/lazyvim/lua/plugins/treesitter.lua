return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash", "c", "cpp", "diff", "html", "lua",
        "luadoc", "markdown", "markdown_inline",
        "vim", "vimdoc",
      },
      -- Disable highlighting for very large files (>100MB)
      highlight = {
        disable = function(_, buf)
          local max_filesize = 100 * 1024 * 1024 -- 100MB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          return ok and stats and stats.size > max_filesize
        end,
      },
    },
  },
}
