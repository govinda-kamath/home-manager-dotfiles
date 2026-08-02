{
  pkgs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true; # sets $EDITOR
    viAlias = true; # `vi` → nvim
    vimAlias = true; # `vim` → nvim

    plugins = with pkgs.vimPlugins; [
      # Theme — same catppuccin-mocha as ghostty
      catppuccin-nvim

      # LSP client (servers come from modules/dev.nix: pyright, rust-analyzer, gopls)
      nvim-lspconfig

      # Completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip
      luasnip
      friendly-snippets

      # Fuzzy finding
      telescope-nvim
      plenary-nvim

      # File tree
      neo-tree-nvim
      nvim-web-devicons

      # Git integration
      gitsigns-nvim

      # Editing niceties
      comment-nvim
      nvim-autopairs
      which-key-nvim
      undotree

      # Syntax highlighting — grammars compiled by nix, only for our languages
      (nvim-treesitter.withPlugins (p: [
        p."tree-sitter-python"
        p."tree-sitter-rust"
        p."tree-sitter-go"
        p."tree-sitter-bash"
        p."tree-sitter-lua"
        p."tree-sitter-markdown"
        p."tree-sitter-nix"
        p."tree-sitter-json"
        p."tree-sitter-yaml"
        p."tree-sitter-toml"
        p."tree-sitter-html"
        p."tree-sitter-css"
        p."tree-sitter-typescript"
        p."tree-sitter-comment"
        p."tree-sitter-gitcommit"
        p."tree-sitter-vim"
        p."tree-sitter-vimdoc"
        p."tree-sitter-make"
        p."tree-sitter-diff"
        p."tree-sitter-sql"
        p."tree-sitter-dockerfile"
      ]))
    ];

    extraLuaConfig = ''
      -- ── Options ──────────────────────────────────────────────────────────
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.cursorline = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"
      vim.opt.clipboard = "unnamedplus"
      vim.opt.mouse = "a"
      vim.opt.swapfile = false
      vim.opt.undofile = true
      vim.opt.scrolloff = 8
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.opt.timeoutlen = 400
      vim.opt.completeopt = "menu,menuone,noselect"

      -- ── Leader + theme ───────────────────────────────────────────────────
      vim.g.mapleader = " "
      vim.opt.background = "dark"
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme("catppuccin")

      -- ── Treesitter (grammars ship with nix, nothing to install at runtime)
      require("nvim-treesitter.configs").setup({
        ensure_installed = {},
        highlight = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      })

      -- ── which-key ────────────────────────────────────────────────────────
      require("which-key").setup({})

      -- ── LSP ──────────────────────────────────────────────────────────────
      -- Servers resolved from PATH: pyright, rust-analyzer, gopls (modules/dev.nix)
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>fmt", function() vim.lsp.buf.format({ async = true }) end, opts)
      end

      for _, server in ipairs({ "pyright", "rust_analyzer", "gopls" }) do
        lspconfig[server].setup({ capabilities = capabilities, on_attach = on_attach })
      end

      -- ── Completion (nvim-cmp + luasnip) ──────────────────────────────────
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
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
          { name = "path" },
        }),
      })

      -- ── Telescope ────────────────────────────────────────────────────────
      require("telescope").setup({})
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

      -- ── File tree ────────────────────────────────────────────────────────
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },
        window = { width = 30 },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", {})

      -- ── Git, comments, autopairs, undotree ───────────────────────────────
      require("gitsigns").setup({})
      require("Comment").setup({})
      require("nvim-autopairs").setup({})
      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, {})
    '';
  };
}
