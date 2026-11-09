-- blade parser ships with nvim-treesitter; only register the filetype mapping
vim.filetype.add({
	pattern = {
		['.*%.blade%.php'] = 'blade',
	},
})
