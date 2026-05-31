-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- Options
vim.g.active_theme = "catppuccin" -- options: tokyonight, catppuccin, kanagawa, rose-pine, cyberdream
-- vim.g.active_theme = "kanagawa"
-- vim.g.active_theme = "rose-pine"
--vim.g.active_theme = "cyberdream"
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.swapfile = false
vim.opt.winborder = "rounded"
vim.opt.signcolumn = "yes"
vim.o.undofile = true        -- persist undo history across sessions
vim.o.breakindent = true     -- indent wrapped lines visually
vim.o.cursorline = true      -- highlight current line
vim.o.scrolloff = 10         -- keep 10 lines above/below cursor
vim.o.inccommand = "split"   -- live preview of :s substitutions in a split
vim.o.confirm = true         -- ask to save instead of erroring on :q with unsaved changes
vim.o.list = true            -- show invisible characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.clipboard = "unnamedplus"
local osc52 = require("vim.ui.clipboard.osc52")
local clipboard_cache = { ["+"] = { { "" }, "v" }, ["*"] = { { "" }, "v" } }
local function make_copy(reg)
  local inner = osc52.copy(reg)
  return function(lines, regtype)
    clipboard_cache[reg] = { lines, regtype or "v" }
    inner(lines, regtype)
  end
end
vim.g.clipboard = {
  name = "OSC 52",
  copy = { ["+"] = make_copy("+"), ["*"] = make_copy("*") },
  paste = {
    ["+"] = function() return clipboard_cache["+"] end,
    ["*"] = function() return clipboard_cache["*"] end,
  },
}
-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Performance
vim.opt.updatetime = 250 -- Faster completion
vim.opt.timeoutlen = 500 -- Shorter mapped sequence wait
-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
if vim.fn.executable("rg") == 1 then
  vim.o.grepprg = "rg --vimgrep --smart-case"
end
vim.cmd(":hi statusline guibg=NONE")

vim.keymap.set("n", "<leader>ui", ":update<CR> :source<CR>", { desc = "Update and Source Init" })

-- Clear search highlights on Escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation with Ctrl+hjkl
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>ch", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle Inlay Hints" })
vim.keymap.set("n", "<leader>cL", vim.lsp.codelens.run, { desc = "Run Codelens" })

vim.keymap.set("n", "<leader>ft",
  [[:vimgrep /\v^\s*[-*]\s+\[ \]\s+.*/gj **/*.md<CR>]],
  { desc = "Find Markdown unchecked todos" }
)
vim.g.dotnet_lsp = "csharp_ls"
vim.lsp.enable({ "lua_ls", vim.g.dotnet_lsp, "basedpyright", "jsonls", "yamlls", "html", "ts_ls", "clangd" })

require("config.lazy")
require("config.dap")

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		spacing = 4,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,

	float = {
		border = "rounded",
		source = true,
		header = "",
		prefix = "",
	},

	-- Auto-open float when jumping between diagnostics with [d / ]d
	jump = {
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
		end,
	},
})

--vim.g.python3_host_prog = "/home/peter/Projects/TestUV/.venv/bin/python"

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- LSP: highlight word under cursor on CursorHold, clear on move
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-document-highlight", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/documentHighlight", event.buf) then
      local group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("lsp-highlight-detach", { clear = true }),
        callback = function(ev)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = ev.buf })
        end,
      })
    end
  end,
})

-- C/C++: point :make at cmake build dir, errorformat matches clang output
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.makeprg = "cmake --build build 2>&1"
    vim.opt_local.errorformat =
      "%f:%l:%c: %t%*[^:]: %m," ..  -- clang:  file:line:col: error: msg
      "%f:%l: %t%*[^:]: %m,"        -- fallback without column
  end,
})
