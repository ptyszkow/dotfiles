return {
	"folke/trouble.nvim",
	opts = {
		-- auto_jump = false, -- don't auto jump to the item when navigating
		-- auto_preview = true, -- show preview as you navigate
		-- focus = false, -- don't focus the trouble window when opening
		-- keys = {
		-- 	["j"] = "next", -- next item without jumping
		-- 	["k"] = "prev", -- previous item without jumping
		-- 	["<cr>"] = "jump", -- enter to actually jump to the item
		-- 	["<2-leftmouse>"] = "jump", -- double click to jump
		-- 	["P"] = "toggle_preview", -- toggle preview window
		-- },
	},
	cmd = "Trouble",
	keys = {
		{
			"<leader>xx",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diagnostics (Trouble)",
		},
		{
			"<leader>xX",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Buffer Diagnostics (Trouble)",
		},
		{
			"<leader>cs",
			"<cmd>Trouble symbols toggle focus=false<cr>",
			desc = "Symbols (Trouble)",
		},
		{
			"<leader>cl",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "LSP Definitions / references / ... (Trouble)",
		},
		{
			"<leader>xL",
			"<cmd>Trouble loclist toggle focus=false win.position=right<cr>",
			desc = "Location List (Trouble)",
		},
		{
			"<leader>xQ",
			"<cmd>Trouble qflist toggle focus=false win.position=right<cr>",
			desc = "Quickfix List (Trouble)",
		},
	},
}
