-- 基本設定
vim.opt.number = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.hlsearch = true
vim.opt.incsearch = true

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
})

-- 設定リロード
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "init.lua",
  command = "source %",
})