local statuslineStatus, statusline = pcall(require, 'lualine')

if not statuslineStatus then
	return
end

local uv = vim.uv or vim.loop

local cpu_icon, cpu_color = '', '#FAB795'
local mem_icon, mem_color = '󰍛', '#25B2BC'

local deviconsStatus, devicons = pcall(require, 'nvim-web-devicons')
if deviconsStatus then
	devicons.set_icon({
		nvimcpu = { icon = cpu_icon, color = cpu_color, name = 'NvimCpu' },
		nvimmem = { icon = mem_icon, color = mem_color, name = 'NvimMem' },
	})
	cpu_icon, cpu_color = devicons.get_icon_color('nvimcpu')
	mem_icon, mem_color = devicons.get_icon_color('nvimmem')
end

local stats = {
	cpu = 0,
	rss = 0,
	cpu_time = nil,
	wall = nil,
	updated = 0,
}

local sample_ns = 1e9

local function sample()
	local now = uv.hrtime()
	if stats.updated ~= 0 and (now - stats.updated) < sample_ns then
		return
	end
	stats.updated = now

	if uv.resident_set_memory then
		stats.rss = uv.resident_set_memory() or stats.rss
	end

	local usage = uv.getrusage()
	if not usage or not usage.utime or not usage.stime then
		return
	end

	local cpu_time = usage.utime.sec
		+ usage.utime.usec / 1e6
		+ usage.stime.sec
		+ usage.stime.usec / 1e6
	local wall = now / 1e9

	if stats.cpu_time then
		local dt = wall - stats.wall
		if dt > 0 then
			stats.cpu = (cpu_time - stats.cpu_time) / dt * 100
			if stats.cpu < 0 then
				stats.cpu = 0
			end
		end
	end

	stats.cpu_time = cpu_time
	stats.wall = wall
end

local function format_rss(bytes)
	local mb = bytes / (1024 * 1024)
	if mb >= 1024 then
		return string.format('%.1fG', mb / 1024)
	end
	if mb < 1 then
		return string.format('%.0fK', bytes / 1024)
	end
	return string.format('%.0fM', mb)
end

statusline.setup({
	options = {
		theme = 'horizon',
		globalstatus = true,
		icons_enabled = true,
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { 'branch', 'diff', 'diagnostics' },
		lualine_c = { 'filename' },
		lualine_x = {
			{
				function()
					sample()
					return string.format('%.1f%%%%', stats.cpu)
				end,
				icon = { cpu_icon, color = { fg = cpu_color } },
			},
			{
				function()
					sample()
					return format_rss(stats.rss)
				end,
				icon = { mem_icon, color = { fg = mem_color } },
			},
			'encoding',
			'fileformat',
			'filetype',
		},
		lualine_y = { 'progress' },
		lualine_z = { 'location' },
	},
})
