return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      require("nvim-treesitter").install({
        "c", "cpp", "python", "cmake", "glsl",
        "lua", "vim", "vimdoc", "bash",
        "json", "yaml", "toml",
        "markdown", "markdown_inline",
        "regex", "diff", "query",
      }):wait(300000)
    end,
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
      vim.treesitter.language.register("cpp", "cuda")

      -- Highlighting and indentation via Neovim built-ins.
      -- Guard: only start if the parser is actually installed.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "c", "cpp", "cuda", "python", "cmake", "glsl",
          "lua", "vim", "bash",
          "json", "yaml", "toml",
          "markdown",
        },
        callback = function()
          local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype
          if not pcall(vim.treesitter.language.inspect, lang) then return end
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- ── Textobjects ───────────────────────────────────────────────────────
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move   = { set_jumps = true },
      })

      local sel  = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      -- Select
      local select_maps = {
        ["af"] = "@function.outer", ["if"] = "@function.inner",
        ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer", ["ia"] = "@parameter.inner",
        ["ab"] = "@block.outer",    ["ib"] = "@block.inner",
        ["al"] = "@loop.outer",     ["il"] = "@loop.inner",
      }
      for key, query in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, key, function()
          sel.select_textobject(query, "textobjects")
        end)
      end

      -- Move
      vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer",     "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer",        "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer",    "textobjects") end)

      -- Swap
      vim.keymap.set("n", "<leader>sn", function() swap.swap_next("@parameter.inner")     end)
      vim.keymap.set("n", "<leader>sp", function() swap.swap_previous("@parameter.inner") end)
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
