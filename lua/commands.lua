vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})

vim.api.nvim_create_user_command('ScssSource', function()
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		pattern = { "*.scss" },
		command = "silent !sass --style=compressed %:p %:s?_??:r.css",
	})
end, {})

vim.api.nvim_create_user_command('ScssNosource', function()
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		pattern = { "*.scss" },
		command = "silent !sass --no-source-map --style=compressed %:p %:s?_??:r.css",
	})
end, {})
