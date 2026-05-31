local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation (4 spaces for C++/Python/CUDA)
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- No line wrap — common in shader/kernel code
opt.wrap = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.colorcolumn = "100"
opt.showmode = false
opt.laststatus = 3   -- global statusline
opt.showtabline = 2  -- always show bufferline

-- Splits open right/below
opt.splitright = true
opt.splitbelow = true

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"

-- Performance
opt.updatetime = 200
opt.timeoutlen = 300

-- Completion
opt.completeopt = "menuone,noselect,noinsert"

-- Clipboard (OSC 52 for SSH/tmux)
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}
opt.clipboard = "unnamedplus"

-- Folds via treesitter (new Neovim 0.12 built-in); disabled by default (open with zR)
opt.foldmethod = "expr"
opt.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false
opt.foldlevel  = 99

-- Mouse
opt.mouse = "a"

-- Visible whitespace
opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }
opt.list = true

-- Diagnostics
vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "always" },
})
