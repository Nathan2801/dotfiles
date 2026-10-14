vim.g.mapleader      = " "
vim.o.shada          = ""
vim.o.tabstop        = 4
vim.o.shiftwidth     = 4
vim.o.hlsearch       = false
vim.o.incsearch      = true
vim.o.number         = true
vim.o.colorcolumn    = "80"
vim.o.relativenumber = true

require("m_pack").setup {
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

require("m_make").setup()

--
-- Local config is better at the bottom to provide full access to
-- others scripts
--
require("m_conf").setup({
	startup = true,
})

vim.cmd[[colorscheme gruvbox]]
--
-- Unknown language developed by me
--
vim.cmd[[au BufRead,BufNewFile *.sir set filetype=sir]]

--
-- Transparent background
--
vim.cmd[[hi Normal guibg=none]]

--
-- Initializes treesitter
--
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = "*",
	callback = function(args)
		local syntax = vim.api.nvim_get_option_value("syntax", {
			buf = args.buf,
		})
		local has_ts = pcall(vim.treesitter.language.inspect, syntax)
		if has_ts then
			vim.treesitter.start()
			vim.api.nvim_set_option_value("indentexpr", "v:lua.require'nvim-treesitter'.indentexpr()", {
				buf = args.buf,
			})
		end
	end
})

--
-- Utility to quick access neovim paths
--
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
