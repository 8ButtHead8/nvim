local cmdlineStatus, cmdline = pcall(require, 'wilder')

if (not cmdlineStatus) then
	return
end

cmdline.setup({ modes = { ':', '?' } })

cmdline.set_option('pipeline', {
	cmdline.branch(
		cmdline.cmdline_pipeline({
			fuzzy = 2,
			fuzzy_filter = cmdline.lua_fzy_filter(),
		}),
		cmdline.vim_search_pipeline()
	)
})

cmdline.set_option('renderer', cmdline.popupmenu_renderer(
	cmdline.popupmenu_border_theme({
		highlights = {
			accent = cmdline.make_hl('WilderAccent', 'Pmenu', { { a = 1 }, { a = 1 }, { foreground = '#ff507a' } }),
			border = 'Normal',
		},
		highlighter = cmdline.lua_fzy_highlighter(),
		border = 'rounded',
	})
))
