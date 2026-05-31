-- Pinned to the `master` branch which uses precompiled parsers (no tree-sitter
-- CLI required). The rewritten `main` branch requires tree-sitter-cli 0.26+.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
      vim.treesitter.language.register("cpp", "cuda")
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp",
          "python",
          "cmake",
          "glsl",
          "lua", "vim", "vimdoc",
          "bash",
          "json", "yaml", "toml",
          "markdown", "markdown_inline",
          "regex", "diff", "query",
        },
        sync_install = false,
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent    = { enable = true },
        textobjects = {
          select = {
            enable    = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer", ["if"] = "@function.inner",
              ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer", ["ia"] = "@parameter.inner",
              ["ab"] = "@block.outer",    ["ib"] = "@block.inner",
              ["al"] = "@loop.outer",     ["il"] = "@loop.inner",
            },
          },
          move = {
            enable    = true,
            set_jumps = true,
            goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          },
          swap = {
            enable        = true,
            swap_next     = { ["<leader>sn"] = "@parameter.inner" },
            swap_previous = { ["<leader>sp"] = "@parameter.inner" },
          },
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      max_lines           = 3,
      min_window_height   = 20,
      multiline_threshold = 1,
    },
    keys = {
      { "<leader>lc", "<cmd>TSContextToggle<cr>", desc = "Toggle context header" },
    },
  },
}
