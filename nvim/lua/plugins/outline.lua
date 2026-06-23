return {
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    -- Load when opening any buffer so open_automatic can fire
    event = "BufReadPost",
    keys = {
      { "<leader>o", "<cmd>AerialToggle<cr>", desc = "Outline toggle" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },

      -- Auto-open for source-code filetypes
      open_automatic = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        local code_fts = {
          python = true, cpp = true, c = true, cuda = true,
          rust = true, go = true, javascript = true, typescript = true,
          javascriptreact = true, typescriptreact = true,
          lua = true, java = true, cs = true, zig = true,
        }
        return code_fts[ft] == true
          and vim.api.nvim_buf_line_count(bufnr) > 1
      end,

      layout = {
        max_width    = { 40, 0.2 },
        width        = nil,
        min_width    = 20,
        default_direction = "right",
        placement    = "edge",
        preserve_equality = true,
      },

      -- Show symbol icons matching VS Code outline
      show_guides  = true,
      guides = {
        mid_item   = "├─",
        last_item  = "└─",
        nested_top = "│ ",
        whitespace = "  ",
      },

      -- Keep outline focused on cursor position
      highlight_on_hover = true,
      autoscroll         = true,

      -- Don't steal focus when auto-opening
      focus_on_open = false,

      -- Close aerial with the last code window
      close_automatic_events = { "switch_buffer" },

      filter_kind = {
        "Class", "Constructor", "Enum", "EnumMember",
        "Event", "Field", "Function", "Interface",
        "Method", "Module", "Namespace", "Package",
        "Property", "Struct", "Type", "TypeParameter", "Variable",
      },
    },
  },
}
