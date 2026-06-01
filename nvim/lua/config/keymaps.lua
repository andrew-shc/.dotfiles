local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Resize splits
map("n", "<C-Up>",    ":resize +2<CR>",          { desc = "Increase height" })
map("n", "<C-Down>",  ":resize -2<CR>",          { desc = "Decrease height" })
map("n", "<C-Left>",  ":vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })

-- Buffer navigation
map("n", "<S-l>", ":bnext<CR>",     { desc = "Next buffer" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Prev buffer" })
local function close_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local alt = vim.fn.bufnr("#")
  if alt ~= -1 and alt ~= buf and vim.api.nvim_buf_is_loaded(alt) then
    vim.api.nvim_set_current_buf(alt)
  else
    vim.cmd("bprevious")
  end
  vim.api.nvim_buf_delete(buf, {})
end

map("n", "<leader>bd", close_buffer, { desc = "Close buffer" })
map("n", "<C-q>",      close_buffer, { desc = "Close buffer" })

-- Move lines
map("n", "<A-j>", ":m .+1<CR>==",       { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==",       { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv",  { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv",  { desc = "Move selection up" })

-- Center on scroll/search
map("n", "<C-d>", "<C-d>zz",   { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz",   { desc = "Scroll up centered" })
map("n", "n",     "nzzzv",     { desc = "Next result centered" })
map("n", "N",     "Nzzzv",     { desc = "Prev result centered" })

-- Indenting keeps selection
map("v", "<",  "<gv", { desc = "Indent left" })
map("v", ">",  ">gv", { desc = "Indent right" })

-- Misc
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear highlight" })
map({ "n", "i", "v" }, "<C-s>", "<Esc>:w<CR>", { desc = "Save" })
map("n", "<leader>qq", ":qa<CR>", { desc = "Quit all" })
map("v", "p", '"_dP', { desc = "Paste without clobbering register" })

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev,  { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic float" })

-- Exit terminal mode
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal" })

-- Convenience: open Lazy and Mason from anywhere
map("n", "<leader>L",  ":Lazy<CR>",      { desc = "Lazy" })
map("n", "<leader>M",  ":Mason<CR>",     { desc = "Mason" })
map("n", "<leader>H",  ":Dashboard<CR>", { desc = "Home dashboard" })

-- Kitty notification (manual trigger — useful after any long shell command)
map("n", "<leader>zn", function()
  require("util").notify_kitty("Neovim", "Done!")
end, { desc = "Notify Kitty" })
