return {
  -- ── Conda / venv environment switcher ────────────────────────────────────
  -- Detects conda envs at ~/anaconda3/envs, ~/miniconda3/envs, and local
  -- .venv / venv dirs. Restarts pyright after switching so LSP picks up the
  -- new interpreter immediately.
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",    -- v2: better conda + pyenv support
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    ft   = "python",
    cmd  = { "VenvSelect", "VenvSelectCached" },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>",       desc = "Select conda / venv" },
      { "<leader>cV", "<cmd>VenvSelectCached<cr>", desc = "Re-use last venv" },
    },
    opts = {
      name = { "venv", ".venv", "env", ".env" },
      auto_refresh         = true,
      search_venv_managers = true,
      search_workspace     = true,
      -- Adjust paths to match your conda installation:
      anaconda_base_path  = vim.fn.expand("~/anaconda3"),
      anaconda_envs_path  = vim.fn.expand("~/anaconda3/envs"),
      miniconda_base_path = vim.fn.expand("~/miniconda3"),
      miniconda_envs_path = vim.fn.expand("~/miniconda3/envs"),
    },
  },

  -- ── Jupyter notebook cell execution (inline output) ──────────────────────
  -- Runs cells in-editor via a Jupyter kernel; outputs appear as virtual text
  -- below each cell. Combined with image.nvim, plots render in the terminal.
  --
  -- Setup:
  --   pip install pynvim jupyter_client ipykernel
  --   :UpdateRemotePlugins  (once, after install)
  --   :MoltenInit  (inside a Python buffer to start a kernel)
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build   = ":UpdateRemotePlugins",
    ft      = { "python", "markdown" },
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_output_win_max_height = 24
      vim.g.molten_image_provider        = "image.nvim"
      vim.g.molten_auto_open_output      = true
      vim.g.molten_wrap_output           = true
      vim.g.molten_virt_text_output      = true
      vim.g.molten_virt_lines_off_by_1   = true
    end,
    keys = {
      { "<leader>jI", ":MoltenInit<CR>",                                             desc = "Init kernel" },
      { "<leader>ji", ":MoltenInterrupt<CR>",                                        desc = "Interrupt" },
      { "<leader>jl", ":MoltenEvaluateLine<CR>",                                     desc = "Eval line" },
      { "<leader>jr", ":MoltenReevaluateCell<CR>",                                   desc = "Re-eval cell" },
      { "<leader>je", ":<C-u>MoltenEvaluateVisual<CR>", mode = "v",                  desc = "Eval selection" },
      { "<leader>jd", ":MoltenDelete<CR>",                                            desc = "Delete output" },
      { "<leader>jh", ":MoltenHideOutput<CR>",                                       desc = "Hide output" },
      { "<leader>jo", ":noautocmd MoltenEnterOutput<CR>",                            desc = "Enter output" },
      { "<leader>jk", ":MoltenShowOutput<CR>",                                       desc = "Show output" },
    },
  },

  -- ── Inline image rendering ────────────────────────────────────────────────
  -- Used by molten-nvim to display matplotlib / OpenCV figures inline.
  -- Default backend: kitty (requires kitty terminal).
  -- For other terminals set backend = "ueberzug" (needs ueberzugpp installed).
  {
    "3rd/image.nvim",
    lazy = true,
    build = false,
    opts = {
      backend     = "kitty",
      integrations = {
        markdown = {
          enabled                   = true,
          clear_in_insert_mode      = false,
          download_remote_images    = true,
        },
      },
      max_width                          = 120,
      max_height                         = 40,
      max_height_window_percentage       = math.huge,
      max_width_window_percentage        = math.huge,
      window_overlap_clear_enabled       = true,
      window_overlap_clear_ft_ignore     = { "cmp_menu", "cmp_docs", "" },
    },
  },
}
