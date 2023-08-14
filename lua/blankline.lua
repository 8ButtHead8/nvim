local blanklineStatus, blankline = pcall(require, 'indent_blankline')

if (not blanklineStatus) then
	return
end

vim.cmd('highlight IndentBlanklineIndent1 guifg=#E5C07B gui=nocombine')
vim.cmd('highlight IndentBlanklineIndent2 guifg=#98C379 gui=nocombine')
vim.cmd('highlight IndentBlanklineIndent2 guifg=#56B6C2 gui=nocombine')

blankline.setup({
	show_end_of_line = true,
	space_char_blankline = " ",
	show_current_context = true,
	show_current_context_start = true,
	show_trailing_blankline_indent = false,
	use_treesitter = true,

	char_list = { '│' },

	filetype_exclude = {
		"CHADthee",
	},

	buftype_exclude = {
		'terminal',
		'nofile',
	},

	char_highlight_list = {
		"IndentBlanklineIndent1",
		"IndentBlanklineIndent2",
		"IndentBlanklineIndent3",
	},
})
