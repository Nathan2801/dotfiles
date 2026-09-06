
vim.treesitter.start()

-- Get all methods from the yanked text.
vim.api.nvim_set_keymap("n", "<leader>gm", "", {
	callback = function(t)
		local reg = vim.fn.getreg('"')
		local pat = string.format("%s) \\w\\+(", reg)
		local cmd = string.format("vimgrep /%s/ %%", pat)
		return vim.cmd(cmd .. "| copen")
	end
})

