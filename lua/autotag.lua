local autotagStatus, autotag = pcall(require, 'nvim-ts-autotag')

if (not autotagStatus) then
	return
end

autotag.setup({})
