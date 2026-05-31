return {
  -- ── Mason: install LSP servers, DAP adapters, formatters ──────────────────
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "clangd", "pyright", "cmake", "lua_ls" },
      automatic_installation = true,
    },
  },

  -- ── Core LSP config ───────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "folke/neodev.nvim", opts = {} },    -- Neovim Lua API types
      "j-hui/fidget.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local caps      = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
      )

      local function on_attach(client, bufnr)
        local map = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = "LSP: " .. desc })
        end
        local tb = require("telescope.builtin")

        map("gd",         tb.lsp_definitions,          "Go to definition")
        map("gD",         vim.lsp.buf.declaration,     "Go to declaration")
        map("gr",         tb.lsp_references,           "References")
        map("gi",         tb.lsp_implementations,      "Go to implementation")
        map("gt",         tb.lsp_type_definitions,     "Type definition")
        map("K",          vim.lsp.buf.hover,           "Hover docs")
        map("<leader>ls", vim.lsp.buf.signature_help,  "Signature help")
        map("<leader>lr", vim.lsp.buf.rename,          "Rename")
        map("<leader>la", vim.lsp.buf.code_action,     "Code action")
        map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
        map("<leader>li", "<cmd>LspInfo<cr>",          "LSP info")

        -- Inlay hints (Neovim 0.10+)
        if vim.lsp.inlay_hint and client.supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          map("<leader>lh", function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
              { bufnr = bufnr }
            )
          end, "Toggle inlay hints")
        end
      end

      -- ── clangd ── C / C++ / CUDA / OptiX ──────────────────────────────────
      -- CUDA: clangd reads compile_commands.json to discover --cuda-gpu-arch;
      -- or put a .clangd file in the project root (see templates/.clangd).
      -- OptiX: add -I/path/to/OptiX/include in compile_flags.txt / .clangd.
      lspconfig.clangd.setup({
        capabilities = vim.tbl_deep_extend("force", caps, {
          offsetEncoding = { "utf-16" },
        }),
        on_attach = on_attach,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          "--offset-encoding=utf-16",
          -- Default GPU arch; override per-project via .clangd CompileFlags
          "--cuda-gpu-arch=sm_86",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_dir = require("lspconfig.util").root_pattern(
          "compile_commands.json", "compile_flags.txt", ".clangd",
          "CMakeLists.txt", "Makefile", ".git"
        ),
        init_options = {
          usePlaceholders    = true,
          completeUnimported = true,
          clangdFileStatus   = true,
        },
      })

      -- ── pyright ── Python / PyTorch / NumPy / OpenCV / etc. ───────────────
      -- Active conda / venv is detected automatically via venv-selector.nvim.
      lspconfig.pyright.setup({
        capabilities = caps,
        on_attach    = on_attach,
        settings = {
          pyright = {
            disableOrganizeImports = true,   -- ruff handles imports
          },
          python = {
            analysis = {
              autoSearchPaths        = true,
              diagnosticMode         = "workspace",
              useLibraryCodeForTypes = true,
              typeCheckingMode       = "basic",
            },
          },
        },
      })

      -- ── cmake-language-server ─────────────────────────────────────────────
      lspconfig.cmake.setup({ capabilities = caps, on_attach = on_attach })

      -- ── lua_ls ── for editing this config ─────────────────────────────────
      lspconfig.lua_ls.setup({
        capabilities = caps,
        on_attach    = on_attach,
        settings = {
          Lua = {
            runtime   = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            hint      = { enable = true },
          },
        },
      })
    end,
  },

  -- ── LSP progress indicator ────────────────────────────────────────────────
  {
    "j-hui/fidget.nvim",
    opts = { notification = { window = { winblend = 0 } } },
  },

  -- ── clangd extras: switch header↔source, AST viewer, inlay hints ─────────
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "cuda" },
    opts = {
      inlay_hints = {
        inline              = true,
        show_parameter_hints = true,
        parameter_hints_prefix = "<- ",
        other_hints_prefix     = "=> ",
      },
    },
    keys = {
      { "<leader>lH", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch header/source (.cu↔.cpp)" },
      { "<leader>lA", "<cmd>ClangdAST<cr>",                desc = "Clangd AST" },
    },
  },

  -- ── cmake-tools: build / run / debug CMake projects inside Neovim ─────────
  -- Automatically sets cmake_generate_options to export compile_commands.json
  -- so clangd picks up CUDA / OptiX flags immediately.
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "cmake", "cpp", "c", "cuda" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      cmake_command          = "cmake",
      cmake_build_directory  = "build",
      cmake_build_type       = "RelWithDebInfo",
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
      cmake_console_size     = 10,
      cmake_show_console     = "always",
    },
    keys = {
      { "<leader>mg", "<cmd>CMakeGenerate<cr>",           desc = "CMake generate" },
      { "<leader>mb", "<cmd>CMakeBuild<cr>",              desc = "CMake build" },
      { "<leader>mr", "<cmd>CMakeRun<cr>",                desc = "CMake run" },
      { "<leader>md", "<cmd>CMakeDebug<cr>",              desc = "CMake debug" },
      { "<leader>ms", "<cmd>CMakeSelectBuildType<cr>",    desc = "CMake build type" },
      { "<leader>mt", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "CMake target" },
      { "<leader>mc", "<cmd>CMakeClean<cr>",              desc = "CMake clean" },
    },
  },
}
