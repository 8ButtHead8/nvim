vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})

vim.api.nvim_create_user_command('ScssSource', function()
	local scss_autocomplete_group = vim.api.nvim_create_augroup('scss_autocomplete', { clear = true })
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = scss_autocomplete_group,
		pattern = { "*.scss" },
		command = "silent !sass --style=compressed %:p %:s?_??:r.css",
	})
end, {})

vim.api.nvim_create_user_command('ScssNosource', function()
	local scss_autocomplete_group = vim.api.nvim_create_augroup('scss_autocomplete', { clear = true })
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = scss_autocomplete_group,
		pattern = { "*.scss" },
		command = "silent !sass --no-source-map --style=compressed %:p %:s?_??:r.css",
	})
end, {})
