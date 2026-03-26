local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.cursorline = true

-- Behavior
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.splitright = true
opt.splitbelow = true
opt.mouse = "a"
opt.updatetime = 250
opt.timeoutlen = 300

-- Whitespace display
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
