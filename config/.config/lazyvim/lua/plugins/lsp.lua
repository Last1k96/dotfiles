return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- clangd with best-practice flags + clang-tidy
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=iwyu",
            "--fallback-style=llvm",
          },
        },
      },
    },
  },
}
