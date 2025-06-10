-- Cross-Platform Neovim Options Configuration

-- Disable netrw (replaced by neo-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Platform detection variables (set in init.lua)
local is_macos = vim.g.platform == 'macos'
local is_linux = vim.g.platform == 'linux'
local is_asahi = vim.g.is_asahi or false

-- [[ Setting options ]]
-- See `:help vim.opt`
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
    if is_macos then
        vim.opt.clipboard = 'unnamedplus'
    elseif is_linux then
        -- Check for available clipboard utilities
        if vim.fn.executable('wl-copy') == 1 and vim.fn.executable('wl-paste') == 1 then
            -- Wayland
            vim.g.clipboard = {
                name = 'wl-clipboard',
                copy = {
                    ['+'] = 'wl-copy',
                    ['*'] = 'wl-copy',
                },
                paste = {
                    ['+'] = 'wl-paste --no-newline',
                    ['*'] = 'wl-paste --no-newline',
                },
                cache_enabled = 0,
            }
            vim.opt.clipboard = 'unnamedplus'
        elseif vim.fn.executable('xclip') == 1 then
            -- X11 with xclip
            vim.g.clipboard = {
                name = 'xclip',
                copy = {
                    ['+'] = 'xclip -selection clipboard',
                    ['*'] = 'xclip -selection primary',
                },
                paste = {
                    ['+'] = 'xclip -selection clipboard -o',
                    ['*'] = 'xclip -selection primary -o',
                },
                cache_enabled = 0,
            }
            vim.opt.clipboard = 'unnamedplus'
        elseif vim.fn.executable('xsel') == 1 then
            -- X11 with xsel
            vim.g.clipboard = {
                name = 'xsel',
                copy = {
                    ['+'] = 'xsel --clipboard --input',
                    ['*'] = 'xsel --primary --input',
                },
                paste = {
                    ['+'] = 'xsel --clipboard --output',
                    ['*'] = 'xsel --primary --output',
                },
                cache_enabled = 0,
            }
            vim.opt.clipboard = 'unnamedplus'
        else
            -- Fallback: no clipboard integration
            vim.notify('No clipboard utility found. Install wl-clipboard, xclip, or xsel.', vim.log.levels.WARN)
        end
    end
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 5

-- Set tab to 4 spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

-- Smart indentations
vim.opt.smartindent = true

-- Incremental search enabled
vim.opt.incsearch = true

-- Terminal gui colors
vim.opt.termguicolors = true

-- No vim backup but allow undotree plugin to have access to long running undos
vim.opt.swapfile = false
vim.opt.backup = false

-- Platform-specific undo directory
if is_macos then
    vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
elseif is_linux then
    local xdg_cache_home = os.getenv("XDG_CACHE_HOME") or os.getenv("HOME") .. "/.cache"
    vim.opt.undodir = xdg_cache_home .. "/nvim/undodir"
    -- Ensure the directory exists
    vim.fn.mkdir(vim.opt.undodir:get(), "p")
else
    vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
end

vim.opt.undofile = true

-- Platform-specific optimizations
if is_asahi then
    -- Asahi Linux specific optimizations for Apple Silicon
    vim.opt.lazyredraw = true
    vim.opt.regexpengine = 1  -- Use old regexp engine for better performance
    vim.opt.synmaxcol = 200   -- Limit syntax highlighting for long lines
end

-- File encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- Search settings
vim.opt.hlsearch = true
vim.opt.wrapscan = true

-- Window settings
vim.opt.winminheight = 0
vim.opt.winminwidth = 0

-- Command line settings
vim.opt.cmdheight = 1
vim.opt.showcmd = true
vim.opt.cmdheight = 1

-- Status line
vim.opt.laststatus = 2

-- Wild menu
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest:full,full'

-- Completion settings
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.pumheight = 10

-- Folding
vim.opt.foldmethod = 'indent'
vim.opt.foldlevel = 99
vim.opt.foldenable = false

-- Session settings
vim.opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }

