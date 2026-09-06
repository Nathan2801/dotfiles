
vim.api.nvim_set_option_value("expandtab", false, {
	scope = "local",
	buf = 0,
})

vim.api.nvim_buf_set_keymap(0, "n", "sn", "", {
	callback = function()
		local word = vim.fn.expand("<cword>")
		if word == "ready" then
			vim.cmd("normal diw")
			vim.api.nvim_put({
				"func _ready() -> void:",
				"\tpass"
			}, "c", true, true)
		elseif word == "twarn" then
			vim.cmd("normal diw")
			vim.api.nvim_put({
				"func _get_configuration_warnings() -> PackedStringArray:",
				"\tvar w: PackedStringArray",
				"\treturn w"
			}, "c", true, true)
		else
			print(string.format("Unknown snippet '%s'", word))
		end
	end
})

