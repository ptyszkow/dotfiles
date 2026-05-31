local dap = require("dap")

vim.fn.sign_define("DapBreakpoint", {
	text = "●",
	texthl = "DapBreakpoint",
	linehl = "",
	numhl = "",
})
vim.fn.sign_define("DapBreakpointCondition", {
	text = "",
	texthl = "DapBreakpointCondition",
	linehl = "",
	numhl = "",
})
vim.fn.sign_define("DapBreakpointRejected", {
	text = "",
	texthl = "DapBreakpointRejected",
	linehl = "",
	numhl = "",
})
vim.fn.sign_define("DapLogPoint", {
	text = "",
	texthl = "DapLogPoint",
	linehl = "",
	numhl = "",
})
vim.fn.sign_define("DapStopped", {
	text = "󰁕",
	texthl = "DapStopped",
	linehl = "DapStoppedLine",
	numhl = "",
})

-- 2. Define the colors (the "colorful" part)
-- You can change "Red", "Orange", etc. to any hex code like "#FF0000"
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "Red" })
vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "Orange" })
vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "DarkRed" })
vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "Blue" })
vim.api.nvim_set_hl(0, "DapStopped", { fg = "Cyan" })
vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#333333" }) -- Dark gray background for the line

-- Python setup
dap.adapters.python = {
	type = "executable",
	command = "python3",
	args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		pythonPath = function()
			-- 1. Check for venv in workspace
			local cwd = vim.fn.getcwd()
			if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
				return cwd .. "/.venv/bin/python"
			elseif vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
				return cwd .. "/venv/bin/python"
			end

			-- 2. Fallback to system python
			return vim.fn.exepath("python3") or "python"
		end,
	},
}
-- .NET / C# setup
dap.adapters.netcoredbg = {
	type = "executable",
	command = "netcoredbg",
	args = { "--interpreter=vscode" },
	options = { detached = false },
}

dap.configurations.cs = {
	{
		type = "netcoredbg",
		name = "Launch - console_test (net9.0)",
		request = "launch",
		program = function()
			return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/net9.0/console_test.dll", "file")
		end,
	},
	{
		type = "netcoredbg",
		name = "Attach to process",
		request = "attach",
		processId = function()
			local output = vim.fn.system("ps -aux | grep dotnet")
			print("Available dotnet processes:\n" .. output)
			return tonumber(vim.fn.input("Process ID: "))
		end,
	},
}
-- Keybindings
vim.keymap.set("n", "<F5>", function()
	dap.continue()
end, { desc = "Debug: Continue" })
vim.keymap.set("n", "<F10>", function()
	dap.step_over()
end, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", function()
	dap.step_into()
end, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", function()
	dap.step_out()
end, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<Leader>b", function()
	dap.toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<Leader>B", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Conditional Breakpoint" })
