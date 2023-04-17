local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local global = vim.g

global.coq_settings = {
	auto_start = 'shut-up',
	display = {
		icons = {
			mode = 'long',
		},
	},
}

require('lazy').setup({
	{
		'neovim/nvim-lspconfig',
		config = function()
			require('lsp')
		end,
	},
	{
		'lukas-reineke/lsp-format.nvim',
	},
	{
		'ms-jpq/coq_nvim',
		build = ':COQdeps',
		branch = 'coq'
	},
	{
		'ms-jpq/coq.artifacts',
		branch = 'artifacts',
	},
	{
		'ms-jpq/coq.thirdparty',
		branch = '3p',
	},
	{
		'ms-jpq/chadtree',
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
		config = function()
			require('treesitter')
		end,
	},
	{
		'windwp/nvim-ts-autotag',
		config = function ()
			require('autotag')
		end
	},
	{
		'numToStr/Comment.nvim',
		config = function()
			require('comment')
		end,
	},
	{
		'sainnhe/sonokai',
		config = function()
			require('colorscheme')
		end,
	},
})

