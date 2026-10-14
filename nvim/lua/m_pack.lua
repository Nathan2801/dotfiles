
-- Get-it.
--
-- Download plugins from github.
-- -

local pub = {}

function echo(msg, err)
	vim.api.nvim_echo({{msg}}, true, { err = err or false })
end

function default_output_path()
	local config = vim.fn.stdpath("config")
	return vim.fs.joinpath(config, "pack/plugins")
end

function git_clone_command(plugin)
	return {
		"git",
		"clone",
		"--depth=1",
		plugin:url(),
		plugin:output_path()
	}
end

local Plugin = {}
Plugin.__index = Plugin

function Plugin:new(path)
	local t = t or {}
	setmetatable(t, self)
	self.path = path or ""
	self.autoload = true
	return t
end

function Plugin:url()
	return "https://github.com/" .. self.path
end

function Plugin:name()
	return self.path:match("%w+/(%w+)") 
end

function Plugin:hash()
	return vim.fn.sha256(self.path):sub(0, 6)
end

function Plugin:folder_name()
	return string.format("%s-%s", self:hash(), self:name())
end

function Plugin:output_path()
	local path = default_output_path()
	if self.autoload then
		path = vim.fs.joinpath(path, "/start")
	else
		path = vim.fs.joinpath(path, "/opt")
	end
	return vim.fs.joinpath(path, self:folder_name())
end

function Plugin:installed()
	for _, dir in ipairs(list_plugins()) do
		local suffix = dir:sub(0, 6)
		if suffix == self:hash() then
			return true
		end
	end
	return false
end

function Plugin:install()
	echo("Installing plugin: " .. self.path)

	local cmd = git_clone_command(self)
	local status = vim.system(cmd, {
		text = true
	}):wait()

	if status.code ~= 0 then
		local cmd_str = vim.fn.join(cmd, " ")
		echo("Failed to execute: " .. cmd_str .. "\n", true)
		echo("  Stdout: " .. status.stdout .. "\n", true)
		echo("  Stderr: " .. status.stdout .. "\n", true)
	end
end

function list_plugins()
	local path = default_output_path()
	local path_opt = vim.fs.joinpath(path, "/opt")
	local path_start = vim.fs.joinpath(path, "/start")

	local files = {}
	for name, type in vim.fs.dir(path_opt) do
		table.insert(files, name)
	end
	for name, type in vim.fs.dir(path_start) do
		table.insert(files, name)
	end
	return files
end

function pub.setup(t)
	local opts = t or {}
	opts.plugins = opts.plugins or {} 

	local output_path = default_output_path()
	if not vim.uv.fs_stat(output_path) then
		local err = vim.uv.fs_mkdir(output_path, 777)
		if not err then
			echo("Directory created: " .. output_path, false)
		else
			echo("Failed to create directory: " .. output_path, true)
		end
	end

	local should_reload = false

	for _, path in ipairs(opts.plugins) do
		local plugin = Plugin:new(path)
		if not plugin:installed() then
			should_reload = true
			plugin:install()
		end
	end

	if should_reload then
		vim.cmd("runtime! plugin/**/*.{vim,lua}")
	end
end

return pub
