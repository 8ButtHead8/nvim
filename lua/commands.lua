vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})

vim.api.nvim_create_user_command('ScssSource', function()
	setSCSSCommand(true)
end, {})

vim.api.nvim_create_user_command('ScssNosource', function()
	setSCSSCommand(false)
end, {})

vim.api.nvim_create_user_command('ScssDis', function()
	vim.api.nvim_create_augroup('scss_autocomplete', { clear = true })
end, {})

function setSCSSCommand(sourceMap)
	local scss_autocomplete_group = vim.api.nvim_create_augroup('scss_autocomplete', { clear = true })
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = scss_autocomplete_group,
		pattern = { "_*.scss" },
		command = "silent !sass " ..
				(sourceMap and "--source-map " or "--no-source-map ") .. "--style=compressed %:p %:s?_??:r.css",
	})
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = scss_autocomplete_group,
		-- pattern = { "*.css" },
		pattern = { "_*.scss" },
		command = "silent !postcss %:s?_??:r.css --use autoprefixer -o %:s?_??:r.css",
	})
end
