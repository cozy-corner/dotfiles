-- 基本設定
vim.opt.number = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.timeoutlen = 300

-- リーダーキーをスペースに設定
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ESC
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("v", "kj", "<Esc>", { noremap = true, silent = true })

-- バッファ移動のキーマッピング
vim.keymap.set("n", "[b", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "]b", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "[B", ":bfirst<CR>", { noremap = true, silent = true, desc = "First buffer" })
vim.keymap.set("n", "]B", ":blast<CR>", { noremap = true, silent = true, desc = "Last buffer" })

-- コマンドラインで%%を現在のファイルのディレクトリに展開
vim.keymap.set("c", "%%", function()
  if vim.fn.getcmdtype() == ":" then
    return vim.fn.expand("%:h") .. "/"
  else
    return "%%"
  end
end, { expr = true })

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
  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = false,
      })
      vim.cmd.colorscheme("catppuccin")
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

  -- render-markdown.nvim: Markdownのリッチ表示
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      -- Insert modeでレンダリングを無効化
      modes = { "n", "c", "v" }, -- normal, command, visual modeのみ
      -- カーソル行も通常表示
      anti_conceal = {
        enabled = true,
      },
      -- 余白を無効化（ペインいっぱいに表示）
      padding = {
        highlight = nil,
      },
      win_options = {
        conceallevel = {
          default = 2,
          rendered = 2,
        },
        concealcursor = {
          default = "",
          rendered = "",
        },
      },
    },
    ft = { "markdown" },
  },

  -- markdown-preview.nvim: ブラウザでMarkdown/Mermaidプレビュー
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0 -- プレビューを閉じてもブラウザを閉じない
      vim.g.mkdp_theme = "dark" -- dark テーマ
      vim.g.mkdp_markdown_css = vim.fn.stdpath("config") .. "/markdown.css"

      -- キーマッピング
      vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { noremap = true, silent = true, desc = "Markdown preview" })
      vim.keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { noremap = true, silent = true, desc = "Stop markdown preview" })
    end,
    ft = { "markdown" },
  },

  -- obsidian.nvim: Obsidian vault連携
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    opts = {
      legacy_commands = false,
      workspaces = {
        { path = vim.env.OBSIDIAN_VAULT },
      },
      picker = {
        name = "telescope.nvim",
      },
      -- render-markdown.nvimが描画を担当するため無効化（二重描画回避）
      ui = {
        enable = false,
      },
      -- 既存ノートへのtype後付けを可能にしつつ、id/aliases/tagsの自動付与は抑止（gitノイズ回避）
      frontmatter = {
        enabled = true,
        func = function(note)
          return note.metadata or {}
        end,
      },
      new_notes_location = "notes_subdir",
      notes_subdir = nil,
      -- ファイル名をタイトルそのままに（既存の命名規則に合わせる）
      note_id_func = function(title)
        if title ~= nil and title ~= "" then
          return title
        end
        return tostring(os.time())
      end,
      daily_notes = {
        folder = nil,
        date_format = "YYYY-MM-DD",
        template = "diary.md",
        default_tags = {},
      },
      templates = {
        folder = "templates",
      },
      completion = {
        min_chars = 2,
      },
    },
  },

  -- Telescope: ファジーファインダー
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Which-key: キーバインディングのヘルプ表示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    config = function()
      require("which-key").setup()
    end,
  },

  -- nvim-surround: 囲み文字の操作
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- Comment.nvim: コメントアウトの操作
  {
    "numToStr/Comment.nvim",
    opts = {},
    config = function()
      require("Comment").setup()
    end,
  },

  -- flash.nvim: 高速な移動とテキスト選択
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- nvim-tree: ファイルエクスプローラー
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- disable netrw at the very start of your init.lua
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- enable 24-bit colour
      vim.opt.termguicolors = true

      require("nvim-tree").setup({
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })

      -- キーマッピング
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle file explorer" })
      vim.keymap.set("n", "<leader>fe", ":NvimTreeFindFile<CR>", { noremap = true, silent = true, desc = "Find current file in explorer" })
    end,
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
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 全サーバー共通の設定（capabilitiesをワイルドカードでマージ）
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- lua_ls用の特別な設定
      vim.lsp.config("lua_ls", {
        settings = {
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
        },
      })

      -- LSPサーバーを有効化
      vim.lsp.enable({
        "lua_ls",
        "ts_ls",
        "pyright",
        "rust_analyzer",
        "kotlin_language_server",
        "fsautocomplete",
      })

      -- LSP attach時のキーマッピング設定
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf, noremap = true, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          -- vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, noremap = true, silent = true, desc = "Rename symbol" })
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, noremap = true, silent = true, desc = "Code action" })
          vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format { async = true }
          end, { buffer = ev.buf, noremap = true, silent = true, desc = "Format code" })
          vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
          vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { buffer = ev.buf, noremap = true, silent = true, desc = "Show diagnostics" })
          vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { buffer = ev.buf, noremap = true, silent = true, desc = "Diagnostic list" })
        end,
      })
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

  -- csvview.nvim: CSVファイルのテーブル表示
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    config = function()
      require("csvview").setup({
        view = {
          display_mode = "border", -- "border"または"highlight"
        },
        keymaps = {
          -- テキストオブジェクト（CSVファイルでのみ有効）
          textobject_field_inner = { "if", mode = { "o", "x" } },
          textobject_field_outer = { "af", mode = { "o", "x" } },
        },
      })

      -- CSVファイルを開いたときに自動で有効化
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "csv", "tsv" },
        callback = function()
          vim.cmd("CsvViewEnable")
        end,
      })
    end,
  },

})

