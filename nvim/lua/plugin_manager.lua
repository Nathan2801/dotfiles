
-- Get Plugin.
--
-- Download neovim plugins from github.
-- -

local pub = {}

-- Wrapper around nvim_echo.
function echo(msg, err)
	vim.api.nvim_echo({{msg}}, true, { err = err or false })
end

-- Returns the default plugin output path.
function default_output_path()
	local data = vim.fn.stdpath("config")
	data = data .. "\\pack\\plugins"
	return data
end

-- Plugin download parameters.
function Plugin(args)
	local path = args.path
	local args = vim.fn.split(path, "/")

	return {
		path = path,
		author = args[1],
		plugin_name = args[2],
		autoload = args.autoload or true,
	}
end

-- Prefix path with github link prefix.
function plugin_url(plugin)
	return "https://github.com/" .. plugin.path
end

-- Returns a directory valid unique name.
function plugin_folder(plugin)
	return plugin.author .. "--" .. plugin.plugin_name
end

-- Returns a git from it's full unique name.
function plugin_path_from_file_name(name)
	local args = vim.fn.split(name, "--")
	if args[1] == nil or args[2] == nil then
		err_msg = string.format("Invalid plugin path: '%s'", name)
		error(err_msg)
	end
	return args[1] .. "/" .. args[2]
end

-- Construct the output plugin path from git type.
function plugin_output_path(plugin)
	local path = default_output_path()
	if plugin.autoload then
		path = path .. "\\start"
	else
		path = path .. "\\opt"
	end
	path = path .. "\\" .. plugin_folder(plugin)
	return path
end

-- Construct the git command from git.
function plugin_command(plugin)
	return {
		"git",
		"clone",
		"--depth=1",
		plugin_url(plugin),
		plugin_output_path(plugin)
	}
end

-- Get all installed plugins names.
function get_plugin_directory_files()
	local path = default_output_path()
	local files = {}

	for name, type in vim.fs.dir(path .. "\\opt") do
		table.insert(files, name)
	end
	for name, type in vim.fs.dir(path .. "\\start") do
		table.insert(files, name)
	end
	return files
end

-- Returns whether plugin is installed or not.
function is_plugin_installed(plugin)
	for _, file_name in ipairs(get_plugin_directory_files()) do
		local plugin_path = plugin_path_from_file_name(file_name)
		if plugin == plugin_path then
			return true
		end
	end
	return false
end

-- Install a plugin.
function install_plugin(plugin)
	echo("Installing plugin: " .. plugin.path)

	local cmd = plugin_command(plugin)
	local status = vim.system(cmd, { text = true }):wait()

	if status.code ~= 0 then
		echo("Failed to execute: " .. cmd .. "\n", true)
		echo("  Stdout: " .. status.stdout .. "\n", true)
		echo("  Stderr: " .. status.stdout .. "\n", true)
	end
end

-- Get git setup function.
function pub.setup(t)
	local opts = t or {}
	opts.plugins = opts.plugins or {} 

	for _, plugin in ipairs(opts.plugins) do
		if not is_plugin_installed(plugin) then
			install_plugin(Plugin { path = plugin })
		end
	end
end

return pub

