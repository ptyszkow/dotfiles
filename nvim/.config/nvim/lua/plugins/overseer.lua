return {
	"stevearc/overseer.nvim",
	opts = {
		task_list = {
			direction = "bottom",
			min_height = 25,
			max_height = 25,
			default_detail = 1
		},
	},
	config = function(_, opts)
		local overseer = require("overseer")
		overseer.setup(opts)

		-- .NET tasks
		overseer.register_template({
			name = "build",
			builder = function()
				return {
					cmd = { "dotnet" },
					args = { "build" },
					components = { "default" }
				}
			end,
			condition = {
				filetype = { "cs", "csharp" },
			},
		})

		overseer.register_template({
			name = "run",
			builder = function()
				return {
					cmd = { "dotnet" },
					args = { "run" },
					components = { "default" }
				}
			end,
			condition = {
				filetype = { "cs", "csharp" },
			},
		})

		overseer.register_template({
			name = "test",
			builder = function()
				return {
					cmd = { "dotnet" },
					args = { "test" },
					components = { "default" }
				}
			end,
			condition = {
				filetype = { "cs", "csharp" },
			},
		})

		overseer.register_template({
			name = "watch",
			builder = function()
				return {
					cmd = { "dotnet" },
					args = { "watch", "run" },
					components = { "default" }
				}
			end,
			condition = {
				filetype = { "cs", "csharp" },
			},
		})

		overseer.register_template({
			name = "clean",
			builder = function()
				return {
					cmd = { "dotnet" },
					args = { "clean" },
					components = { "default" }
				}
			end,
			condition = {
				filetype = { "cs", "csharp" },
			},
		})

		-- C++ / CMake tasks
		overseer.register_template({
			name = "build",
			builder = function()
				return {
					cmd = { "cmake" },
					args = { "--build", "build" },
					components = {
						"default",
						"on_result_diagnostics",
						"on_result_diagnostics_quickfix",
					},
				}
			end,
			condition = {
				filetype = { "cpp", "c", "h", "hpp" },
			},
		})

		overseer.register_template({
			name = "run",
			builder = function()
				return {
					cmd = { "./build/my_cpp" },
					args = {},
					components = { "default" },
				}
			end,
			condition = {
				filetype = { "cpp", "c", "h", "hpp" },
			},
		})

		-- Python/uv tasks
		overseer.register_template({
			name = "run",
			builder = function()
				return {
					cmd = { "uv" },
					args = { "run", vim.fn.expand("%") },
					components = { "default" }
				}
			end,
			condition = {
				filetype = { "python" },
			},
		})

		overseer.register_template({
			name = "sync",
			builder = function()
				return {
					cmd = { "uv" },
					args = { "sync" },
					components = { "default" }
				}
			end,
			condition = {
				filetype = { "python" },
			},
		})

		overseer.register_template({
			name = "build",
			builder = function()
				return {
					cmd = { "basedpyright" },
					args = {},
					components = { "default" }
				}
			end,
			condition = {
				filetype = { "python" },
			},
		})

		overseer.register_template({
			name = "test",
			builder = function()
				return {
					cmd = { "uv" },
					args = { "run", "pytest" },
					components = { "default" }
				}
			end,
			condition = {
				filetype = { "python" },
			},
		})
	end,
	keys = {
		{
			"<leader>oo",
			function()
				require("overseer").toggle()
			end,
			mode = "n",
			desc = "Overseer: Toggle Task List",
		},
		{
			"<leader>ob",
			function()
				require("overseer").run_task({ name = "build" })
			end,
			mode = "n",
			desc = "Overseer: Build",
		},
		{
			"<leader>or",
			function()
				require("overseer").run_task({ name = "run" })
			end,
			mode = "n",
			desc = "Overseer: Run",
		},
		{
			"<leader>ot",
			function()
				require("overseer").run_task({ name = "test" })
			end,
			mode = "n",
			desc = "Overseer: Test",
		},
		{
			"<leader>os",
			function()
				require("overseer").run_task()
			end,
			mode = "n",
			desc = "Overseer: Select Task",
		},
		{
			"<leader>oa",
			"<cmd>OverseerTaskAction<cr>",
			mode = "n",
			desc = "Overseer: Task Action",
		},
	},
}
