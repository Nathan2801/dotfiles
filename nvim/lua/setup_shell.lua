
-- Setup shells.
-- -

local pub = {}

function pub.mingw()
	error("setup_mingw: not implemented")
end

function pub.powershell()
	vim.o.shell = "powershell"
	vim.o.shellquote = ""
	vim.o.shellslash = false
	vim.o.shellcmdflag = "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new(); $PSDefaultParameterValues.Add('Out-File:Encoding', 'utf8');"
	vim.o.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
	vim.o.shellredir = ', fakepath 2>&1 | %%{"$_"} | Out-File %s; exit $LastExitCode'
	vim.o.shellquote = ""
	vim.o.shellxquote = ""
end

return pub

