local ok, ts = pcall(require, 'nvim-treesitter')
if not ok then
	return
end

-- Drop leftover parsers from the frozen `master` branch (they shadow site installs)
local legacy_parsers = vim.fn.stdpath('data') .. '/lazy/nvim-treesitter/parser'
if vim.fn.isdirectory(legacy_parsers) == 1 then
	vim.fn.delete(legacy_parsers, 'rf')
end

-- nvim-treesitter `main` (Neovim 0.12+): modules API removed
ts.setup({})

local parsers = {
	'javascript',
	'lua',
	'tsx',
	'typescript',
	'css',
	'scss',
	'html',
	'go',
	'gomod',
	'gosum',
	'gowork',
	'php',
	'php_only',
	'blade',
	'bash',
}

-- async; no-op if already installed
pcall(function()
	ts.install(parsers)
end)

-- Languages where treesitter indent is known to hang / jump the cursor
-- (especially mixed PHP/HTML Bitrix templates)
local no_ts_indent = {
	php = true,
	blade = true,
	html = true,
	javascript = true,
	typescript = true,
	tsx = true,
}

-- Highlighting is provided by Neovim and must be started per buffer
vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('TreesitterHighlight', { clear = true }),
	callback = function(args)
		local ft = args.match
		if ft == '' or ft == 'CHADTree' or ft == 'TelescopePrompt' then
			return
		end
		if not pcall(vim.treesitter.start, args.buf) then
			return
		end

		-- indentexpr is experimental; on PHP templates it can teleport the
		-- cursor to line 1 on InsertEnter and freeze after the first keystroke
		if not no_ts_indent[ft] then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		else
			vim.bo[args.buf].indentexpr = ''
		end
	end,
})
