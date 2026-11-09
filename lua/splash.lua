vim.opt.shortmess:append('I')

local render = require('render')

local function model_path()
	local src = debug.getinfo(1, 'S').source
	if src:sub(1, 1) == '@' then
		src = src:sub(2)
	end
	return (src:gsub('lua/splash%.lua$', 'models/skull.obj'))
end

local max = math.max
local min = math.min
local floor = math.floor

local ns = vim.api.nvim_create_namespace('splash')
local timers = {}
local baseline
-- Marker so a split can be told apart from a normal window. CHADtree reads
-- number/relativenumber/winhighlight off the current window when it starts,
-- so those stay untouched and the gutter is hidden only through statuscolumn.
local GUTTER = '%#SplashArt#'

local aim_yaw, aim_pitch = 0, 0
local yaw, pitch = 0, 0
local saved_mouse, saved_move
local mouse_on = false
local seen_mouse = false

local function release_mouse()
	if not mouse_on then
		return
	end
	vim.o.mouse = saved_mouse
	vim.o.mousemoveevent = saved_move
	mouse_on = false
	seen_mouse = false
	aim_yaw, aim_pitch, yaw, pitch = 0, 0, 0, 0
end

local function grab_mouse()
	if mouse_on then
		return
	end
	saved_mouse = vim.o.mouse
	saved_move = vim.o.mousemoveevent
	vim.o.mouse = 'a'
	vim.o.mousemoveevent = true
	mouse_on = true
end

-- Nose turns toward the pointer. Angles stay put when the pointer leaves the window.
local function track_mouse(win)
	if not seen_mouse or not mouse_on or not vim.api.nvim_win_is_valid(win) then
		return
	end
	local pos = vim.fn.getmousepos()
	if pos.winid ~= win or pos.wincol < 1 then
		return
	end
	local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_win_get_height(win)
	if width < 2 or height < 2 then
		return
	end
	local x = (pos.wincol - 0.5) / width - 0.5
	local y = (pos.winrow - 0.5) / height - 0.5
	aim_yaw = min(0.9, max(-0.9, x * 1.75))
	aim_pitch = min(0.85, max(-0.85, -y * 1.7))
end

local function apply_hl()
	local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = true })
	local fg = vim.g.splash_color
	if type(fg) ~= 'string' or fg == '' then
		local accent = vim.api.nvim_get_hl(0, { name = 'String', link = true })
		fg = accent.fg or '#9ed072'
	elseif fg:match('^%x%x%x%x%x%x$') then
		fg = '#' .. fg
	end
	vim.api.nvim_set_hl(0, 'SplashArt', {
		fg = fg,
		bg = normal.bg,
	})
end

local function capture(win)
	return {
		statuscolumn = vim.wo[win].statuscolumn,
		list = vim.wo[win].list,
		wrap = vim.wo[win].wrap,
		scrolloff = vim.wo[win].scrolloff,
		sidescrolloff = vim.wo[win].sidescrolloff,
		cursorline = vim.wo[win].cursorline,
		fillchars = vim.api.nvim_get_option_value('fillchars', { scope = 'local', win = win }),
	}
end

local function restore(win, opts)
	if opts == nil or not vim.api.nvim_win_is_valid(win) then
		return
	end
	vim.wo[win].statuscolumn = opts.statuscolumn
	vim.wo[win].list = opts.list
	vim.wo[win].wrap = opts.wrap
	vim.wo[win].scrolloff = opts.scrolloff
	vim.wo[win].sidescrolloff = opts.sidescrolloff
	vim.wo[win].cursorline = opts.cursorline
	vim.api.nvim_set_option_value('fillchars', opts.fillchars, { scope = 'local', win = win })
end

local function scrub(win)
	if baseline == nil or not vim.api.nvim_win_is_valid(win) then
		return
	end
	local buf = vim.api.nvim_win_get_buf(win)
	if vim.bo[buf].filetype == 'splash' then
		return
	end
	if vim.wo[win].statuscolumn ~= GUTTER then
		return
	end
	restore(win, baseline)
end

local function stop(buf)
	local timer = timers[buf]
	if timer and not timer:is_closing() then
		timer:stop()
		timer:close()
	end
	timers[buf] = nil
end

local drawing = false

