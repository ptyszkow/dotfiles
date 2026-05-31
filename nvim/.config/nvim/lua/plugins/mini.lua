return {
	"nvim-mini/mini.nvim",
	version = "*",
	config = function()
		require("mini.surround").setup()
		require("mini.ai").setup({
			-- Avoid conflicts with built-in treesitter incremental selection (nvim>=0.12)
			mappings = {
				around_next = "aa",
				inside_next = "ii",
			},
			n_lines = 500, -- look up to 500 lines for matching text objects
		})
		require("mini.move").setup()
	end,
}
