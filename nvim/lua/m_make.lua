
-- Run program.
--
-- Helps you run commands inside the editor.
-- -

local pub = {}

local g = {
	buffer = nil,
	command = "nmake",
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
	return g.command:gsub("%%", vim.fn.expand("%"))
end

-- Executes command synchronously using `vim.system()`.
function execute_command(cmd_table, buffer)
	local now = os.clock()
	local ok, err_or_result = pcall(function()
		return vim.system(cmd_table):wait()
	end)
	local time_spend = os.clock() - now

	if not ok then
		vim.api.nvim_echo({
			{string.format("Unable to run command: %s\n", command_expanded)},
			{err_or_result}
		}, false, {})
		return
	end

	local system_result = err_or_result
	if system_result.code ~= 0 then
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {
			"Command failed with code: " .. system_result.code
		})

		local lines = {} -- used to set the quick-fix list.
		local stderr = string.gsub(system_result.stderr, "\r\n", "\n")

		for line in string.gmatch(stderr, "[^\n]+") do
			table.insert(lines, line)
			vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {line})
		end
		-- setup the quickfix list.
		vim.fn.setqflist({}, "r", {
			title = "stderr",
			lines = lines,
		})
	end

	local stdout = string.gsub(system_result.stdout, "\r\n", "\n")
	for line in string.gmatch(stdout, "[^\n]+") do
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {line})
	end

	update_window_header(buffer, cmd_table, time_spend)
end

-- Executes command asynchronously using `vim.fn.jobstart()`.
-- FIXME: async is still blocking neovim.
function execute_command_async(cmd_table, buffer)
	local paste = function(_, chunk)
		for _, line in ipairs(chunk) do
			if line ~= "\r" then
				line = line:gsub("\r", "")
				vim.api.nvim_buf_set_lines(buffer, -1, -1, false, { line })
			end
		end
		update_window_header(buffer, cmd_table, 0)
	end

	local _ = vim.fn.jobstart(cmd_table, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = paste,
		on_stderr = paste,
	})
end

function clean_window(buffer)
	vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
end

function update_window_header(buffer, command, time_spend)
	vim.api.nvim_buf_set_lines(buffer, 0, 2, false, {
		string.format(
			"-*- %s (took %.4fs) -*-", os.date("%d-%m-%Y %H:%M:%S"),
			time_spend
		),
		string.format(
			"Command: %s",
			table.concat(command, " ")
		)
	})
end

-- This function parses a string into a list of arguments for `vim.system`, it
-- splits everything by space but handles strings that contains spaces, but you
-- can get in trouble if you have a string that contains spaces and the escaped
-- quote that defines the string.
function parse_arguments(s)
	local arguments = {}
	local parsing_string = ""
	local is_single_quote = false

	for argument in string.gmatch(s, "[^ ]+") do
		if string.len(parsing_string) > 0 then
			parsing_string = parsing_string .. " " .. argument
			local quote_to_match = "\"$"
			if is_single_quote then
				quote_to_match = "'$"
			end
			if string.find(argument, quote_to_match) then
				table.insert(arguments, parsing_string)
				parsing_string = ""
			end
			goto continue
		end
		if string.find(argument, "^\"") ~= nil then
			parsing_string = parsing_string .. argument
			is_single_quote = false
		elseif string.find(argument, "^'") ~= nil then
			parsing_string = parsing_string .. argument
			is_single_quote = true
		else
			table.insert(arguments, argument)
		end
		::continue::
	end
	return arguments
end

function run(opts)
	local opts = opts or {}
	local command = opts.command or nil
	local run_async = opts.async or false

	local buffer = get_buffer()
	local window = get_or_create_window()

	if type(command) == "string" and command ~= "" then
		g.command = command
	end

	local cmd_expanded = expand_command(g.command)
	local cmd_table = parse_arguments(cmd_expanded)

	clean_window(buffer)
	update_window_header(buffer, cmd_table, 0)

	if not run_async then
		execute_command(cmd_table, buffer)
	else
		execute_command_async(cmd_table, buffer)
	end
end

function pub.setup(t)
	vim.api.nvim_create_user_command("Run", function(t)
		run({
			command = vim.fn.join(t.fargs, " "),
		})
	end, { nargs = "*", complete="file" })

	vim.api.nvim_create_user_command("RunAsync", function(t)
		run({
			command = vim.fn.join(t.fargs, " "),
			async = true,
		})
	end, { nargs = "*", complete="file" })

	vim.api.nvim_create_user_command("RunSet", function(t)
		g.command = vim.fn.join(t.fargs, " ")
	end, { nargs = "*", complete="file" })

	vim.api.nvim_create_user_command("RunWindowAbove", function(t)
		g.window_placement = "above"
	end, { nargs = 0 })

	vim.api.nvim_create_user_command("RunWindowBelow", function(t)
		g.window_placement = "below"
	end, { nargs = 0 })

	vim.api.nvim_set_keymap("n", "<leader>r", ":Run<cr>", {})
end

return pub

