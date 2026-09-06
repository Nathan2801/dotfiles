
-- Local config.
--
-- This script aims to privide a simple way to configure neovim by
-- each project, there could be something that already exists but I
-- don't found it, so I gonna write my own.
-- -

local pub = {}

function default_project_path()
	-- In the future we can make something more intelligent but for now using
	-- the current path should work just fine.
	return "."
end

function load_config_file()
	local path = default_project_path()
	for name, type in vim.fs.dir(path) do
		if name == ".nvim.lua" then
			dofile(path .. "/" .. name)
		end
	end
end

function load_config_file_safe()
	local ok, err = pcall(load_config_file)
	if not ok then
		vim.api.nvim_echo({
			{"Failed to load init file\n"},
			{err},
		}, true, { err = true })
	end
end

function pub.setup(opts)
	local startup = opts.startup or false
	if startup then
		load_config_file_safe()
	end

	vim.api.nvim_create_user_command(
		"LocalConfig",
		load_config_file_safe,
		{ nargs = 0 }
	)
end

return pub

