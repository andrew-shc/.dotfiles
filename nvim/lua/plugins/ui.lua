return {
  -- ── Color scheme (VS Code Dark+) ────────────────────────────────────────────
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    opts = {
      style = "dark",
      transparent = false,
      italic_comments = true,
      disable_nvimtree_bg = true,
    },
    config = function(_, opts)
      require("vscode").setup(opts)
      vim.cmd.colorscheme("vscode")
    end,
  },

  -- ── Statusline ───────────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function active_env()
        local venv = vim.env.CONDA_DEFAULT_ENV or vim.env.VIRTUAL_ENV
        if venv then
          return "  " .. vim.fn.fnamemodify(venv, ":t")
        end
        return ""
      end

      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = {
            { active_env, color = { fg = "#a6e3a1" } },
            "encoding", "fileformat", "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- ── Buffer tabs ──────────────────────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        mode = "buffers",
        separator_style = "slant",
        diagnostics = "nvim_lsp",
        show_close_icon = false,
        always_show_bufferline = true,
        offsets = {
          { filetype = "neo-tree", text = "Explorer", text_align = "left", separator = true },
        },
      },
    },
  },

  -- ── Indent guides ────────────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope  = { enabled = true },
    },
  },

  -- ── Notifications ────────────────────────────────────────────────────────────
  {
    "rcarriga/nvim-notify",
    opts = { render = "minimal", stages = "fade", timeout = 3000 },
    init = function()
      vim.notify = require("notify")
    end,
  },


  -- ── Dashboard ────────────────────────────────────────────────────────────────
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    cond = function() return not vim.env.KITTY_SCROLLBACK_NVIM end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function(_, opts)
      opts.config.project.action = function(path)
        vim.cmd("cd " .. vim.fn.fnameescape(path))
        require("neo-tree.command").execute({ action = "show", dir = path })
      end
      require("dashboard").setup(opts)
    end,
    opts = {
      theme = "hyper",
      config = {
        week_header = { enable = true },
        project = { enable = true, limit = 20, icon = " ", label = "Recent Projects" },
        mru     = { enable = true, limit = 5,  label = "Recent Files" },
        shortcut = {
          { desc = "Lazy",   group = "Special", action = "Lazy",                 key = "l" },
          { desc = "Files",  group = "Label",   action = "Telescope find_files", key = "f" },
          { desc = "Recent", group = "Label",   action = "Telescope oldfiles",   key = "r" },
          { desc = "Grep",   group = "Label",   action = "Telescope live_grep",  key = "g" },
          { desc = "Quit",   group = "Special", action = "qa",                   key = "q" },
        },
      },
    },
  },

  -- ── Icons ────────────────────────────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Inline image rendering (Kitty graphics protocol) ─────────────────────────
  {
    "3rd/image.nvim",
    build = "luarocks install magick",
    event = "VeryLazy",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = true, download_remote_images = true },
      },
      max_width_window_percentage = 60,
      max_height_window_percentage = 40,
      -- required when inside tmux (needs `set -gq allow-passthrough on` in tmux.conf)
      tmux_show_only_in_active_window = true,
    },
  },
}
