local commentStatus, comment = pcall(require, 'Comment')

if (not commentStatus) then
	return
end

comment.setup({})
