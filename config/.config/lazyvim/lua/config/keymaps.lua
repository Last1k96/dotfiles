-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>sf", LazyVim.pick("files"), { desc = "Find Files" })
vim.keymap.del("n", "<leader>ff")

-- Centered scrolling: keep cursor in middle of screen
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })

-- Move selected lines up/down in visual mode
vim.keymap.set("v", "<C-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "<C-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

-- Replace word under cursor globally
vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word globally" })

-- Switch between windows with Ctrl+Arrow
vim.keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows with Alt+Arrow
vim.keymap.set("n", "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
vim.keymap.set("n", "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })
vim.keymap.set("n", "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase height" })
vim.keymap.set("n", "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease height" })

-- Disable accidental command-line window
vim.keymap.set("n", "q:", "<nop>", { desc = "Disable q: window" })

-- JIRA link: extract number from word under cursor, copy JIRA URL
-- Requires a lua/jira_config.lua file with: return { prefix = "https://jira.example.com/browse/PROJ-" }
vim.api.nvim_create_user_command("CopyJiraLink", function()
  local word = vim.fn.expand("<cWORD>")
  local number = word:match("%d+")
  if number then
    local ok, jira = pcall(require, "jira_config")
    local prefix = ok and jira.prefix or "https://jira.example.com/browse/PROJ-"
    local link = prefix .. number
    vim.fn.setreg("+", link)
    vim.notify("Copied: " .. link)
  else
    vim.notify("No number found under cursor", vim.log.levels.WARN)
  end
end, {})
vim.keymap.set("n", "<leader>yj", "<cmd>CopyJiraLink<cr>", { desc = "Copy JIRA link" })
