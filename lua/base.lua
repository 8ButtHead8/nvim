local opt = vim.opt

vim.scriptencoding = 'utf-8'

opt.mouse = ""
opt.encoding = 'utf-8'
opt.fileencoding = 'unf-8'

opt.number = true
opt.relativenumber = true

opt.title = true
opt.autoindent = true
opt.smartindent = true
opt.hlsearch = true
opt.backup = false
opt.writebackup = true
opt.showcmd = true
opt.laststatus = 2
opt.expandtab = false
opt.scrolloff = 10
opt.smarttab = true
opt.breakindent = true
opt.shiftwidth = 2
opt.tabstop = 2
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
	lead = ' ',
	space = ' ',
	tab = '  ',
	nbsp = '×',
	eol = '↴'
}
