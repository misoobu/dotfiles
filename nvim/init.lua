vim.opt.number = true
vim.opt.cursorline = true
vim.opt.breakindent = true
vim.opt.list = true
vim.opt.listchars = { tab = '␉·' }

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "

vim.keymap.set('n', 'q', ':q<CR>')
vim.keymap.set('n', '<C-k>', 'i<CR><ESC>')
vim.keymap.set('n', '<C-s>', ':w<CR>')
vim.keymap.set('i', '<C-s>', '<ESC>')

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup('MyAutocmdGroup', { clear = true }),
  pattern = "*",
  command = ":%s/\\s\\+$//e",
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
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },

  { 'neovim/nvim-lspconfig' },

  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/nvim-cmp' },

  { 'L3MON4D3/LuaSnip' },
  { 'saadparwaiz1/cmp_luasnip' },

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
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
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { "lua", "vimdoc", "javascript", "typescript", "tsx", "ruby", "rust", "markdown", "markdown_inline" },
        sync_install = true,
        highlight = { enable = true },
      })
    end,
  },
  { "catppuccin/nvim",                     name = "catppuccin", priority = 1000 },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = false,
        component_separators = '',
        section_separators = '',
      },
    },
  },
  { "lewis6991/gitsigns.nvim",             opts = {} },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl",        opts = {} },
})

require("mason").setup()
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_servers = {
  lua_ls = { Lua = { diagnostics = { globals = { 'vim' } } } },
}
require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(lsp_servers),
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup {
        capabilities = capabilities,
        settings = lsp_servers[server_name],
      }
    end,
  }
}

vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations, opts)
    vim.keymap.set('n', '<Leader>s', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<Leader>D', require('telescope.builtin').lsp_type_definitions, opts)
    vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<Leader>C', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
    vim.keymap.set('n', '<Leader>lds', require('telescope.builtin').lsp_document_symbols, opts)
    vim.keymap.set('n', '<Leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols, opts)
    vim.keymap.set('n', '<Leader>F', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm {
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
}

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

local telescope = require('telescope')
telescope.setup {
  defaults = {
    mappings = {
      i = {
        ["<C-s>"] = "close",
      },
    },
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--glob=!**/.git/**',
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
}
telescope.load_extension('fzf')
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>o', telescope_builtin.oldfiles, { desc = 'Recently opened files' })
vim.keymap.set('n', '<Leader>b', telescope_builtin.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<Leader>f', telescope_builtin.git_files, { desc = 'Files' })
vim.keymap.set('n', '<Leader>c', telescope_builtin.grep_string, { desc = 'Grep cursor word' })
vim.keymap.set('n', '<Leader>g', telescope_builtin.live_grep, { desc = 'Grep' })
vim.keymap.set('n', '<Leader>d', telescope_builtin.diagnostics, { desc = 'Diagnostics' })

require("catppuccin").setup {
  flavour = "mocha",
  custom_highlights = function()
    return {
      Comment = { fg = "#eebebe" },
    }
  end
}

vim.cmd.colorscheme "catppuccin"
