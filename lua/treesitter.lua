local tsStatus, ts = pcall(require, 'nvim-treesitter.configs')

if (not tsStatus) then
	return
end

ts.setup({
	ensure_installed = {
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
	},
	auto_install = true,
	highlight = {
		enable = true,
	},
})
