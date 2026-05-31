return {
	"nvim-neotest/neotest",
	tag = "v5.7.0",
	dependencies = {
		"Issafalcon/neotest-dotnet",
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-dotnet")
			}
		})
	end,
	keys = {
		{
			"<leader>ts",
			function()
				require("neotest").summary.toggle()
			end,
			mode = "n",
			desc = "Toggle Test Summary",
		},
		{
			"<leader>tw",
			function()
				require("neotest").watch.toggle(vim.fn.expand("%"))
			end,
			mode = "n",
			desc = "Toggle Test Watch",
		},
		{
			"<leader>trn",
			function()
				require("neotest").run.run()
			end,
			mode = "n",
			desc = "Run Nearest Test",
		},
		{
			"<leader>tr",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			mode = "n",
			desc = "Run Test File",
		},
		{
			"<leader>tc",
			function()
				require("neotest").output_panel.clear()
			end,
			mode = "n",
			desc = "Clear Test Output",
		},
		{
			"<leader>tt",
			function()
				require("neotest").output_panel.toggle()
			end,
			mode = "n",
			desc = "Toggle Test Output",
		},
	},
}
