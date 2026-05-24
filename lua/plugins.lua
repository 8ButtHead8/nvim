local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.api.nvim_set_var("coq_settings", {
	auto_start = 'shut-up',
	display = {
		icons = {
			mode = 'long',
		},
	},
	clients = {
		snippets = {
			user_path = './snippets/',
		},
	},
})

vim.api.nvim_set_var("chadtree_settings", {
	options = {
		show_hidden = true,
	},
	view = {
		width = 36,
	}
})

require('lazy').setup({
	{
		'neovim/nvim-lspconfig',
		event = "BufReadPre", -- загружать при открытии файла
		config = function()
			require('lsp')
		end,
	},
	{
		'lukas-reineke/lsp-format.nvim',
		event = "BufWritePre", -- загружать при сохранении файла
	},
	{
		'ms-jpq/coq_nvim',
		event = "InsertEnter", -- загружать при входе в режим вставки
		build = ':COQdeps',
		branch = 'coq'
	},
	{
		'ms-jpq/coq.artifacts',
		event = "InsertEnter", -- загружать при входе в режим вставки
		branch = 'artifacts',
	},
	{
		'ms-jpq/coq.thirdparty',
		event = "InsertEnter", -- загружать при входе в режим вставки
		branch = '3p',
	},
	{
		'ms-jpq/chadtree',
		cmd = "CHADopen", -- загружать при вызове команды CHADopen
		build = ':CHADdeps',
		branch = 'chad',
	},
	{
		'williamboman/mason.nvim',
		dependencies = {
			'williamboman/mason-lspconfig.nvim',
		},
		build = ':MasonUpdate',
		config = function()
			require('masonlsp')
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		branch = "master",
		event = "BufReadPost", -- загружать после чтения буфера
		config = function()
			-- require('tsblade')
			require('treesitter')
		end,
	},
	{
		'windwp/nvim-ts-autotag',
		event = "InsertEnter", -- загружать при входе в режим вставки
		config = function()
			require('autotag')
		end
	},
	{
		'numToStr/Comment.nvim',
		event = "InsertEnter", -- загружать при входе в режим вставки
		config = function()
			require('comment')
		end,
	},
	{
		'kyazdani42/nvim-web-devicons',
		event = "VimEnter", -- загружать при запуске Neovim
	},
	{
		'nvim-lualine/lualine.nvim',
		event = "VimEnter", -- загружать при запуске Neovim
		config = function()
			require('statusline')
		end,
	},
	{
		'sainnhe/sonokai',
		config = function()
			require('colorscheme')
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "BufRead", -- загружать при чтении буфера
		config = function()
			require('blankline')
		end,
	},
	{
		"8ButtHead8/peek.nvim",
		cmd = "PeekOpen", -- загружать при вызове команды PeekOpen
		build = 'deno task --quiet build:fast',
		config = function()
			require('mdpreview')
		end,
	},
	{
		"gelguy/wilder.nvim",
		event = "CmdlineEnter", -- загружать при входе в командную строку
		dependencies = {
			'romgrk/fzy-lua-native',
		},
		config = function()
			require('cmdline')
		end,
	},
	{
		'romgrk/barbar.nvim',
		event = "BufEnter",           -- загружать при входе в буфер
		dependencies = {
			'lewis6991/gitsigns.nvim',  -- git status
			'nvim-tree/nvim-web-devicons', -- file icons
		},
		init = function() vim.g.barbar_auto_setup = false end,
		config = function()
			require('bars')
		end,
	},
	{
		"sindrets/diffview.nvim",
	},
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim'
		}
	},
	"mfussenegger/nvim-dap",          -- Debug Adapter Protocol
	"rcarriga/nvim-dap-ui",           -- UI для DAP
	"nvim-neotest/nvim-nio",
	"theHamsta/nvim-dap-virtual-text", -- Виртуальный текст с отладочной информацией
	-- "nvim-telescope/telescope-dap.nvim", -- Интеграция с Telescope
	"phpactor/phpactor",              -- PHP language server
	{
		'praem90/nvim-phpcsf',
		config = function()
			require("phpcs").setup({
				phpcs = "phpcs",
				phpcbf = "phpcbf",
				standard = "PSR12"
			})
		end,
	},

})

require('dap-conf')
