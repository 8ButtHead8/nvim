-- Load lspconfig defaults into vim.lsp.config.*
local lspconfig_ok = pcall(require, 'lspconfig')
if not lspconfig_ok then
	return
end

-- coq v2 attaches on require/setup
pcall(require, 'coq')

-- Third-party / builtin coq sources (must be configured separately)
-- Skip builtin/php: vimscript omnifunc is very slow on Bitrix/HTML+PHP templates
pcall(function()
	require('coq_3p')({
		{ src = 'nvimlua', short_name = 'nLUA' },
		{ src = 'builtin/css' },
		{ src = 'builtin/html' },
		{ src = 'builtin/js' },
		{ src = 'dap' },
	})
end)

-- Neovim 0.12 defaults: virtual_text = false
vim.diagnostic.config({
	virtual_text = {
		spacing = 2,
		source = 'if_many',
	},
	signs = true,
	underline = true,
	severity_sort = true,
	update_in_insert = false,
	float = {
		border = 'rounded',
		source = true,
	},
})

local on_attach = function(client, bufnr)
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
	end

	-- Built-in defaults cover K / grn / gra / grr / gri / grt; add common jumps
	-- Keep Vim's `gi` (last insert pos); use gI for implementations
	map('n', 'gd', vim.lsp.buf.definition, 'LSP definition')
	map('n', 'gD', vim.lsp.buf.declaration, 'LSP declaration')
	map('n', 'gI', vim.lsp.buf.implementation, 'LSP implementation')
	map('n', '<leader>D', vim.lsp.buf.type_definition, 'LSP type definition')
	map('n', '<leader>rn', vim.lsp.buf.rename, 'LSP rename')
	map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, 'LSP code action')
	map('n', 'gl', vim.diagnostic.open_float, 'Line diagnostics')
	map('n', '<leader>q', vim.diagnostic.setloclist, 'Diagnostics loclist')

	-- Inlay hints: skip phpactor (noisy + can lag on large templates)
	if client.name ~= 'phpactor' and client:supports_method('textDocument/inlayHint') then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	-- Format-on-save: skip phpactor (rewrites/slow on mixed PHP templates)
	if client.name ~= 'phpactor' and client:supports_method('textDocument/formatting') then
		vim.api.nvim_create_autocmd('BufWritePre', {
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({
					bufnr = bufnr,
					async = false,
				})
			end,
		})
	end
end

-- Prefer lspconfig defaults; only override what we customize
for _, server in ipairs({ 'lua_ls', 'ts_ls', 'html', 'gopls' }) do
	vim.lsp.config(server, { on_attach = on_attach })
end

vim.lsp.config('phpactor', {
	on_attach = on_attach,
	-- Safer for mixed HTML/PHP template files
	init_options = {
		['language_server_worse_reflection.enabled'] = false,
		['language_server_completion.trim_leading_dollar'] = true,
	},
})

local prettier = {
	formatCommand = 'prettierd ${INPUT}',
	formatStdin = true,
}

vim.lsp.config('efm', {
	filetypes = { 'css', 'scss', 'less', 'json', 'jsonc' },
	on_attach = on_attach,
	init_options = { documentFormatting = true },
	settings = {
		languages = {
			css = { prettier },
			scss = { prettier },
			json = { prettier },
			jsonc = { prettier },
		},
	},
})

-- Attach keymaps/inlay even for servers without other overrides
for _, server in ipairs({ 'cssls', 'pyright' }) do
	vim.lsp.config(server, { on_attach = on_attach })
end

vim.lsp.enable({
	'lua_ls',
	'ts_ls',
	'cssls',
	'html',
	'efm',
	'gopls',
	'pyright',
	'phpactor',
})
