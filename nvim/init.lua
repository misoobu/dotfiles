vim.opt.number = true
vim.opt.cursorline = true
vim.opt.breakindent = true
vim.opt.list = true
vim.opt.listchars = { tab = "␉·" }
vim.opt.mouse = ""
vim.opt.swapfile = false

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "

vim.env.EDITOR = "nvr --nostart -cc split --remote-wait +'set bufhidden=delete'"

vim.keymap.set("n", "q", ":q<cr>")
vim.keymap.set("n", "<C-k>", "i<cr><esc>")
vim.keymap.set("n", "<C-s>", ":w<cr>")
vim.keymap.set("i", "<C-s>", "<esc>")
vim.keymap.set("t", "<C-s>", "<C-\\><C-n>")

-- <C-w>hjkl moves for i and t
vim.keymap.set("i", "<C-w>", "<esc><C-w>")
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>")

vim.keymap.set("i", "<C-space>", "<esc><leader>", { remap = true })
vim.keymap.set("t", "<C-space>", "<C-\\><C-n><leader>", { remap = true })
vim.keymap.set("n", "<C-space>", "<leader>", { remap = true })

local function set_window_keymap(key, action, desc)
  vim.keymap.set("n", "<leader>w" .. key, action, { desc = "Window: " .. desc })
end
set_window_keymap("h", "<cmd>vertical leftabove split<cr>", "split toward left")
set_window_keymap("j", "<cmd>belowright split<cr>", "split toward below")
set_window_keymap("k", "<cmd>aboveleft split<cr>", "split toward above")
set_window_keymap("l", "<cmd>vertical rightbelow split<cr>", "split toward right")

local function set_diagnostic_keymap(key, action, desc, key_override)
  vim.keymap.set(
    "n",
    key_override and key or ("<leader>d" .. key),
    action,
    { desc = "Diagnostic: " .. desc }
  )
end
set_diagnostic_keymap("<C-n>", vim.diagnostic.goto_next, "go to next", true)
set_diagnostic_keymap("<C-p>", vim.diagnostic.goto_prev, "go to prev", true)

local function set_lsp_keymap(key, action, desc)
  vim.keymap.set("n", "<leader>l" .. key, action, { desc = "LSP: " .. desc })
end
set_lsp_keymap(
  "e",
  "<cmd>split | lua vim.lsp.buf.declaration()<cr>",
  "declaration (use definition instead)"
)
set_lsp_keymap("h", vim.lsp.buf.hover, "hover")
set_lsp_keymap("s", vim.lsp.buf.signature_help, "signature help")
set_lsp_keymap("R", vim.lsp.buf.rename, "rename")
set_lsp_keymap("C", vim.lsp.buf.code_action, "code action")
set_lsp_keymap("F", function()
  vim.lsp.buf.format({ async = true })
end, "format")
set_lsp_keymap("X", function()
  vim.cmd("LspRestart")
  vim.diagnostic.reset()
  vim.cmd("edit")
end, "Restart")

local my_autocmd_group = vim.api.nvim_create_augroup("MyAutocmdGroup", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  group = my_autocmd_group,
  pattern = "*",
  command = "setlocal nonumber",
})
vim.api.nvim_create_autocmd("VimEnter", {
  group = my_autocmd_group,
  pattern = "*",
  callback = function()
    if not vim.env.NVIM then
      vim.cmd("rightbelow vsplit")
      vim.cmd("terminal")
      vim.cmd("setlocal nonumber")
      vim.cmd("startinsert")
    end
  end,
})

vim.filetype.add({
  extension = {
    mdx = "mdx",
  },
})
vim.treesitter.language.register("markdown", "mdx")

