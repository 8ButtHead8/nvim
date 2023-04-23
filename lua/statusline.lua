local statuslineStatus, statusline = pcall(require, 'lualine')

if (not statuslineStatus) then
	return
end

statusline.setup({
	options = {
		theme = 'horizon',
	},
})
