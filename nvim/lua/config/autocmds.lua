local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Open neo-tree when nvim is launched with a directory ─────────────────────
-- Uses VimEnter so neo-tree is fully initialized before any autocmds fire,
-- avoiding WinClosed conflicts with toggleterm and other floating windows.
autocmd("VimEnter", {
  group = augroup("neotree_dir_open", { clear = true }),
  callback = function()
    if vim.fn.argc(-1) == 1 then
      local stat = vim.uv.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then
        vim.cmd("Neotree " .. vim.fn.fnameescape(vim.fn.argv(0)))
      end
    end
  end,
})

-- ── Filetype detection ───────────────────────────────────────────────────────
vim.filetype.add({
  extension = {
    cu   = "cuda",
    cuh  = "cuda",
    ptx  = "asm",      -- NVIDIA PTX assembly
    glsl = "glsl",
    vert = "glsl",
    frag = "glsl",
    geom = "glsl",
    comp = "glsl",     -- compute shaders
    tesc = "glsl",
    tese = "glsl",
    rgen = "glsl",     -- OptiX/ray-tracing pipeline shaders
    rmiss = "glsl",
    rchit = "glsl",
    rahit = "glsl",
    rint  = "glsl",
  },
})

-- CUDA settings (clangd handles it as C++/CUDA)
autocmd("FileType", {
  group = augroup("cuda_ft", { clear = true }),
  pattern = "cuda",
  callback = function()
    vim.bo.commentstring = "// %s"
    vim.bo.cindent = true
  end,
})

-- ── Editor UX ────────────────────────────────────────────────────────────────
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = augroup("last_pos", { clear = true }),
  callback = function()
    local mark  = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Language-specific indent ─────────────────────────────────────────────────
autocmd("FileType", {
  group = augroup("two_space_indent", { clear = true }),
  pattern = { "lua", "yaml", "json", "cmake", "toml", "glsl" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})

autocmd("FileType", {
  group = augroup("cmake_comment", { clear = true }),
  pattern = "cmake",
  callback = function() vim.bo.commentstring = "# %s" end,
})

-- ── Conda / venv hint ────────────────────────────────────────────────────────
-- Notify when a project has an environment file so the user remembers to
-- activate it with <leader>cv (venv-selector).
autocmd({ "VimEnter", "DirChanged" }, {
  group = augroup("conda_hint", { clear = true }),
  callback = function()
    local root = vim.fn.getcwd()
    local markers = { "environment.yml", "environment.yaml", ".python-version", "pyproject.toml" }
    for _, f in ipairs(markers) do
      if vim.fn.filereadable(root .. "/" .. f) == 1 then
        vim.defer_fn(function()
          vim.notify("Python env file detected — use <leader>cv to activate.", vim.log.levels.INFO, { title = "venv" })
        end, 500)
        return
      end
    end
  end,
})

-- ── compile_commands.json hint ───────────────────────────────────────────────
-- If a CMake build exists but compile_commands.json isn't in the project root,
-- remind the user to symlink it so clangd can index the project.
autocmd({ "VimEnter", "DirChanged" }, {
  group = augroup("clangd_hint", { clear = true }),
  callback = function()
    local root = vim.fn.getcwd()
    local has_root_cc = vim.fn.filereadable(root .. "/compile_commands.json") == 1
    local has_cmake   = vim.fn.filereadable(root .. "/CMakeLists.txt") == 1
    if has_cmake and not has_root_cc then
      local build_cc = root .. "/build/compile_commands.json"
      if vim.fn.filereadable(build_cc) == 1 then
        vim.defer_fn(function()
          vim.notify(
            "clangd: symlink compile_commands.json to the project root for full indexing.\n" ..
            "  ln -s build/compile_commands.json .",
            vim.log.levels.HINT, { title = "clangd" }
          )
        end, 1000)
      end
    end
  end,
})
