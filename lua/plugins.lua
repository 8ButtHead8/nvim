local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local out = vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable',
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
			{ out, 'WarningMsg' },
			{ '\nPress any key to exit...' },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Must be set before coq loads (coq v2 has no auto_start)
vim.g.coq_settings = {
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
}

vim.g.chadtree_settings = {
	options = {
		show_hidden = true,
	},
	view = {
		width = 36,
	},
}

require('lazy').setup({
	-- coq docs: lspconfig + coq must start at startup (lazy = false)
	{
		'neovim/nvim-lspconfig',
		lazy = false,
		dependencies = {
			{ 'ms-jpq/coq_nvim', branch = 'coq', build = ':COQdeps' },
			{ 'ms-jpq/coq.artifacts', branch = 'artifacts' },
			{ 'ms-jpq/coq.thirdparty', branch = '3p' },
		},
		config = function()
			require('lsp')
		end,
	},
	{
		'ms-jpq/chadtree',
		cmd = 'CHADopen',
		keys = {
			{ '<leader>e', '<cmd>CHADopen<cr>', desc = 'File tree' },
		},
		build = ':CHADdeps',
		branch = 'chad',
	},
	{
		'mason-org/mason.nvim',
		lazy = false,
		dependencies = {
			'mason-org/mason-lspconfig.nvim',
		},
		build = ':MasonUpdate',
		config = function()
			require('masonlsp')
		end,
	},
	{
		-- Neovim 0.12 requires the rewritten `main` branch (master is frozen / Nvim ≤0.11)
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false,
		build = ':TSUpdate',
		config = function()
			require('tsblade')
			require('treesitter')
		end,
	},
	{
		'windwp/nvim-ts-autotag',
		event = { 'BufReadPre', 'BufNewFile' },
		config = function()
			require('autotag')
		end,
	},
	{
		'numToStr/Comment.nvim',
		event = { 'BufReadPost', 'BufNewFile' },
		opts = {},
	},
	{
		'nvim-tree/nvim-web-devicons',
		lazy = true,
	},
	{
		'nvim-lualine/lualine.nvim',
		event = 'VeryLazy',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			require('statusline')
		end,
	},
	{
		'sainnhe/sonokai',
		lazy = false,
		priority = 1000,
		config = function()
			require('colorscheme')
		end,
	},
	{
		'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',
		event = { 'BufReadPost', 'BufNewFile' },
		config = function()
			require('blankline')
		end,
	},
	{
		'gelguy/wilder.nvim',
		event = 'CmdlineEnter',
		dependencies = {
			'romgrk/fzy-lua-native',
		},
		build = function()
			vim.cmd('silent! UpdateRemotePlugins')
		end,
		config = function()
			require('cmdline')
		end,
	},
	{
		'lewis6991/gitsigns.nvim',
		event = { 'BufReadPre', 'BufNewFile' },
		opts = {
			signcolumn = true,
			numhl = true,
			attach_to_untracked = true,
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = 'eol',
				delay = 300,
				ignore_whitespace = false,
			},
			current_line_blame_formatter = '<author>, <author_time:%R> • <summary>',
			on_attach = function(bufnr)
				local gs = require('gitsigns')
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
				end
				map('n', ']c', function()
					if vim.wo.diff then
						vim.cmd.normal({ ']c', bang = true })
					else
						gs.nav_hunk('next')
					end
				end, 'Next git hunk')
				map('n', '[c', function()
					if vim.wo.diff then
						vim.cmd.normal({ '[c', bang = true })
					else
						gs.nav_hunk('prev')
					end
				end, 'Prev git hunk')
				map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
				map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
				map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
				map('n', '<leader>hb', function()
					gs.blame_line({ full = true })
				end, 'Blame line')
			end,
		},
	},
	{
		'romgrk/barbar.nvim',
		event = 'BufEnter',
		dependencies = {
			'lewis6991/gitsigns.nvim',
			'nvim-tree/nvim-web-devicons',
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		config = function()
			require('bars')
		end,
	},
	{
		'sindrets/diffview.nvim',
		cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewClose' },
		keys = {
			{ '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview open' },
			{ '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'Diffview file history' },
			{ '<leader>gc', '<cmd>DiffviewClose<cr>', desc = 'Diffview close' },
		},
	},
	{
		'nvim-telescope/telescope.nvim',
		version = '*',
		cmd = 'Telescope',
		keys = {
			{ '<leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Telescope find files' },
			{ '<leader>fg', function() require('telescope.builtin').live_grep() end, desc = 'Telescope live grep' },
			{ '<leader>fb', function() require('telescope.builtin').buffers() end, desc = 'Telescope buffers' },
			{ '<leader>fh', function() require('telescope.builtin').help_tags() end, desc = 'Telescope help tags' },
		},
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
		opts = {},
	},
	{
		'mfussenegger/nvim-dap',
		lazy = true,
	},
	{
		'rcarriga/nvim-dap-ui',
		dependencies = {
			'mfussenegger/nvim-dap',
			'nvim-neotest/nvim-nio',
			'theHamsta/nvim-dap-virtual-text',
		},
		keys = {
			{ '<F5>', function() require('dap').continue() end, desc = 'DAP continue' },
			{ '<F10>', function() require('dap').step_over() end, desc = 'DAP step over' },
			{ '<F11>', function() require('dap').step_into() end, desc = 'DAP step into' },
			{ '<F12>', function() require('dap').step_out() end, desc = 'DAP step out' },
			{ '<Leader>b', function() require('dap').toggle_breakpoint() end, desc = 'DAP breakpoint' },
			{ '<Leader>du', function() require('dapui').toggle() end, desc = 'DAP UI toggle' },
		},
		config = function()
			require('dap-conf')
		end,
	},
	{
		'theHamsta/nvim-dap-virtual-text',
		lazy = true,
		opts = {},
	},
	-- Full phpactor tooling (LSP binary also ensured via Mason)
	'phpactor/phpactor',
	{
		'praem90/nvim-phpcsf',
		ft = 'php',
		config = function()
			require('phpcs').setup({
				phpcs = 'phpcs',
				phpcbf = 'phpcbf',
				standard = 'PSR12',
			})
		end,
	},
})
