return {
  -- ── Gutter signs + hunk operations ───────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs  = package.loaded.gitsigns
        local map = function(mode, keys, fn, desc)
          vim.keymap.set(mode, keys, fn, { buffer = bufnr, desc = "Git: " .. desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk,          "Next hunk")
        map("n", "[h", gs.prev_hunk,          "Prev hunk")

        -- Stage / reset
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>",  "Stage hunk")
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>",  "Reset hunk")
        map("n", "<leader>gS", gs.stage_buffer,      "Stage buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk,   "Undo stage hunk")
        map("n", "<leader>gR", gs.reset_buffer,      "Reset buffer")

        -- Inspect
        map("n", "<leader>gp", gs.preview_hunk,      "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gd", gs.diffthis,          "Diff this")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff against HEAD~")

        -- Text object: ih = inner hunk
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- ── Side-by-side diff view + file history ────────────────────────────────
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>",            desc = "Diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>",   desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",     desc = "Repo history" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>",           desc = "Close diff view" },
    },
    opts = {},
  },
}
