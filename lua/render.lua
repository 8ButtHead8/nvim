-- Client for the Go ASCII rasterizer (`bin/ascii-render`).
local job = 0
local leftover = ''
local needed = 0
local collected = {}

local function config_root()
	local src = debug.getinfo(1, 'S').source
	if src:sub(1, 1) == '@' then
		src = src:sub(2)
	end
	return src:gsub('lua/render%.lua$', '')
end

local function bin_path()
	return config_root() .. 'bin/ascii-render'
end

local function stale(bin)
	if vim.fn.executable(bin) ~= 1 then
		return true
	end
	local bt = vim.fn.getftime(bin)
	for _, name in ipairs({ 'main.go', 'render.go', 'obj.go' }) do
		if vim.fn.getftime(config_root() .. 'go/' .. name) > bt then
			return true
		end
	end
	return false
end

local function ensure_bin()
	local bin = bin_path()
	if not stale(bin) then
		return bin
	end
	if vim.fn.executable('go') ~= 1 then
		if vim.fn.executable(bin) == 1 then
			return bin
		end
		return nil
	end
	local root = config_root()
	vim.fn.mkdir(root .. 'bin', 'p')
	vim.fn.system({ 'go', 'build', '-C', root .. 'go', '-o', bin, '.' })
	if vim.v.shell_error ~= 0 then
		if vim.fn.executable(bin) == 1 then
			return bin
		end
		return nil
	end
	if vim.fn.executable(bin) == 1 then
		return bin
	end
	return nil
end

local function on_stdout(_, data)
	if type(data) ~= 'table' then
		return
	end
	for i = 1, #data do
		if i == #data then
			leftover = leftover .. data[i]
		else
			local line = leftover .. data[i]
			leftover = ''
			if needed > 0 and #collected < needed then
				collected[#collected + 1] = line
			end
		end
	end
end

local function stop()
	if job ~= 0 then
		pcall(vim.fn.jobstop, job)
	end
	job = 0
	leftover = ''
	needed = 0
	collected = {}
end

local function start(model)
	stop()
	local bin = ensure_bin()
	if not bin then
		return
	end
	job = vim.fn.jobstart({ bin, model }, {
		stdin = 'pipe',
		stdout_buffered = false,
		on_stdout = on_stdout,
		on_exit = function()
			job = 0
		end,
	})
	if job <= 0 then
		job = 0
	end
end

local function draw(cols, rows, yaw, pitch, opts)
	if job <= 0 then
		return {}
	end
	opts = opts or {}
	needed = rows
	collected = {}
	leftover = ''
	local shader = 1
	if opts.shader == false then
		shader = 0
	end
	vim.fn.chansend(job, string.format('%d %d %.10f %.10f %d\n', cols, rows, yaw, pitch, shader))
	local ok = vim.wait(400, function()
		return #collected >= rows
	end, 2)
	if not ok then
		return {}
	end
	local lines = {}
	for i = 1, rows do
		lines[i] = collected[i]
	end
	return lines
end

return {
	start = start,
	stop = stop,
	draw = draw,
}
