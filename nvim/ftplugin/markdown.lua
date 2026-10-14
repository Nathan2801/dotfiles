
function replace_in_line(pattern, replace)
	local line = vim.api.nvim_get_current_line()
	line = string.gsub(line, pattern, replace)
	vim.api.nvim_set_current_line(line)
end

function todo_ok()
	replace_in_line("%[ %]", "[x]")
end

function todo_not()
	replace_in_line("%[x%]", "[ ]")
end

function todo_risk()
	replace_in_line("%* %[(.)%] (.*)", "* [%1] ~%2~")
end

function todo_unrisk()
	replace_in_line("~", "")
end

vim.api.nvim_buf_set_keymap(0, "n", "<leader>to", "", {
	noremap = true,
	callback = todo_ok,
})

vim.api.nvim_buf_set_keymap(0, "n", "<leader>tn", "", {
	noremap = true,
	callback = todo_not,
})

vim.api.nvim_buf_set_keymap(0, "n", "<leader>tr", "", {
	noremap = true,
	callback = todo_risk,
})

vim.api.nvim_buf_set_keymap(0, "n", "<leader>tu", "", {
	noremap = true,
	callback = todo_unrisk,
})

