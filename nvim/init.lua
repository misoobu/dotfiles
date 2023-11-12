vim.opt.number = true
vim.opt.cursorline = true
vim.opt.breakindent = true
vim.opt.list = true
vim.opt.listchars = { tab = "␉·" }
vim.opt.mouse = ""

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.keymap.set("n", "q", ":q<CR>")
vim.keymap.set("n", "<C-k>", "i<CR><ESC>")
vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("i", "<C-s>", "<ESC>")
vim.keymap.set('t', '<C-s>', "<C-\\><C-n>")

vim.keymap.set("n", "<Leader>wh", "<cmd>vertical leftabove split<cr>", { desc = "Split new window toward left" })
vim.keymap.set("n", "<Leader>wj", "<cmd>belowright split<cr>", { desc = "Split new window toward below" })
vim.keymap.set("n", "<Leader>wk", "<cmd>aboveleft split<cr>", { desc = "Split new window toward above" })
vim.keymap.set("n", "<Leader>wl", "<cmd>vertical rightbelow split<cr>", { desc = "Split new window toward right" })

vim.keymap.set("n", "<C-n>", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<C-p>", vim.diagnostic.goto_prev, { desc = "Go to prev diagnostic" })

local my_autocmd_group = vim.api.nvim_create_augroup("MyAutocmdGroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = my_autocmd_group,
  pattern = "*",
  command = ":%s/\\s\\+$//e",
})
vim.api.nvim_create_autocmd("TermOpen", {
  group = my_autocmd_group,
  pattern = "*",
  command = "startinsert",
})
vim.api.nvim_create_autocmd("TermOpen", {
  group = my_autocmd_group,
  pattern = "*",
  command = "setlocal nonumber",
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
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      color_overrides = {
        mocha = {
          overlay0 = '#b0b6d9',
        },
      },
      highlight_overrides = {
        mocha = function()
          return {
            LineNr = { fg = '#7a7d99' },
            Whitespace = { fg = '#7a7d99' },
          }
        end,
      }
    })

    vim.cmd.colorscheme("catppuccin")
  end},
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-lualine/lualine.nvim", opts = {
    options = {
      globalstatus = true,
      component_separators = '',
    },
    sections = {
      lualine_b = {'branch', 'diff'},
      lualine_c = {{'buffers', symbols = { modified = '+'}}},
      lualine_x = {},
      lualine_y = {'diagnostics'},
      lualine_z = {'progress'}
    },
    winbar = {
      lualine_a = {{'filename', path = 1}},
    },
    inactive_winbar = {
      lualine_c = {{'filename', path = 1}},
    },
  }},
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = { scope = { enabled = false }} },
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
          "markdown",
          "markdown_inline",
        },
        sync_install = true,
        highlight = { enable = true },
      })
    end,
  },
  { 'RRethy/vim-illuminate', event = "VeryLazy" },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {"williamboman/mason.nvim", "neovim/nvim-lspconfig"},
    config = function()
      require("mason").setup()
      local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lsp_servers = {
        lua_ls = { Lua = { diagnostics = { globals = { "vim" } } } },
        solargraph = {},
        rust_analyzer = {},
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
    end,
  },

  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/nvim-cmp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    ft = {"javascript", "typescript", "typescriptreact"},
    opts = {},
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
    },
    event = "VeryLazy",
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-h>"] = "which_key",
              ["<esc>"] = "close",
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
            show_untracked = true,
          },
          grep_string = {
            disable_coordinates = true,
          },
          live_grep = {
            disable_coordinates = true,
          },
        },
        extensions = {
          frecency = {
            workspaces = {
              ["hoge"]    = "~/bench/hoge",
              ["dotfiles"]    = "~/dotfiles",
            }
          },
        },
      })

      telescope.load_extension("fzf")

      local telescope_builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader><space>o", telescope_builtin.oldfiles, { desc = "List recent files" })
      vim.keymap.set("n", "<leader><space>b", telescope_builtin.buffers, { desc = "List buffers" })
      vim.keymap.set("n", "<leader><space>f", telescope_builtin.git_files, { desc = "List git files" })
      vim.keymap.set("n", "<leader><space>c", telescope_builtin.grep_string, { desc = "Grep cursor word" })
      vim.keymap.set("n", "<leader><space>g", telescope_builtin.live_grep, { desc = "Grep" })

      vim.keymap.set("n", "<leader><space>h", telescope_builtin.command_history, { desc = "List recent commands" })
      vim.keymap.set("n", "<leader><space>t", telescope_builtin.git_bcommits, { desc = "List buffer git commits" })
      vim.keymap.set("n", "<leader><space>s", telescope_builtin.treesitter, { desc = "List symbols from treesitter" })

      vim.keymap.set("n", "<leader>d", telescope_builtin.diagnostics, { desc = "List diagnostics" })
    end,
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    config = function()
      require("telescope").load_extension "frecency"
      vim.keymap.set("n", "<leader><space>r", "<cmd>Telescope frecency<cr>", { desc = "List frecent files" })
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
    "nvim-tree/nvim-tree.lua",
    opts = {},
    keys = {
      { "<leader>e", function() require("nvim-tree.api").tree.toggle({ find_file = true, focus = true }) end, silent = true, desc = "Toggle file explorer" },
    },
  },
  { "j-hui/fidget.nvim", opts = {} },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local function map(key, action, desc)
      vim.keymap.set('n', "<leader>l" .. key, action, { buffer = ev.buf, desc = "LSP: " .. desc })
    end
    map("d", function() require("telescope.builtin").lsp_definitions({jump_type = 'split'}) end, "definitions")
    map("i", function() require("telescope.builtin").lsp_implementations({jump_type = 'split'}) end, "implementations")
    map("t", function() require("telescope.builtin").lsp_type_definitions({jump_type = 'split'}) end, "type definitions")
    map("r", require("telescope.builtin").lsp_references, "references")
    map("o", require("telescope.builtin").lsp_document_symbols, "document symbols")
    map("w", require("telescope.builtin").lsp_dynamic_workspace_symbols, "workspace symbols")

    map("e", vim.lsp.buf.declaration, "declaration")
    map("h", vim.lsp.buf.hover, "hover")
    map("s", vim.lsp.buf.signature_help, "signature help")

    map("R", vim.lsp.buf.rename, "rename")
    map("C", vim.lsp.buf.code_action, "code action")
    map("F", function()
      vim.lsp.buf.format({ async = true })
    end, "format")
  end,
})

local cmp = require("cmp")

local luasnip = require("luasnip")
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-a>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({
      select = true,
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
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