-- Telescopeキーマッピング
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Search in current buffer' })
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })

vim.api.nvim_create_user_command("Vb", function()
  vim.cmd([[!git -C "$OBSIDIAN_VAULT" add -A && git -C "$OBSIDIAN_VAULT" commit -m "vault backup: $(date '+\%Y-\%m-\%d \%H:\%M:\%S')" && git -C "$OBSIDIAN_VAULT" pull --no-edit && git -C "$OBSIDIAN_VAULT" push]])
end, { desc = "Vault backup (git add+commit+pull+push)" })

-- Obsidian操作（すべて <leader>o 配下）
-- ナビゲーション
vim.keymap.set('n', '<leader>ob', '<cmd>Obsidian backlinks<cr>', { desc = 'backlinks' })
vim.keymap.set('n', '<leader>od', '<cmd>Obsidian today<cr>',     { desc = 'today (daily)' })

-- 種別テンプレを現在のノートに適用（箱→後から種別付け）
vim.keymap.set('n', '<leader>otf', '<cmd>Obsidian template fleeting<cr>',   { desc = 'type: fleeting' })
vim.keymap.set('n', '<leader>otp', '<cmd>Obsidian template permanent<cr>',  { desc = 'type: permanent' })
vim.keymap.set('n', '<leader>otl', '<cmd>Obsidian template literature<cr>', { desc = 'type: literature' })
vim.keymap.set('n', '<leader>ots', '<cmd>Obsidian template structure<cr>',  { desc = 'type: structure' })
vim.keymap.set('n', '<leader>otd', '<cmd>Obsidian template diary<cr>',      { desc = 'type: diary' })

-- テンプレから新規ノートを作成（タイトルを聞いてから作る）
local function new_from_template(template)
  vim.ui.input({ prompt = 'Title: ' }, function(title)
    if title and title ~= '' then
      vim.cmd('Obsidian new_from_template ' .. title .. ' ' .. template)
    end
  end)
end
vim.keymap.set('n', '<leader>onf', function() new_from_template('fleeting') end,   { desc = 'new: fleeting' })
vim.keymap.set('n', '<leader>onp', function() new_from_template('permanent') end,  { desc = 'new: permanent' })
vim.keymap.set('n', '<leader>onl', function() new_from_template('literature') end, { desc = 'new: literature' })
vim.keymap.set('n', '<leader>ons', function() new_from_template('structure') end,  { desc = 'new: structure' })

-- Which-keyグループ登録
local wk = require("which-key")
wk.add({
  { "<leader>f", group = "Find" },
  { "<leader>g", group = "Git" },
  { "<leader>o", group = "Obsidian" },
  { "<leader>ot", group = "apply template" },
  { "<leader>on", group = "new note" },
})

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
