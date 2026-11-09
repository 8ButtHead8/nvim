local barsStatus, bars = pcall(require, 'barbar')

if not barsStatus then
	return
end

bars.setup({
	icons = {
		gitsigns = {
			added = { enabled = true, icon = '+' },
			changed = { enabled = true, icon = '~' },
			deleted = { enabled = true, icon = '-' },
		},
	},
})

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map('n', '<C-,>', '<Cmd>BufferPrevious<CR>', opts)
map('n', '<C-.>', '<Cmd>BufferNext<CR>', opts)
map('n', '<C-d>', '<Cmd>BufferClose<CR>', opts)
map('n', '<leader>bp', '<Cmd>BufferPick<CR>', { desc = 'Buffer pick' })
