return {
  -- ── Core DAP ──────────────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end,                           desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,   desc = "Conditional BP" },
      { "<leader>dc", function() require("dap").continue() end,                                    desc = "Continue / Start" },
      { "<leader>dn", function() require("dap").step_over() end,                                   desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end,                                   desc = "Step into" },
      { "<leader>do", function() require("dap").step_out() end,                                    desc = "Step out" },
      { "<leader>dr", function() require("dap").repl.open() end,                                   desc = "REPL" },
      { "<leader>dl", function() require("dap").run_last() end,                                    desc = "Run last" },
      { "<leader>du", function() require("dapui").toggle() end,                                    desc = "DAP UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" },                 desc = "Eval expression" },
    },
    config = function()
      local dap    = require("dap")
      local dapui  = require("dapui")

      -- Auto-open UI on session start, auto-close on end
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

      -- ── Python (debugpy installed by mason) ─────────────────────────────
      require("dap-python").setup(
        vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      )
      -- Additional Python config for PyTorch / multiprocess training
      table.insert(dap.configurations.python, {
        type     = "python",
        request  = "attach",
        name     = "Attach to running process",
        connect  = { host = "localhost", port = 5678 },
        justMyCode = false,
      })

      -- ── C++ / CUDA (codelldb) ───────────────────────────────────────────
      -- codelldb supports CUDA device-side breakpoints on Volta+ GPUs with
      -- CUDA-GDB under the hood. Use cmake-tools <leader>md for integration.
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = { command = mason_bin, args = { "--port", "${port}" } },
      }
      local cpp_config = {
        {
          name    = "Launch (codelldb)",
          type    = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/build/", "file")
          end,
          cwd           = "${workspaceFolder}",
          stopOnEntry   = false,
          args          = {},
          -- Uncomment to attach CUDA debugger
          -- initCommands  = { "set cuda break_on_launch application" },
        },
        {
          name    = "Attach (codelldb)",
          type    = "codelldb",
          request = "attach",
          pid     = require("dap.utils").pick_process,
          args    = {},
        },
      }
      dap.configurations.cpp  = cpp_config
      dap.configurations.c    = cpp_config
      dap.configurations.cuda = cpp_config

      -- ── Breakpoint icons ────────────────────────────────────────────────
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",          numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", numhl = "" })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",             numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected",  { text = "✗", texthl = "DapBreakpointRejected",  numhl = "" })
    end,
  },

  -- ── DAP UI ───────────────────────────────────────────────────────────────
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes",      size = 0.35 },
            { id = "breakpoints", size = 0.20 },
            { id = "stacks",      size = 0.25 },
            { id = "watches",     size = 0.20 },
          },
          size     = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl",    size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size     = 0.25,
          position = "bottom",
        },
      },
      floating = { border = "rounded" },
    },
  },

  -- ── Inline variable values while debugging ────────────────────────────────
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = { commented = true, highlight_new_as_changed = true },
  },

  -- ── Mason DAP installer ───────────────────────────────────────────────────
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "codelldb", "python" },
    },
  },
}