-- Diff settings
vim.opt.diffopt:append('algorithm:patience')
vim.opt.diffopt:append('indent-heuristic')

-- Format settings
vim.opt.formatoptions:remove('o')  -- Don't insert comment leader after 'o' or 'O'
vim.opt.formatoptions:append('j')  -- Remove comment leader when joining lines

-- Platform-specific shell settings
if is_macos then
    -- macOS typically uses zsh
    if vim.fn.executable('zsh') == 1 then
        vim.opt.shell = 'zsh'
    end
elseif is_linux then
    -- Linux typically uses bash, but check for zsh
    if vim.fn.executable('zsh') == 1 then
        vim.opt.shell = 'zsh'
    elseif vim.fn.executable('bash') == 1 then
        vim.opt.shell = 'bash'
    end
end

-- Python provider settings (cross-platform)
local function setup_python_provider()
    -- Disable Python 2 provider
    vim.g.loaded_python_provider = 0
    
    -- Set up Python 3 provider
    if is_macos then
        -- macOS with Homebrew
        if vim.fn.executable('/opt/homebrew/bin/python3') == 1 then
            vim.g.python3_host_prog = '/opt/homebrew/bin/python3'
        elseif vim.fn.executable('/usr/local/bin/python3') == 1 then
            vim.g.python3_host_prog = '/usr/local/bin/python3'
        elseif vim.fn.executable('python3') == 1 then
            vim.g.python3_host_prog = vim.fn.exepath('python3')
        end
    elseif is_linux then
        -- Linux
        if vim.fn.executable('python3') == 1 then
            vim.g.python3_host_prog = vim.fn.exepath('python3')
        elseif vim.fn.executable('/usr/bin/python3') == 1 then
            vim.g.python3_host_prog = '/usr/bin/python3'
        end
    end
end

setup_python_provider()

-- Node.js provider settings
local function setup_node_provider()
    if is_macos then
        -- macOS with Homebrew
        if vim.fn.executable('/opt/homebrew/bin/node') == 1 then
            vim.g.node_host_prog = '/opt/homebrew/bin/neovim-node-host'
        elseif vim.fn.executable('/usr/local/bin/node') == 1 then
            vim.g.node_host_prog = '/usr/local/bin/neovim-node-host'
        end
    elseif is_linux then
        -- Linux
        if vim.fn.executable('node') == 1 then
            local node_modules_path = vim.fn.expand('~/.local/share/nvim/node_modules')
            vim.g.node_host_prog = node_modules_path .. '/.bin/neovim-node-host'
        end
    end
end

setup_node_provider()

-- GUI-specific settings
if vim.g.neovide then
    -- Neovide GUI settings
    vim.g.neovide_scale_factor = 1.0
    vim.g.neovide_padding_top = 0
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0
    
    -- Platform-specific font settings for Neovide
    if is_macos then
        vim.o.guifont = "JetBrains Mono:h14"
    else
        vim.o.guifont = "JetBrains Mono:h11"
    end
    
    vim.g.neovide_cursor_animation_length = 0.1
    vim.g.neovide_cursor_trail_size = 0.8
    vim.g.neovide_cursor_antialiasing = true
    vim.g.neovide_cursor_animate_in_insert_mode = true
    vim.g.neovide_cursor_animate_command_line = true
    vim.g.neovide_cursor_unfocused_outline_width = 0.125
end

-- Terminal settings
if vim.fn.exists('$TMUX') == 1 then
    vim.opt.t_8f = '<Esc>[38;2;%lu;%lu;%lum'
    vim.opt.t_8b = '<Esc>[48;2;%lu;%lu;%lum'
end

-- Performance settings for different platforms
if is_asahi then
    -- Additional performance optimizations for Asahi Linux
    vim.opt.lazyredraw = true
    vim.opt.ttyfast = true
    vim.opt.redrawtime = 1500
    vim.opt.timeoutlen = 500
    vim.opt.ttimeoutlen = 10
end