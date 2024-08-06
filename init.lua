vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false
vim.opt.showmode = false
vim.opt.wrap = false

vim.opt.number = true
vim.opt.mouse = 'a'
vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'
end) -- reschedule to reduce startup-time
vim.opt.breakindent = true
vim.opt.ignorecase = true -- for search
vim.opt.smartcase = true -- for search
vim.opt.cursorline = true
vim.opt.scrolloff = 10 -- minimal number of lines below the cursor
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.background = 'dark'

vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })
-- Visual mode mappings for continuous indentation
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true })
-- Key mappings for navigating diagnostics
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })

-- Return to the last edit position when reopening a file
vim.api.nvim_create_autocmd('BufReadPost', {
    pattern = '*',
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local line_count = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.api.nvim_win_set_cursor(0, mark)
        end
    end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    -- colorsheme that will be used when installing plugins
    spec = {
        {
            'Mofiqul/vscode.nvim',
            priority = 1000,
            transparent = true,
            italic_comments = false,
            underline_links = true,
            disable_nvimtree_bg = true,
            color_overrides = { vscLineNumber = '#FFFFFF' },
            init = function()
                -- vim.cmd.colorscheme 'vscode'
            end,
        },
        {
            "neanias/everforest-nvim",
            version = false,
            lazy = false,
            priority = 1000,
            config = function()
                require("everforest").setup({
                    background = "hard",
                    transparent_background_level = 0,
                    italics = false,
                    disable_italic_comments = true,
                    sign_column_background = "none",
                    ui_contrast = "low",
                    dim_inactive_windows = false,
                    diagnostic_text_highlight = false,
                    diagnostic_virtual_text = "coloured",
                    diagnostic_line_highlight = false,
                    spell_foreground = false,
                    show_eob = true,
                    float_style = "bright",
                    inlay_hints_background = "none",
                    on_highlights = function(highlight_groups, palette) end,
                    colours_override = function(palette) end,
                })
            end,
            init = function()
                vim.cmd.colorscheme 'everforest'
            end,
        },
        {
            'folke/todo-comments.nvim',
            event = 'VimEnter',
            dependencies = { 'nvim-lua/plenary.nvim' },
            opts = { signs = false }
        },
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            config = function()
                require'lualine'.setup {
                    options = {
                        icons_enabled = true,
                        theme = 'auto',
                        component_separators = { left = '', right = ''},
                        section_separators = { left = '', right = ''},
                        disabled_filetypes = {
                            statusline = {},
                            winbar = {},
                        },
                        ignore_focus = {},
                        always_divide_middle = true,
                        globalstatus = false,
                        refresh = {
                            statusline = 1000,
                            tabline = 1000,
                            winbar = 1000,
                        }
                    },
                    sections = {
                        lualine_a = {'mode'},
                        lualine_b = {'branch', 'diff', 'diagnostics'},
                        lualine_c = {'filename'},
                        lualine_x = {'encoding', 'fileformat', 'filetype'},
                        lualine_y = {'progress'},
                        lualine_z = {'location'}
                    },
                    inactive_sections = {
                        lualine_a = {},
                        lualine_b = {},
                        lualine_c = {'filename'},
                        lualine_x = {'location'},
                        lualine_y = {},
                        lualine_z = {}
                    },
                    tabline = {},
                    winbar = {},
                    inactive_winbar = {},
                    extensions = {}
                }
            end,
        },
        {
            'nvim-treesitter/nvim-treesitter',
            build = ':TSUpdate',
            opts = {
                ensure_installed = { 'cpp', 'c', 'python', 'rust', 'lua', 'bash' },
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = { 'ruby' },
                },
                indent = { enable = true, disable = { 'ruby' } },
            },
            config = function(_, opts)
                ---@diagnostic disable-next-line: missing-fields
                require('nvim-treesitter.configs').setup(opts)
            end,
        },
        { -- Fuzzy Finder (files, lsp, etc)
            'nvim-telescope/telescope.nvim',
            event = 'VimEnter',
            branch = '0.1.x',
            dependencies = {
                'nvim-lua/plenary.nvim',
                {
                    'nvim-telescope/telescope-fzf-native.nvim',
                    build = 'make',
                    cond = function()
                        return vim.fn.executable 'make' == 1
                    end,
                },
                { 'nvim-telescope/telescope-ui-select.nvim' },
                { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
            },
            config = function()
                require('telescope').setup {
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown(),
                    },
                },
            }
            -- Enable Telescope extensions if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')

            -- See `:help telescope.builtin`
            local builtin = require 'telescope.builtin'
            vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
            vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
            vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
            vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
            vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
            vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
            vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
            vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
            vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
            vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

            -- Slightly advanced example of overriding default behavior and theme
            vim.keymap.set('n', '<leader>/', function()
                -- You can pass additional configuration to Telescope to change the theme, layout, etc.
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                })
            end, { desc = '[/] Fuzzily search in current buffer' })

            -- It's also possible to pass additional configuration options.
            --  See `:help telescope.builtin.live_grep()` for information about particular keys
            vim.keymap.set('n', '<leader>s/', function()
            builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files',
            }
            end, { desc = '[S]earch [/] in Open Files' })
            -- Shortcut for searching your Neovim configuration files
            vim.keymap.set('n', '<leader>sn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
            end, { desc = '[S]earch [N]eovim files' })
        end,
        },
        {
            'neovim/nvim-lspconfig',
            dependences = {
                { 'williamboman/mason.nvim', config = true },
                'williamboman/mason-lspconfig.nvim',
                'WhoIsSethDaniel/mason-tool-installer.nvim',
                { 'j-hui/fidget.nvim', opts = {} },
                'hrsh7th/cmp-nvim-lsp',
            },
            config = function()
                require'lspconfig'.pyright.setup{}
                require'lspconfig'.rust_analyzer.setup{}
                require'lspconfig'.clangd.setup{}
                require'lspconfig'.lua_ls.setup{
                    settings = {
                        Lua = {
                            diagnostics = { globals = { 'vim' } }
                        }
                    }
                }
                vim.api.nvim_create_autocmd('LspAttach', {
                    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                    callback = function(event)
                        local map = function(keys, func, desc)
                            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                        end
                        -- Jump to the definition of the word under your cursor.
                        --  This is where a variable was first declared, or where a function is defined, etc.
                        --  To jump back, press <C-t>.
                        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                        -- Find references for the word under your cursor.
                        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                        -- Jump to the implementation of the word under your cursor.
                        --  Useful when your language has ways of declaring types without an actual implementation.
                        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                        -- Jump to the type of the word under your cursor.
                        --  Useful when you're not sure what type a variable is and you want to see
                        --  the definition of its *type*, not where it was *defined*.
                        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
                        -- Fuzzy find all the symbols in your current document.
                        --  Symbols are things like variables, functions, types, etc.
                        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                        -- Fuzzy find all the symbols in your current workspace.
                        --  Similar to document symbols, except searches over your entire project.
                        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
                        -- Rename the variable under your cursor.
                        --  Most Language Servers support renaming across files, etc.
                        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                        -- Execute a code action, usually your cursor needs to be on top of an error
                        -- or a suggestion from your LSP for this to activate.
                        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
                        -- WARN: This is not Goto Definition, this is Goto Declaration.
                        --  For example, in C this would take you to the header.
                        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                        local client = vim.lsp.get_client_by_id(event.data.client_id)
                        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                                buffer = event.buf,
                                group = highlight_augroup,
                                callback = vim.lsp.buf.document_highlight,
                            })
                            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                                buffer = event.buf,
                                group = highlight_augroup,
                                callback = vim.lsp.buf.clear_references,
                            })
                            vim.api.nvim_create_autocmd('LspDetach', {
                                group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                                callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                                end,
                            })
                        end
                        -- The following code creates a keymap to toggle inlay hints in your
                        -- code, if the language server you are using supports them
                        --
                        -- This may be unwanted, since they displace some of your code
                        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                            map('<leader>th', function()
                                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                            end, '[T]oggle Inlay [H]ints')
                        end
                    end
                })
                -- LSP servers and clients are able to communicate to each other what features they support.
                --  By default, Neovim doesn't support everything that is in the LSP specification.
                --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
                --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
                local capabilities = vim.lsp.protocol.make_client_capabilities()
                capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
            end,
        },
        {
            'windwp/nvim-autopairs',
            event = "InsertEnter",
            config = true
        },
        {
            'hrsh7th/nvim-cmp',
            event = 'insertEnter',
            dependencies = {
                {
                    'L3MON4D3/LuaSnip',
                    build = (function()
                        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                            return
                        end
                        return 'make install_jsregexp'
                    end)()
                },
                'saadparwaiz1/cmp_luasnip',
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-path',
            },
            config = function()
                local cmp = require 'cmp'
                local luasnip = require 'luasnip'
                luasnip.config.setup {}
                cmp.setup {
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_extend(args.body)
                        end,
                    },
                    completion = { completeopt = 'menu,menuone,noinsert' },
                    mapping = cmp.mapping.preset.insert {
                        -- Select the [n]ext item
                        ['<C-n>'] = cmp.mapping.select_next_item(),
                        -- Select the [p]revious item
                        ['<C-p>'] = cmp.mapping.select_prev_item(),
                        -- Scroll the documentation window [b]ack / [f]orward
                        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-f>'] = cmp.mapping.scroll_docs(4),
                        -- Accept ([y]es) the completion.
                        --  This will auto-import if your LSP supports it.
                        --  This will expand snippets if the LSP sent a snippet.
                        ['<C-y>'] = cmp.mapping.confirm { select = true },
                        -- If you prefer more traditional completion keymaps,
                        -- you can uncomment the following lines
                        ['<CR>'] = cmp.mapping.confirm { select = true },
                        ['<Tab>'] = cmp.mapping.select_next_item(),
                        --['<S-Tab>'] = cmp.mapping.select_prev_item(),
                        --
                        -- Manually trigger a completion from nvim-cmp.
                        --  Generally you don't need this, because nvim-cmp will display
                        --  completions whenever it has completion options available.
                        ['<C-Space>'] = cmp.mapping.complete {},
                        -- Think of <c-l> as moving to the right of your snippet expansion.
                        --  So if you have a snippet that's like:
                        --  function $name($args)
                        --    $body
                        --  end
                        --
                        -- <c-l> will move you to the right of each of the expansion locations.
                        -- <c-h> is similar, except moving you backwards.
                        ['<C-l>'] = cmp.mapping(function()
                            if luasnip.expand_or_locally_jumpable() then
                                luasnip.expand_or_jump()
                            end
                        end, { 'i', 's' }),
                        ['<C-h>'] = cmp.mapping(function()
                            if luasnip.locally_jumpable(-1) then
                                luasnip.jump(-1)
                            end
                        end, { 'i', 's' }),
                        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
                        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
                    },
                    sources = {
                        {
                            name = 'lazydev',
                            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
                            group_index = 0,
                        },
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' },
                        { name = 'path' },
                    },
                }
            end
        },
    },

    -- update checker
    install = { colorscheme = {'everforest'} },
    checker = { enabled = true },
})
