# Neovim configuration with modern setup
{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # LSP servers and language tools
    extraPackages = with pkgs; [
      # LSP servers
      nil                    # Nix LSP
      rust-analyzer         # Rust LSP
      gopls                 # Go LSP
      nodePackages.typescript-language-server  # TypeScript LSP
      nodePackages.vscode-langservers-extracted  # HTML/CSS/JSON LSP
      pyright               # Python LSP
      lua-language-server   # Lua LSP
      marksman             # Markdown LSP
      
      # Formatters
      nixpkgs-fmt          # Nix formatter
      rustfmt              # Rust formatter
      gofumpt              # Go formatter
      nodePackages.prettier # Web formatter
      black                # Python formatter
      stylua               # Lua formatter
      
      # Linters  
      statix               # Nix linter
      deadnix              # Dead Nix code finder
      golangci-lint        # Go linter
      ruff                 # Python linter
      
      # Tree-sitter (for better syntax highlighting)
      tree-sitter
      
      # Debugging
      delve                # Go debugger
      
      # Other tools
      ripgrep              # For telescope
      fd                   # For telescope
      nodejs               # For some plugins
      git                  # For git integration
    ];

    plugins = with pkgs.vimPlugins; [
      # Plugin manager and core
      lazy-nvim

      # LSP and completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets

      # Treesitter for syntax highlighting
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      nvim-treesitter-textobjects

      # Fuzzy finder
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim

      # File explorer
      nvim-tree-lua
      nvim-web-devicons

      # Git integration
      gitsigns-nvim
      fugitive
      vim-rhubarb

      # Status line and UI
      lualine-nvim
      bufferline-nvim
      alpha-nvim
      dressing-nvim
      noice-nvim
      nui-nvim
      nvim-notify

      # Color schemes
      catppuccin-nvim
      tokyonight-nvim
      gruvbox-nvim
      kanagawa-nvim

      # Editing enhancements
      mini-nvim
      nvim-autopairs
      nvim-surround
      comment-nvim
      indent-blankline-nvim
      nvim-colorizer-lua

      # Terminal integration
      toggleterm-nvim

      # Which-key for keybinding help
      which-key-nvim

      # Mason for managing LSP servers
      mason-nvim
      mason-lspconfig-nvim

      # Formatting
      conform-nvim

      # Linting
      nvim-lint

      # Session management
      persistence-nvim

      # Language specific
      rust-tools-nvim
      go-nvim
      typescript-nvim
    ];

    extraLuaConfig = ''
      -- Set leader key
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"

      -- Basic settings
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.signcolumn = "yes"
      vim.opt.wrap = false
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.autoindent = true
      vim.opt.smartindent = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.incsearch = true
      vim.opt.hlsearch = true
      vim.opt.showmatch = true
      vim.opt.cursorline = true
      vim.opt.termguicolors = true
      vim.opt.background = "dark"
      vim.opt.scrolloff = 8
      vim.opt.sidescrolloff = 8
      vim.opt.mouse = "a"
      vim.opt.clipboard = "unnamedplus"
      vim.opt.splitbelow = true
      vim.opt.splitright = true
      vim.opt.timeoutlen = 1000
      vim.opt.updatetime = 250
      vim.opt.undofile = true
      vim.opt.swapfile = false
      vim.opt.backup = false

      -- Color scheme
      require("catppuccin").setup({
        flavour = "macchiato",
        transparent_background = false,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          telescope = true,
          which_key = true,
        }
      })
      vim.cmd.colorscheme "catppuccin"

      -- LSP configuration
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Configure LSP servers
      local servers = {
        nil_ls = {},
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy"
              }
            }
          }
        },
        gopls = {},
        tsserver = {},
        pyright = {},
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { library = vim.api.nvim_get_runtime_file("", true) },
              telemetry = { enable = false },
            }
          }
        },
        html = {},
        cssls = {},
        jsonls = {},
        marksman = {},
      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end

      -- Completion setup
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })

      -- Treesitter configuration
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = false,
            node_decremental = '<bs>',
          },
        },
      })

      -- Telescope configuration
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git", "target" },
          mappings = {
            i = {
              ["<C-h>"] = "which_key"
            }
          }
        },
        pickers = {
          find_files = {
            hidden = true
          }
        }
      })

      -- File explorer
      require('nvim-tree').setup({
        disable_netrw = true,
        hijack_netrw = true,
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          highlight_git = true,
          icons = {
            show = {
              git = true,
            }
          }
        },
        filters = {
          dotfiles = false,
        }
      })

      -- Status line
      require('lualine').setup({
        options = {
          theme = 'catppuccin',
          icons_enabled = true,
        }
      })

      -- Git signs
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        }
      })

      -- Key mappings
      local function map(mode, lhs, rhs, opts)
        opts = opts or {}
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      -- General mappings
      map('n', '<leader>w', '<cmd>write<cr>')
      map('n', '<leader>q', '<cmd>quit<cr>')
      map('n', '<Esc>', '<cmd>nohlsearch<CR>')

      -- File explorer
      map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>')

      -- Telescope
      map('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
      map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
      map('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
      map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')

      -- LSP mappings
      map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
      map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
      map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
      map('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
      map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
      map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>')
      map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>')

      -- Git
      map('n', '<leader>gb', '<cmd>Gitsigns blame_line<cr>')
      map('n', '<leader>gd', '<cmd>Gitsigns diffthis<cr>')

      -- Buffer navigation
      map('n', '<leader>bn', '<cmd>bnext<cr>')
      map('n', '<leader>bp', '<cmd>bprev<cr>')
      map('n', '<leader>bd', '<cmd>bdelete<cr>')

      -- Terminal
      require('toggleterm').setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        direction = 'horizontal',
      })

      -- Which-key setup
      require('which-key').setup({})

      -- Auto pairs
      require('nvim-autopairs').setup({})

      -- Comment
      require('Comment').setup({})

      -- Indent blankline
      require('ibl').setup({})

      -- Load snippets
      require("luasnip.loaders.from_vscode").lazy_load()
    '';
  };
}