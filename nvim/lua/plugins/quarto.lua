return {
  -- ── otter.nvim: LSP completions for embedded code blocks ─────────────────
  {
    "jmbuhr/otter.nvim",
    ft = { "quarto", "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  -- ── quarto-nvim: editing, preview, and cell execution ────────────────────
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        languages        = { "python", "r", "julia", "bash", "lua" },
        chunks           = "all",
        diagnostics      = { enabled = true },
        completion       = { enabled = true },
      },
      keymap = { hover = "K" },
    },
    keys = {
      { "<leader>qp", function() require("quarto").quartoPreview() end,  ft = "quarto", desc = "Quarto preview" },
      { "<leader>qq", function() require("quarto").quartoClosePreview() end, ft = "quarto", desc = "Quarto close preview" },
      { "<leader>qa", function() require("quarto").quartoActivate() end, ft = "quarto", desc = "Quarto activate otter" },
    },
  },
}
