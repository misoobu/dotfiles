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

vim.env.EDITOR = "nvr --nostart -cc split --remote-wait +'set bufhidden=delete'"

vim.keymap.set("n", "q", ":q<cr>")
vim.keymap.set("n", "<C-k>", "i<cr><esc>")
vim.keymap.set("n", "<C-s>", ":w<cr>")
vim.keymap.set("i", "<C-s>", "<esc>")
vim.keymap.set("t", "<C-s>", "<C-\\><C-n>")

-- <C-w>hjkl moves for i and t
vim.keymap.set("i", "<C-w>", "<esc><C-w>")
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>")

vim.keymap.set("n", "<leader>wh", "<cmd>vertical leftabove split<cr>", { desc = "Split new window toward left" })
vim.keymap.set("n", "<leader>wj", "<cmd>belowright split<cr>", { desc = "Split new window toward below" })
vim.keymap.set("n", "<leader>wk", "<cmd>aboveleft split<cr>", { desc = "Split new window toward above" })
vim.keymap.set("n", "<leader>wl", "<cmd>vertical rightbelow split<cr>", { desc = "Split new window toward right" })

vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "Go to prev diagnostic" })

local function set_lsp_keymap(key, action, desc)
  vim.keymap.set("n", "<leader>l" .. key, action, { desc = "LSP: " .. desc })
end

set_lsp_keymap("e", "<cmd>split | lua vim.lsp.buf.declaration()<cr>", "declaration (use definition instead)")
set_lsp_keymap("h", vim.lsp.buf.hover, "hover")
set_lsp_keymap("s", vim.lsp.buf.signature_help, "signature help")
set_lsp_keymap("R", vim.lsp.buf.rename, "rename")
set_lsp_keymap("C", vim.lsp.buf.code_action, "code action")
set_lsp_keymap("F", function()
  vim.lsp.buf.format({ async = true })
end, "format")

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
      options = {
        globalstatus = true,
        component_separators = "",
      },
      sections = {
        lualine_b = { "branch", "diff" },
        lualine_c = { { "buffers", symbols = { modified = "+" } } },
        lualine_x = {},
        lualine_y = { "diagnostics" },
        lualine_z = { "progress" },
      },
      winbar = {
        lualine_a = { { "filename", path = 1 } },
        lualine_z = { "location" },
      },
      inactive_winbar = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
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
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      { "pmizio/typescript-tools.nvim" },

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

      require("typescript-tools").setup({})

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
          ["<C-space>"] = cmp.mapping.complete(),
          ["<C-a>"] = cmp.mapping.abort(),
          ["<cr>"] = cmp.mapping.confirm({
            select = true,
          }),
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
      { "nvim-telescope/telescope-frecency.nvim" },
    },
    event = "VeryLazy",
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
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
              ["hoge"] = "~/bench/hoge",
              ["dotfiles"] = "~/dotfiles",
            },
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("frecency")

      local builtin = require("telescope.builtin")

      local function map(key, action, desc)
        vim.keymap.set("n", "<leader>" .. key, action, { desc = desc })
      end

      map("to", builtin.oldfiles, "List recent files")
      map("tb", builtin.buffers, "List buffers")
      map("tf", builtin.git_files, "List git files")
      map("tc", builtin.grep_string, "Grep cursor word")
      map("tg", builtin.live_grep, "Grep")
      map("th", builtin.command_history, "List recent commands")
      map("tt", builtin.git_bcommits, "List buffer git commits")
      map("ts", builtin.treesitter, "List symbols from treesitter")

      map("tr", "<cmd>Telescope frecency<cr>", "List frecent files")

      map("dl", builtin.diagnostics, "List diagnostics")

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
      set_lsp_keymap("w", require("telescope.builtin").lsp_dynamic_workspace_symbols, "workspace symbols")
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
      {
        "<leader>e",
        function()
          require("nvim-tree.api").tree.toggle({ find_file = true, focus = true })
        end,
        silent = true,
        desc = "Toggle file explorer",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format buffer",
      },
    },
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
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    },
  },
})
