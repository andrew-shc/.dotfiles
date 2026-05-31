return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build   = "make install_jsregexp",
        dependencies = "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()

          local ls = require("luasnip")
          local s  = ls.snippet
          local t  = ls.text_node
          local i  = ls.insert_node

          -- ── CUDA snippets ──────────────────────────────────────────────────
          ls.add_snippets("cuda", {
            s("kernel", {
              t("__global__ void "), i(1, "kernel_name"),
              t("("), i(2, ""), t(") {"),
              t({ "", "\t" }), i(3, "const int idx = blockIdx.x * blockDim.x + threadIdx.x;"),
              t({ "", "\t" }), i(4),
              t({ "", "}" }),
            }),
            s("klaunch", {
              i(1, "kernel_name"),
              t("<<<"), i(2, "grid"), t(", "), i(3, "block"), t(", "),
              i(4, "0"), t(", "), i(5, "stream"),
              t(">>>("), i(6), t(");"),
            }),
            s("chk", {
              t("CUDA_CHECK("), i(1, "cudaExpr"), t(");"),
            }),
            s("device", { t("__device__ "), i(1) }),
            s("shared", {
              t("__shared__ "), i(1, "float"), t(" "), i(2, "smem"), t("["), i(3, "BLOCK_SIZE"), t("];"),
            }),
          })

          -- ── OptiX snippets ────────────────────────────────────────────────
          ls.add_snippets("cpp", {
            s("optix_includes", {
              t({ "#include <optix.h>", "#include <optix_stubs.h>", "#include <optix_function_table_definition.h>", "" }),
              i(1),
            }),
            s("optix_check", {
              t("OPTIX_CHECK("), i(1, "optixExpr"), t(");"),
            }),
            s("raygen", {
              t({ "extern \"C\" __global__ void __raygen__", "" }),
              i(1, "rg"), t({ "()" , "{", "\t" }),
              i(2),
              t({ "", "}" }),
            }),
          })

          -- ── PyTorch / Python snippets ─────────────────────────────────────
          ls.add_snippets("python", {
            s("torchmod", {
              t({ "import torch", "import torch.nn as nn", "import torch.nn.functional as F", "", "" }),
              t("class "), i(1, "Model"), t({ "(nn.Module):", "    def __init__(self):", "        super().__init__()", "        " }),
              i(2),
              t({ "", "", "    def forward(self, x):", "        " }),
              i(3, "return x"),
            }),
            s("argparse", {
              t({ "import argparse", "", "parser = argparse.ArgumentParser()", "parser.add_argument('--" }),
              i(1, "arg"), t("', type="), i(2, "str"), t(", default="), i(3, "None"), t(", help='"), i(4), t("')"),
              t({ "", "args = parser.parse_args()", "" }),
              i(5),
            }),
          })
        end,
      },
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp",               priority = 1000 },
          { name = "luasnip",                priority = 750  },
          { name = "nvim_lsp_signature_help", priority = 900  },
          { name = "path",                   priority = 500  },
        }, {
          { name = "buffer", priority = 250, keyword_length = 3 },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode           = "symbol_text",
            maxwidth       = 50,
            ellipsis_char  = "...",
            show_labelDetails = true,
          }),
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        experimental = { ghost_text = true },
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },
}
