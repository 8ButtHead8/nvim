vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})

vim.api.nvim_create_user_command('ScssSource', function()
	setSCSSCommand(true)
end, {})

vim.api.nvim_create_user_command('ScssNosource', function()
	setSCSSCommand(false)
end, {})

function setSCSSCommand(sourceMap)
	local scss_autocomplete_group = vim.api.nvim_create_augroup('scss_autocomplete', { clear = true })
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = scss_autocomplete_group,
		pattern = { "*.scss" },
		command = "!sass " ..
				(sourceMap and "--source-map " or "--no-source-map ") .. "--style=compressed %:p %:s?_??:r.css",
	})
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = scss_autocomplete_group,
		pattern = { "*.scss" },
		command = "!postcss %:r.css --use autoprefixer -o %:r.css",
	})
end