local function present(buf)
	if drawing then
		return
	end
	if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= 'splash' then
		stop(buf)
		return
	end
	local win = vim.fn.bufwinid(buf)
	if win == -1 then
		return
	end
	track_mouse(win)
	yaw = yaw + (aim_yaw - yaw) * 0.22
	pitch = pitch + (aim_pitch - pitch) * 0.22

	local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_win_get_height(win)
	local cols = max(20, min(width, 320))
	local rows = max(12, min(height, 160))
	drawing = true
	local ok, frame = pcall(render.draw, cols, rows, yaw, pitch, { shader = true })
	drawing = false
	if not ok or type(frame) ~= 'table' or #frame == 0 then
		return
	end
	if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= 'splash' then
		return
	end
	local left = floor((width - cols) / 2)
	local top = floor((height - rows) / 2)
	if left > 0 then
		local pad = string.rep(' ', left)
		for i = 1, rows do
			frame[i] = pad .. frame[i]
		end
	end
	if top > 0 then
		for i = rows, 1, -1 do
			frame[i + top] = frame[i]
		end
		for i = 1, top do
			frame[i] = ''
		end
	end
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, frame)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for i = 0, #frame - 1 do
		if frame[i + 1] ~= '' then
			vim.api.nvim_buf_set_extmark(buf, ns, i, 0, {
				end_row = i + 1,
				hl_group = 'SplashArt',
				hl_eol = false,
			})
		end
	end
	vim.bo[buf].modifiable = false
end

local function dismiss(key)
	return function()
		local win = vim.api.nvim_get_current_win()
		if baseline then
			restore(win, baseline)
		end
		release_mouse()
		vim.cmd('enew')
		if key then
			vim.api.nvim_feedkeys(key, 'n', false)
		end
	end
end

local function show()
	if vim.fn.argc() > 0 then
		return
	end
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].filetype ~= '' or vim.api.nvim_buf_get_name(buf) ~= '' then
		return
	end
	if vim.fn.line2byte(vim.fn.line('$')) ~= -1 then
		return
	end

	apply_hl()
	render.start(model_path())
	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'wipe'
	vim.bo[buf].swapfile = false
	vim.bo[buf].buflisted = false
	vim.bo[buf].filetype = 'splash'

	local win = vim.api.nvim_get_current_win()
	baseline = capture(win)
	vim.wo[win].statuscolumn = GUTTER
	vim.wo[win].list = false
	vim.wo[win].wrap = false
	vim.wo[win].scrolloff = 0
	vim.wo[win].sidescrolloff = 0
	vim.wo[win].cursorline = false
	vim.opt_local.fillchars:append({ eob = ' ' })
	grab_mouse()

	present(buf)
	vim.api.nvim_win_set_cursor(win, { 1, 0 })

	local timer = vim.uv.new_timer()
	timers[buf] = timer
	timer:start(40, 40, vim.schedule_wrap(function()
		present(buf)
	end))

	vim.api.nvim_create_autocmd('BufWinLeave', {
		buffer = buf,
		callback = function()
			restore(vim.api.nvim_get_current_win(), baseline)
		end,
	})

	vim.api.nvim_create_autocmd('BufWipeout', {
		buffer = buf,
		once = true,
		callback = function()
			stop(buf)
			render.stop()
			release_mouse()
			vim.schedule(function()
				for _, w in ipairs(vim.api.nvim_list_wins()) do
					scrub(w)
				end
			end)
		end,
	})

	for _, key in ipairs({ 'i', 'a', 'o', 'I', 'A', 'O', 'c', 'C', 's', 'S' }) do
		vim.keymap.set('n', key, dismiss(key), { buffer = buf, nowait = true, silent = true })
	end
	vim.keymap.set('n', '<CR>', dismiss(nil), { buffer = buf, nowait = true, silent = true })

	local ignore = {
		'<LeftMouse>', '<LeftRelease>', '<LeftDrag>', '<2-LeftMouse>',
		'<RightMouse>', '<RightRelease>', '<RightDrag>',
		'<MiddleMouse>', '<MiddleRelease>', '<MiddleDrag>',
		'<ScrollWheelUp>', '<ScrollWheelDown>',
	}
	for _, key in ipairs(ignore) do
		vim.keymap.set('n', key, '<Nop>', { buffer = buf, nowait = true, silent = true })
	end
	vim.keymap.set('n', '<MouseMove>', function()
		seen_mouse = true
		track_mouse(vim.api.nvim_get_current_win())
	end, { buffer = buf, nowait = true, silent = true })
end

vim.api.nvim_create_autocmd({ 'WinNew', 'BufWinEnter' }, {
	callback = function()
		scrub(vim.api.nvim_get_current_win())
	end,
})

vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		vim.schedule(show)
	end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
	callback = function()
		if vim.bo.filetype == 'splash' then
			apply_hl()
		end
	end,
})
