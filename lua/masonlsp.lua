local masonStatus, mason = pcall(require, 'mason')
local masonLSPStatus, masonLSP = pcall(require, 'mason-lspconfig')

if (not masonStatus or not masonLSPStatus) then
	print('Mason plugins are not loaded')
	return
end

mason.setup()
masonLSP.setup({
	ensure_installed = {
		'ts_ls',
		'lua_ls',
		'cssls',
		'html',
		'efm',
		'gopls',
		'pyright',
		'intelephense',
	},
	automatic_installation = true
})
