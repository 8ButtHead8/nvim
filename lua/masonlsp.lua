local mason_ok, mason = pcall(require, 'mason')
local mason_lsp_ok, mason_lsp = pcall(require, 'mason-lspconfig')

if not mason_ok or not mason_lsp_ok then
	print('Mason plugins are not loaded')
	return
end

mason.setup()
mason_lsp.setup({
	ensure_installed = {
		'ts_ls',
		'lua_ls',
		'cssls',
		'html',
		'efm',
		'gopls',
		'pyright',
		'phpactor',
	},
	-- Servers are enabled manually in lua/lsp.lua
	automatic_enable = false,
})
