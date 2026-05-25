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

-- System clipboard. Default to "unnamedplus" so y/d/p route through the +
-- register. Under SSH there's no local X/Wayland to talk to, so swap the
-- provider for Neovim's built-in OSC 52 escape — the terminal (e.g. Windows
-- Terminal) puts the yanked text into the host clipboard. Tmux passes the
-- escape through via `set-clipboard on` in .tmux.conf.
vim.opt.clipboard = "unnamedplus"
if vim.env.SSH_TTY ~= nil then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
  }
end
