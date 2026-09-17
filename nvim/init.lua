
function setup()
	vim.g.mapleader = " "

	require("get_it").setup {
		plugins = {
			"nvim-treesitter/nvim-treesitter",
			"jlcrochet/vim-crystal",
			"thecodinglab/nvim-vlang",
			"catppuccin/nvim",
			"ClearAspect/OneHalf",
			"evergardentheme/nvim",
			"maxmx03/solarized.nvim",
			"ellisonleao/gruvbox.nvim",
		},
	}

	require("run_program").setup()
	if vim.fn.has("win32") == 1 then
		require("setup_shell").powershell()
	end

	-- Local config is better at the bottom to provide full access to
	-- others scripts.
	require("local_config").setup({
		startup = true,
	})

	vim.cmd[[au BufRead,BufNewFile *.sir set filetype=sir]]

	vim.cmd[[colorscheme gruvbox]]

	local terminal_background = true
	if terminal_background then
		vim.cmd[[hi Normal guibg=none]]
	end

	options()
	commands()
end

function options()
	vim.o.shada = ""

    vim.o.tabstop = 4
	vim.o.shiftwidth = 4

	vim.o.hlsearch = false
    vim.o.incsearch = true

	vim.o.number = true
	vim.o.colorcolumn = "80"
	vim.o.relativenumber = true
end

function commands()
    vim.api.nvim_create_user_command(
		"Path",
		"execute 'e ' .. stdpath('<args>')",
		{
			nargs = 1,
			complete = function(arg_lead, cmd_line, cursor_pos)
				local completes = {}
				if string.match("data", arg_lead .. "[a-zA-Z]+") then
					table.insert(completes, "data")
				end
				if string.match("config", arg_lead .. "[a-zA-Z]+") then
					table.insert(completes, "config")
				end
				return completes
			end
		}
	)

    vim.api.nvim_create_user_command(
		"Scratch",
		function()
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_open_win(buf, true, { split = "above" })
		end,
		{}
	)

	vim.api.nvim_create_user_command(
		"Todos",
		"vimgrep /- \\[ \\]/ **",
		{}
	)

	vim.api.nvim_create_user_command(
		"HTML",
		function()
			vim.api.nvim_paste([[
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Template</title>
	</head>
	<body>
		<!-- app -->
	</body>
</html>
			]], false, -1)
		end,
		{}
	)
end

setup()

