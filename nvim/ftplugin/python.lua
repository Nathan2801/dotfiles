
vim.treesitter.start()

vim.api.nvim_set_option_value("makeprg", "python %", {
	scope = "local",
	buf = 0,
})

-- expands the word under cursor into a class getter method
vim.api.nvim_buf_create_user_command(0,
	"Getter",
	[[normal "tdiwadef get_"tpa(self):return self._"tp]],
	{ nargs = 0 }
)

-- expands the word under cursor into a class setter method
vim.api.nvim_buf_create_user_command(0,
	"Setter",
	[[normal "tdiwadef set_"tpa(self, value):self._"tpa = value]],
	{ nargs = 0 }
)

