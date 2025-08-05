-- 基本設定
vim.opt.number = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- リーダーキーをスペースに設定
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- カラースキーム
vim.cmd.colorscheme("habamax")

-- lazy.nvimのセットアップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.mkdir(vim.fn.stdpath("data") .. "/lazy", "p")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to install lazy.nvim. Please check your network connection.", vim.log.levels.ERROR)
    return
  end
end
vim.opt.rtp:prepend(lazypath)

-- プラグイン設定
require("lazy").setup({
  -- Treesitter: シンタックスハイライト
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- マークダウンとよく使う言語パーサー
        ensure_installed = { 
          "markdown", 
          "markdown_inline",
          "javascript",
          "typescript", 
          "python",
          "bash",
          "json",
          "lua",
          "yaml",
          "html",
          "css",
          "kotlin",
          "rust",
          "go",
          "sql",
          "dockerfile",
          "toml",
          "vim"
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
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              preview_width = 0.5,
            },
          },
        },
      })
    end,
  },
})

-- Telescopeキーマッピング
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Telescope recent files' })
vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Telescope git commits' })
vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Telescope git status' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Telescope git files' })
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Telescope git branches' })

-- 設定リロード
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "init.lua",
  command = "source %",
})