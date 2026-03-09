-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Tab/indent: 4 spaces (override LazyVim's 2)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Keep cursor centered with generous scroll margin
vim.opt.scrolloff = 16

-- Disable line wrapping
vim.opt.wrap = false

-- Fast escape sequence handling (fixes arrow key delay in terminal)
vim.opt.ttimeoutlen = 5

-- Register .mlir files as MLIR filetype
vim.filetype.add({ extension = { mlir = "mlir" } })
