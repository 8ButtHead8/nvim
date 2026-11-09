-- vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
-- vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})

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
	local source_flag = sourceMap and '--source-map' or '--no-source-map'

	vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
		group = scss_autocomplete_group,
		pattern = { '_*.scss' },
		callback = function(args)
			local file = args.file
			local dir = vim.fn.fnamemodify(file, ':h')
			local name = vim.fn.fnamemodify(file, ':t:r'):gsub('^_', '')
			local css = dir .. '/' .. name .. '.css'

			vim.fn.system({
				'sass',
				source_flag,
				'--style=compressed',
				file,
				css,
			})
			vim.fn.system({
				'postcss',
				css,
				'--use',
				'autoprefixer',
				'-o',
				css,
			})
		end,
	})
end

-- PHP Code Sniffer
vim.api.nvim_create_augroup('PHBSCF', { clear = true })

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
