local peekStatus, peek = pcall(require, 'peek')

if (not peekStatus) then
	return
end

peek.setup()
