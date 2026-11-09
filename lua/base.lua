local opt = vim.opt

vim.g.mapleader = '\\'
vim.g.maplocalleader = '\\'

-- Foreground of the startup model. Hex, for example '#9ed072'.
-- vim.g.splash_color = '#9ed072'
vim.g.splash_color = '#ca7896'

vim.scriptencoding = 'utf-8'

opt.mouse = ""
opt.encoding = 'utf-8'
opt.fileencoding = 'utf-8'
opt.clipboard = 'unnamedplus'
opt.updatetime = 250
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true

opt.number = true
opt.relativenumber = true
opt.signcolumn = 'yes'

opt.title = true
opt.autoindent = true
opt.smartindent = true
opt.hlsearch = true
opt.backup = false
opt.writebackup = true
opt.showcmd = true
opt.laststatus = 3
opt.expandtab = false
opt.scrolloff = 10
opt.smarttab = true
opt.breakindent = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.ai = true
opt.si = true
opt.wrap = true
opt.backspace = 'indent,eol,start'
opt.swapfile = false

opt.cursorline = true
opt.termguicolors = true
opt.wildoptions = 'pum'
opt.pumblend = 5
opt.background = 'dark'

opt.showmatch = true
opt.list = true
opt.listchars = {
	extends = '»',
	precedes = '«',
	trail = '•',
	nbsp = '×',
	eol = '↴',
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = "php",
	callback = function()
		vim.bo.tabstop = 4
		vim.bo.shiftwidth = 4
		vim.bo.softtabstop = 4
		vim.bo.expandtab = true
		-- Avoid treesitter/cindent jumps on InsertEnter in mixed PHP templates
		vim.bo.indentexpr = ''
		vim.bo.indentkeys = ''
	end,
})
