return {
  -- Tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      if vim.g.active_theme == "tokyonight" then
        vim.cmd([[colorscheme tokyonight]])
      end
    end,
  },

  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_background = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      if vim.g.active_theme == "catppuccin" then
        vim.cmd([[colorscheme catppuccin]])
      end
    end,
  },

  -- Kanagawa
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      overrides = function(colors)
        local theme = colors.theme
        return {
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },

          -- Save an hlgroup with dark background and dimmed foreground
          -- so that you can use it where your still want darker windows.
          -- E.g. ":hi NormalFloat guibg=none"
          NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

          -- Popular plugins that open floats will link to NormalFloat by default;
          -- set their background accordingly if you wish to keep them dark and borderless
          LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
        }
      end,
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      if vim.g.active_theme == "kanagawa" then
        vim.cmd([[colorscheme kanagawa]])
      end
    end,
  },

  -- Rose Pine
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      styles = {
        bold = true,
        italic = true,
        transparency = true,
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      if vim.g.active_theme == "rose-pine" then
        vim.cmd([[colorscheme rose-pine]])
      end
    end,
  },

  -- Cyberdream
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      italic_comments = true,
      hide_fillchars = true,
      borderless_telescope = true,
    },
    config = function(_, opts)
      require("cyberdream").setup(opts)
      if vim.g.active_theme == "cyberdream" then
        vim.cmd([[colorscheme cyberdream]])
      end
    end,
  },
}
