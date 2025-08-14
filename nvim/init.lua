-- 基本設定
vim.opt.number = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- リーダーキーをスペースに設定
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- lazy.nvimのセットアップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.mkdir(vim.fn.stdpath("data") .. "/lazy", "p")
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

-- プラグイン設定
require("lazy").setup({
  -- Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "medium", -- hard, medium, soft
        transparent_mode = false,
      })
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  -- Treesitter: シンタックスハイライト
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- 最小限のパーサー（他はauto_installで必要時にインストール）
        ensure_installed = {
          "lua",
          "vim",
        },
        -- ファイルを開いたときに自動で言語パーサーをインストール
        auto_install = true,
        highlight = {
          enable = true,
        },
      })
    end,
  },

  -- Telescope: ファジーファインダー
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Mason: LSPサーバー管理
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "pyright",
          "rust_analyzer",
          "kotlin_language_server",
          "fsautocomplete",
        },
        automatic_enable = false,
      })
    end,
  },

  -- LSP設定
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- LSP共通のキーマッピング設定
      local function lsp_keymaps(_, bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>f", function()
          vim.lsp.buf.format { async = true }
        end, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
      end
      
      -- LSPサーバーのリスト
      local servers = {
        "lua_ls",
        "ts_ls",
        "pyright",
        "rust_analyzer",
        "kotlin_language_server",
        "fsautocomplete",
      }
      
      -- 基本的なLSPサーバーの設定
      for _, lsp in ipairs(servers) do
        local config = {
          capabilities = capabilities,
          on_attach = lsp_keymaps,
        }
        
        -- lua_ls用の特別な設定
        if lsp == "lua_ls" then
          config.settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          }
        end
        
        lspconfig[lsp].setup(config)
      end
    end,
  },

  -- 補完エンジン
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
    },
  },

})

-- Telescopeキーマッピング
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Telescope recent files' })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Telescope git commits' })
vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Telescope git status' })
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Telescope git branches' })

-- 補完の設定
local cmp = require("cmp")

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
  }, {
    { name = "path" },
  }),
})

-- 診断表示の設定
vim.diagnostic.config({
  update_in_insert = false,
})
