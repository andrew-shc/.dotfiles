return {
  -- ── render-markdown.nvim: in-buffer rendering of headings, code blocks,
  --    lists, tables, checkboxes, etc. (treesitter-based, no external deps) ──
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "quarto" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      file_types = { "markdown", "quarto" },
    },
    keys = {
      { "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", ft = { "markdown", "quarto" }, desc = "Toggle markdown rendering" },
    },
  },
}
