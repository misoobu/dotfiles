-- Basic
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.breakindent = true
vim.opt.list = true
vim.opt.listchars = { tab = "␉·" }
vim.opt.mouse = ""
vim.opt.swapfile = false
vim.o.winborder = "rounded"
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "
vim.env.EDITOR =
  "uvx --from 'neovim-remote==2.5.1' nvr --nostart -cc split --remote-wait +'set bufhidden=delete'"
local augroup = vim.api.nvim_create_augroup("augroup", { clear = true })

-- Keymap
vim.keymap.set("n", "q", ":q<cr>")
vim.keymap.set("n", "<C-s>", ":w<cr>")
vim.keymap.set("i", "<C-s>", "<esc>")
vim.keymap.set("t", "<C-s>", "<C-\\><C-n>")
---- <C-w>hjkl works for in i and t like in n
vim.keymap.set("i", "<C-w>", "<esc><C-w>")
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>")
---- Window split
local function map_window_split_key(key, action, desc)
  vim.keymap.set("n", "<leader>w" .. key, action, { desc = "Window: " .. desc })
end
map_window_split_key("h", "<cmd>vertical leftabove split<cr>", "split toward left")
map_window_split_key("j", "<cmd>belowright split<cr>", "split toward below")
map_window_split_key("k", "<cmd>aboveleft split<cr>", "split toward above")
map_window_split_key("l", "<cmd>vertical rightbelow split<cr>", "split toward right")

-- Diagnostic
vim.keymap.set("n", "<C-n>", function()
  vim.diagnostic.jump({ count = 1, float = true })
end)
vim.keymap.set("n", "<C-p>", function()
  vim.diagnostic.jump({ count = -1, float = true })
end)

-- Terminal
local function open_terminal_split()
  vim.cmd("rightbelow vsplit")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
  end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  nested = true,
  callback = function()
    if not vim.env.NVIM then
      open_terminal_split()
    end
  end,
})
vim.api.nvim_create_user_command("T", function()
  vim.cmd("tabnew")
  vim.cmd("tcd ~")
  open_terminal_split()
end, { desc = "Open a new tab with a terminal split" })

-- Auto-reload files when modified externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup,
  command = "if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif",
})

-- Tabline
function _G.MyTabLine()
  local s = ""
  local cur = vim.fn.tabpagenr()
  local last = vim.fn.tabpagenr("$")

  for tab = 1, last do
    s = s .. (tab == cur and "%#TabLineSel#" or "%#TabLine#")

    local cwd = vim.fn.getcwd(-1, tab) -- tab-local cwd (:tcd)
    local name = vim.fn.fnamemodify(cwd, ":t") -- directory name only

    s = s .. " " .. tab .. ":" .. name .. " "
  end

  return s .. "%#TabLineFill#"
end
vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.MyTabLine()"

-- Plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out =
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  spec = {
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
          term_colors = true,
          auto_integrations = true,
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
      lazy = false,
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter").install({
          "lua",
          "vimdoc",
          "javascript",
          "typescript",
          "tsx",
          "jsx",
          "ruby",
          "python",
          "rust",
          "html",
          "css",
          "json",
          "markdown",
          "markdown_inline",
          "kotlin",
          "swift",
        })

        vim.api.nvim_create_autocmd("FileType", {
          pattern = {
            "lua",
            "vimdoc",
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "ruby",
            "python",
            "rust",
            "html",
            "css",
            "json",
            "markdown",
            "kotlin",
            "swift",
          },
          callback = function()
            vim.treesitter.start()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end,
        })
      end,
    },
    {
      "RRethy/vim-illuminate",
      event = "VeryLazy",
    },
    {
      "nvimdev/hlsearch.nvim",
      event = "BufRead",
      opts = {},
    },
    {
      "supermaven-inc/supermaven-nvim",
      opts = {
        disable_inline_completion = true, -- disables inline completion for use with cmp
        disable_keymaps = true, -- disables built in keymaps for more manual control
      },
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
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
        local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
        local lsp_servers = {
          -- `brew install lua-language-server`
          lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
          -- `gem install ruby-lsp`
          ruby_lsp = {},
          -- `brew install rust-analyzer`
          rust_analyzer = {
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  features = "all",
                },
                diagnostics = {
                  disabled = { "inactive-code" },
                },
              },
            },
          },
          -- `npm install -g @tailwindcss/language-server`
          tailwindcss = {
            filetypes = { "javascriptreact", "typescriptreact" },
          },
          basedpyright = {},
          sourcekit = {},
          -- `brew install JetBrains/utils/kotlin-lsp`
          kotlin_lsp = {},
        }

        vim.lsp.config("*", {
          capabilities = lsp_capabilities,
        })

        for server_name, server_config in pairs(lsp_servers) do
          vim.lsp.config(server_name, server_config)
          vim.lsp.enable(server_name)
        end

        require("typescript-tools").setup({})

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
            { name = "supermaven" },
          }, {
            { name = "buffer" },
          }),
          window = {
            -- completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
          },
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
      version = "*",
      dependencies = {
        "nvim-lua/plenary.nvim",
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          build = "make",
        },
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
        telescope.load_extension("file_browser")

        local builtin = require("telescope.builtin")

        local function map_telescope(key, action, desc)
          vim.keymap.set("n", "<leader>f" .. key, action, { desc = "Telescope: " .. desc })
        end

        map_telescope("f", builtin.git_files, "list git files")
        map_telescope("g", builtin.live_grep, "grep")
        map_telescope("c", builtin.grep_string, "grep cursor word")
        map_telescope("e", "<cmd>Telescope file_browser<cr>", "explore cwd")
        map_telescope(
          "p",
          "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>",
          "explore path"
        )

        map_telescope("t", function()
          builtin.buffers({ default_text = "term: " })
        end, "list term buffers")

        local function map_lsp(key, action, desc)
          vim.keymap.set("n", "<leader>l" .. key, action, { desc = "LSP: " .. desc })
        end
        -- NOTE: Use global `grn` for `vim.lsp.buf.rename`

        map_lsp("d", function()
          builtin.lsp_definitions({ jump_type = "split" })
        end, "definitions")
        map_lsp("i", function()
          builtin.lsp_implementations({ jump_type = "split" })
        end, "implementations")
        map_lsp("t", function()
          builtin.lsp_type_definitions({ jump_type = "split" })
        end, "type definitions")
        map_lsp("r", builtin.lsp_references, "references")
      end,
    },
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {},
      keys = {
        {
          "<leader>?",
          function()
            require("which-key").show({ global = false })
          end,
          desc = "Buffer Local Keymaps (which-key)",
        },
      },
    },
    { "lewis6991/gitsigns.nvim", opts = { signs_staged_enable = false } },
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
  },
})
