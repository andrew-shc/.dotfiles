return {
  -- ── Auto-formatting on save ───────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd   = "ConformInfo",
    keys = {
      {
        "<leader>lf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        -- Python: ruff replaces black + isort in one fast pass
        python  = { "ruff_fix", "ruff_format" },
        -- C / C++ / CUDA: clang-format with project .clang-format if present,
        -- falling back to LLVM style
        c       = { "clang_format" },
        cpp     = { "clang_format" },
        cuda    = { "clang_format" },
        -- CMake
        cmake   = { "cmake_format" },
        -- Config / data
        lua     = { "stylua" },
        json    = { "jq" },
        yaml    = { "prettier" },
        -- Fallback for everything else
        ["*"]   = { "trim_whitespace" },
      },
      format_on_save = {
        timeout_ms   = 3000,
        lsp_fallback = true,
      },
      formatters = {
        clang_format = {
          -- Use .clang-format in project root if it exists
          prepend_args = { "--style=file", "--fallback-style=LLVM" },
        },
      },
    },
  },

  -- ── Linting (on-save and on-open) ─────────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
        cmake  = { "cmakelint" },
      }
      local group = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group    = group,
        callback = function() lint.try_lint() end,
      })
    end,
  },
}
