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

-- TODO: plugins
