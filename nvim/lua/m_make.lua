-- Run program.
--
-- Runs an asynchronously command (current using 'sh') and redirects the output
-- to a localized buffer.
local pub = {}

local g = {
	buffer = nil,
	cmd = "make",
	window_placement = "above",
}

function get_buffer()
	if g.buffer == nil or not vim.api.nvim_buf_is_valid(g.buffer) then
		g.buffer = vim.api.nvim_create_buf(false, true)
	end
	return g.buffer
end

function get_or_create_window()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == g.buffer then
			return nil
		end
	end
	return vim.api.nvim_open_win(g.buffer, false, {
		win = 0,
		split = g.window_placement,
		height = 10,
	})
end

function expand_command()
	return g.cmd:gsub("%%", vim.fn.expand("%"))
end

-- TODO: handle when command is already running.
-- TODO: redirect error information to quickfix list.
function execute_command(cmd, buffer)
	local stdout = vim.uv.new_pipe()
	local stderr = vim.uv.new_pipe()

	local spawn_time = os.clock()
	-- TODO: allow us to configure shell.
	local handle, pid = vim.uv.spawn("sh", {
		args = {"-c", cmd},
		stdio = {nil, stdout, stderr},
	}, function(code, signal)
		local exit_time = os.clock()
		vim.schedule(function()
			local time_spend = exit_time - spawn_time
			update_header(buffer, cmd, code, time_spend)
		end)
	end)

	vim.uv.read_start(stdout, function(err, data)
		if not err and data then
			vim.schedule(function()
				local data = data:gsub("\n", "")
				vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {data})
			end)
		end
	end)

	vim.uv.read_start(stderr, function(err, data)
		if not err and data then
			vim.schedule(function()
				local data = data:gsub("\n", "")
				vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {data})
			end)
		end
	end)
end

function clear_buffer(buffer)
	vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
end

function update_header(buf, cmd, exit, time)
	local time = time or 0

	local exit_text = "?"
	if exit ~= nil then
		exit_text = string.format("%d", exit)
	end

	local date = os.date("%d-%m-%Y %H:%M:%S")
	local header_fmt = "-*- %s (exit %s) (took %.4fs) -*-"

	vim.api.nvim_buf_set_lines(buf, 0, 2, false, {
		string.format(header_fmt, date, exit_text, time),
		string.format("Command: %s", cmd),
	})
end

function run(opts)
	local opts = opts or {}

	local cmd = opts.cmd or ""
	if cmd ~= "" then
		g.cmd = cmd
	end

	local buffer = get_buffer()
	local _ = get_or_create_window()

	cmd = expand_command(g.cmd)

	clear_buffer(buffer)
	update_header(buffer, cmd)
	execute_command(cmd, buffer)
end

function pub.setup(t)
	vim.api.nvim_create_user_command(
		"Run",
		function(t)
			run({ cmd = vim.fn.join(t.fargs, " ") })
		end, { nargs = "*", complete = "file" }
	)

	vim.api.nvim_create_user_command(
		"RunSet",
		function(t)
			g.cmd = vim.fn.join(t.fargs, " ")
		end,
		{ nargs = "*", complete = "file" }
	)

	vim.api.nvim_create_user_command(
		"RunWindowAbove",
		function(t)
			g.window_placement = "above"
		end,
		{ nargs = 0 }
	)

	vim.api.nvim_create_user_command(
		"RunWindowBelow",
		function(t)
			g.window_placement = "below"
		end,
		{ nargs = 0 }
	)

	vim.api.nvim_set_keymap("n", "<leader>r", ":Run<cr>", {})
end

return pub
