vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})

vim.api.nvim_create_user_command('ScssSource', function()
	setSCSSCommand(true)
end, {})

vim.api.nvim_create_user_command('ScssNosource', function()
	setSCSSCommand(false)
end, {})

vim.api.nvim_create_user_command('ScssDis', function()
	vim.api.nvim_create_augroup('scss_autocomplete', { clear = true })
end, {})

function setSCSSCommand(sourceMap)
	local scss_autocomplete_group = vim.api.nvim_create_augroup('scss_autocomplete', { clear = true })
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = scss_autocomplete_group,
		pattern = { "_*.scss" },
		command = "silent !sass " ..
				(sourceMap and "--source-map " or "--no-source-map ") .. "--style=compressed %:p %:s?_??:r.css",
	})
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = scss_autocomplete_group,
		-- pattern = { "*.css" },
		pattern = { "_*.scss" },
		command = "silent !postcss %:s?_??:r.css --use autoprefixer -o %:s?_??:r.css",
	})
end

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- PHP Code Sniffer
vim.api.nvim_create_augroup("PHBSCF", { clear = true })

--[[ vim.api.nvim_create_autocmd(
  {"BufWritePost", "BufReadPost", "InsertLeave"},
  {
    pattern = "*.php",
    group = "PHBSCF",
    callback = function()
      require('phpcs').cs()
    end
  }
)

vim.api.nvim_create_autocmd(
  {"BufWritePost"},
  {
    pattern = "*.php",
    group = "PHBSCF",
    callback = function()
      require('phpcs').cbf()
    end
  }
) ]]

vim.api.nvim_create_user_command('Wf', function()
	local buf = vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(buf)
	if filename:match('%.php$') then
		vim.cmd('write')
		require('phpcs').cs()
		require('phpcs').cbf()
	else
		vim.cmd('write')
	end
end, {})
