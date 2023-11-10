vim.opt.number = true
vim.opt.cursorline = true
vim.opt.breakindent = true
vim.opt.list = true
vim.opt.listchars = { tab='␉·' }

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

-- TODO: grep?

local my_autocmd_group = vim.api.nvim_create_augroup('MyAutocmdGroup', { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = my_autocmd_group,
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
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "nvim-lualine/lualine.nvim", opts = {
      options = {
        icons_enabled = false,
        component_separators = '',
        section_separators = '',
      },
    },
  },
  { "lewis6991/gitsigns.nvim" },
})

require('lualine').setup()
require('gitsigns').setup()

vim.cmd.colorscheme "catppuccin-mocha"