-- Auto-reload files when modified externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = my_autocmd_group,
  pattern = "*",
  command = "if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif",
})
-- Notification after file change
vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
  group = my_autocmd_group,
  pattern = "*",
  command = "echo 'File changed on disk. Buffer reloaded.'",
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        color_overrides = {
          mocha = {
            overlay0 = "#b0b6d9",
          },
        },
        highlight_overrides = {
          mocha = function()
            return {
              LineNr = { fg = "#7a7d99" },
              Whitespace = { fg = "#7a7d99" },
            }
          end,
        },
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },
  { "nvim-tree/nvim-web-devicons" },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        lualine_a = { { "filename", path = 1 } },
        lualine_b = { "branch" },
        lualine_c = { "diff" },
        lualine_x = {},
        lualine_y = { "diagnostics" },
        lualine_z = { "progress" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "progress" },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = { scope = { enabled = false } } },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vimdoc",
          "javascript",
          "typescript",
          "tsx",
          "ruby",
          "rust",
          "solidity",
          "html",
          "css",
          "json",
          "markdown",
          "markdown_inline",
        },
        sync_install = true,
        highlight = { enable = true },
      })
    end,
  },
  { "RRethy/vim-illuminate", event = "VeryLazy" },
  {
    "nvimdev/hlsearch.nvim",
    event = "BufRead",
    config = function()
      require("hlsearch").setup()
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })

      require("copilot_cmp").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/nvim-cmp" },
      { "L3MON4D3/LuaSnip" },
      { "saadparwaiz1/cmp_luasnip" },

      { "j-hui/fidget.nvim" },
    },
    config = function()
      require("mason").setup()

      local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lsp_servers = {
        lua_ls = { Lua = { diagnostics = { globals = { "vim" } } } },
        solargraph = {},
        rust_analyzer = {
          ["rust-analyzer"] = {
            cargo = {
              features = "all",
            },
            diagnostics = {
              disabled = { "inactive-code" },
            },
          },
        },
        solidity_ls_nomicfoundation = {},
        tsserver = {},
      }

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(lsp_servers),
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = lsp_capabilities,
              settings = lsp_servers[server_name],
            })
          end,
        },
      })

      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-a>"] = cmp.mapping.abort(),
          ["<cr>"] = cmp.mapping.confirm(),
          ["<tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "copilot" },
        }, {
          { name = "buffer" },
        }),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      require("fidget").setup({})
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      -- { "nvim-telescope/telescope-frecency.nvim" },
      { "nvim-telescope/telescope-file-browser.nvim" },
    },
    event = "VeryLazy",
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            prompt_position = "top",
          },
          mappings = {
            i = {
              ["<C-s>"] = "close",
            },
            n = {
              ["<C-s>"] = "close",
            },
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!**/.git/**",
          },
        },
        pickers = {
          git_files = {
            use_git_root = false,
            show_untracked = true,
          },
          grep_string = {
            disable_coordinates = true,
          },
          live_grep = {
            disable_coordinates = true,
          },
          buffers = {
            ignore_current_buffer = true,
          },
        },
        extensions = {
          -- frecency = {
          --   workspaces = {
          --     ["hoge"] = "~/bench/hoge",
          --     ["dotfiles"] = "~/dotfiles",
          --   },
          -- },
          file_browser = {
            hidden = true,
            hide_parent_dir = true,
            grouped = true,
            mappings = {
              ["i"] = {
                ["<C-h>"] = require("telescope._extensions.file_browser.actions").backspace,
              },
            },
          },
        },
      })

      telescope.load_extension("fzf")
      -- telescope.load_extension("frecency")
      telescope.load_extension("file_browser")

      local builtin = require("telescope.builtin")

      local function map(key, action, desc)
        vim.keymap.set("n", "<leader>" .. key, action, { desc = desc })
      end
      local function map_file(key, action, desc)
        map("f" .. key, action, "File: " .. desc)
      end

      map_file("f", builtin.git_files, "list git files")
      map_file("g", builtin.live_grep, "grep")
      map_file("c", builtin.grep_string, "grep cursor word")
      map_file("b", builtin.buffers, "list buffers")
      -- map_file("r", "<cmd>Telescope frecency<cr>", "list recent files")
      map_file("e", "<cmd>Telescope file_browser<cr>", "explore cwd")
      map_file("p", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", "explore path")

      map_file("t", function()
        builtin.buffers({ default_text = "term: " })
      end, "list term buffers")

      map("<space>c", builtin.command_history, "List recent commands")
      map("<space>g", builtin.git_bcommits, "List buffer git commits")
      map("<space>t", builtin.treesitter, "List symbols from treesitter")

      set_diagnostic_keymap("l", builtin.diagnostics, "list")

      set_lsp_keymap("d", function()
        require("telescope.builtin").lsp_definitions({ jump_type = "split" })
      end, "definitions")
      set_lsp_keymap("i", function()
        require("telescope.builtin").lsp_implementations({ jump_type = "split" })
      end, "implementations")
      set_lsp_keymap("t", function()
        require("telescope.builtin").lsp_type_definitions({ jump_type = "split" })
      end, "type definitions")
      set_lsp_keymap("r", require("telescope.builtin").lsp_references, "references")
      set_lsp_keymap("o", require("telescope.builtin").lsp_document_symbols, "document symbols")
      set_lsp_keymap(
        "w",
        require("telescope.builtin").lsp_dynamic_workspace_symbols,
        "workspace symbols"
      )
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },
  { "lewis6991/gitsigns.nvim", opts = {} },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    init = function()
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
    end,
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        ["_"] = { "trim_whitespace" },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = false }
      end,
    },
  },
})
