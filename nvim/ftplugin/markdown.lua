
function replace_line(pattern, replace)
	local line = vim.api.nvim_get_current_line()
	line = string.gsub(line, pattern, replace)
	vim.api.nvim_set_current_line(line)
end

function todo_ok()
	replace_line("%[ %]", "[x]")
end

function todo_not()
	replace_line("%[x%]", "[ ]")
end

vim.api.nvim_buf_set_keymap(0, "n", "<leader>tx", "", {
	noremap = true,
	callback = todo_ok,
})

vim.api.nvim_buf_set_keymap(0, "n", "<leader>tn", "", {
	noremap = true,
	callback = todo_not,
})

