return {
  -- ── Session management (one session per project root) ─────────────────────
  -- Saves/restores buffers, splits, and cwd automatically.
  -- Use: cd into a project dir, work, quit — next time `nvim .` restores it.
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "skiprtp" } },
    keys = {
      { "<leader>qs", function() require("persistence").load() end,                desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't save session" },
    },
  },

  -- ── File explorer ─────────────────────────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>fe", "<cmd>Neotree toggle<cr>", desc = "Toggle explorer" },
      { "<leader>fc", "<cmd>Neotree reveal<cr>", desc = "Reveal current file" },
    },
    opts = {
      filesystem = {
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = true },
        follow_current_file = { enabled = true },
      },
      window = { width = 35 },
      close_if_last_window = false,
    },
  },

  -- ── Fuzzy finder ──────────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",                  desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",                   desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",                     desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",                   desc = "Help" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                    desc = "Recent files" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",        desc = "Doc symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "WS symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",                 desc = "Diagnostics" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>",                         desc = "TODO comments" },
      { "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<cr>",   desc = "Search buffer" },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")
      telescope.setup({
        defaults = {
          prompt_prefix   = "  ",
          selection_caret = "  ",
          sorting_strategy = "ascending",
          layout_config    = { prompt_position = "top" },
          file_ignore_patterns = {
            "%.git/", "node_modules/", "__pycache__/", "%.pyc",
            "build/", "dist/", "%.o$", "%.a$", "%.so$", "%.ptx$",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<esc>"] = actions.close,
            },
          },
        },
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  -- ── Auto pairs ────────────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true, disable_filetype = { "TelescopePrompt" } },
  },

  -- ── Surround ──────────────────────────────────────────────────────────────
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

  -- ── Comments ──────────────────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- ── Which-key ─────────────────────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { mappings = true },
      spec = {
        { "<leader>b",  group = "buffers" },
        { "<leader>d",  group = "debug" },
        { "<leader>f",  group = "find / files" },
        { "<leader>g",  group = "git" },
        { "<leader>j",  group = "jupyter / cells" },
        { "<leader>l",  group = "lsp" },
        { "<leader>m",  group = "cmake / make" },
        { "<leader>s",  group = "swap params" },
        { "<leader>t",  group = "terminal" },
        { "<leader>x",  group = "diagnostics" },
      },
    },
  },

  -- ── Flash motion ──────────────────────────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  -- ── Diagnostics list ──────────────────────────────────────────────────────
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location list" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix list" },
    },
    opts = {},
  },

  -- ── Terminal ──────────────────────────────────────────────────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<cr>",           desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>",      desc = "H terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "V terminal" },
      { "<C-\\>",     "<cmd>ToggleTerm<cr>",                           desc = "Toggle terminal" },
    },
    config = function()
      require("toggleterm").setup({
        open_mapping = "<C-\\>",
        direction    = "float",
        float_opts   = { border = "curved" },
        size = function(term)
          if term.direction == "horizontal" then return 15
          elseif term.direction == "vertical" then return math.floor(vim.o.columns * 0.4)
          end
        end,
      })

      -- LazyGit shortcut
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit  = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = {
          border = "curved",
          width  = math.floor(vim.o.columns * 0.92),
          height = math.floor(vim.o.lines   * 0.88),
        },
      })
      vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "LazyGit" })
    end,
  },

  -- ── Todo comments ─────────────────────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = "nvim-lua/plenary.nvim",
    opts = {
      keywords = {
        TODO  = { icon = " ", color = "info" },
        HACK  = { icon = " ", color = "warning" },
        PERF  = { icon = " ", color = "default", alt = { "OPT", "OPTIM", "OPTIMIZE" } },
        NOTE  = { icon = " ", color = "hint",    alt = { "INFO" } },
        CUDA  = { icon = " ", color = "error",   alt = { "GPU", "KERNEL" } },
        FIXME = { icon = " ", color = "error",   alt = { "BUG", "ISSUE" } },
      },
    },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
    },
  },

  -- ── Mini utilities (better text objects, alignment) ───────────────────────
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })     -- better a/i text objects
      require("mini.align").setup()                    -- ga / gA align operators
    end,
  },

  -- ── Better quickfix ───────────────────────────────────────────────────────
  { "kevinhwang91/nvim-bqf", ft = "qf", opts = {} },

  -- ── Project-wide search & replace ─────────────────────────────────────────
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Search & replace" },
    },
  },

  -- ── Hex color inline preview (useful for shaders) ─────────────────────────
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = { "glsl", "hlsl", "css", "html", "lua" },
      user_default_options = { mode = "background", names = false },
    },
  },
}
