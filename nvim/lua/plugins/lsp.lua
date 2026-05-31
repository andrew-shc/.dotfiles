return {
  -- ── Mason: install LSP servers, DAP adapters, formatters ──────────────────
  {
    "williamboman/mason.nvim",
    lazy = false,
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "clangd", "basedpyright", "cmake", "lua_ls" },
      automatic_installation = true,
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "ruff", "stylua", "clang-format" },
      auto_update = false,
    },
  },

  -- ── Core LSP config (Neovim 0.11+ native API) ────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "folke/neodev.nvim", opts = {} },
      "j-hui/fidget.nvim",
    },
    config = function()
      local caps = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
      )

      -- Keymaps and inlay hints via LspAttach (replaces on_attach)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufnr  = args.buf
          local map    = function(keys, fn, desc)
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

          if client and vim.lsp.inlay_hint and client.supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            map("<leader>lh", function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
                { bufnr = bufnr }
              )
            end, "Toggle inlay hints")
          end
        end,
      })

      -- ── clangd ── C / C++ / CUDA / OptiX ──────────────────────────────────
      vim.lsp.config("clangd", {
        capabilities = vim.tbl_deep_extend("force", caps, {
          offsetEncoding = { "utf-16" },
        }),
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          "--offset-encoding=utf-16",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_markers = {
          "compile_commands.json", "compile_flags.txt", ".clangd",
          "CMakeLists.txt", "Makefile", ".git",
        },
        init_options = {
          usePlaceholders    = true,
          completeUnimported = true,
          clangdFileStatus   = true,
        },
      })

      -- ── basedpyright ── Python / PyTorch / NumPy / OpenCV / etc. ──────────
      vim.lsp.config("basedpyright", {
        capabilities = caps,
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
        settings = {
          basedpyright = {
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              autoSearchPaths        = true,
              diagnosticMode         = "openFilesOnly",
              useLibraryCodeForTypes = true,
              typeCheckingMode       = "basic",
            },
          },
        },
      })

      -- ── cmake-language-server ─────────────────────────────────────────────
      vim.lsp.config("cmake", { capabilities = caps })



      -- ── lua_ls ── for editing this config ─────────────────────────────────
      vim.lsp.config("lua_ls", {
        capabilities = caps,
        settings = {
          Lua = {
            runtime   = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            hint      = { enable = true },
          },
        },
      })

      vim.lsp.enable({ "clangd", "basedpyright", "cmake", "lua_ls" })
    end,
  },

  -- ── Python venv selector (mirrors VS Code's "Select Interpreter") ─────────
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    ft = "python",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    opts = {
      settings = {
        -- fdfind is the binary name when installed via apt; conda install -c conda-forge fd gives "fd"
        fd_binary_name = vim.fn.executable("fd") == 1 and "fd" or "fdfind",
        search = {
          anaconda_base = { enabled = true },
          anaconda_envs = { enabled = true },
          venv          = { enabled = false },
        },
      },
    },
    keys = {
      { "<leader>lv", "<cmd>VenvSelect<cr>", desc = "Select Python venv" },
    },
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
        inline               = true,
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
      { "<leader>mb", function()
          require("cmake-tools").build({}, function(result)
            local ok = result.code == require("cmake-tools.types").SUCCESS
            require("util").notify_kitty(
              ok and "CMake Build ✓" or "CMake Build ✗",
              ok and "Build succeeded" or "Build failed"
            )
          end)
        end, desc = "CMake build" },
      { "<leader>mr", function()
          require("cmake-tools").run({}, function(result)
            local ok = result.code == require("cmake-tools.types").SUCCESS
            require("util").notify_kitty(
              ok and "CMake Run ✓" or "CMake Run ✗",
              ok and "Run finished" or "Run failed"
            )
          end)
        end, desc = "CMake run" },
      { "<leader>md", "<cmd>CMakeDebug<cr>",              desc = "CMake debug" },
      { "<leader>ms", "<cmd>CMakeSelectBuildType<cr>",    desc = "CMake build type" },
      { "<leader>mt", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "CMake target" },
      { "<leader>mc", "<cmd>CMakeClean<cr>",              desc = "CMake clean" },
    },
  },
}
