local blanklineStatus, blankline = pcall(require, 'ibl')

if (not blanklineStatus) then
	return
end

local hooks = require('ibl.hooks')

hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
	vim.api.nvim_set_hl(0, 'IndentBlanklineIndent1', { fg = "#E5C07B" })
	vim.api.nvim_set_hl(0, 'IndentBlanklineIndent2', { fg = "#98C379" })
	vim.api.nvim_set_hl(0, 'IndentBlanklineIndent3', { fg = "#56B6C2" })
end)

blankline.setup({
	enabled = true,
	indent = {
		smart_indent_cap = true,
		char = "│",
		tab_char = '│',
		highlight = {
			"IndentBlanklineIndent1",
			"IndentBlanklineIndent2",
			"IndentBlanklineIndent3",
		},
	},
	scope = {
		enabled = true,
	},
	exclude = {
		filetypes = {
			"CHADthee",
		},
		buftypes = {
			'terminal',
			'nofile',
		},
	},
})
