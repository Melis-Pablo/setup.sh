--==================================================================
--[[
         .-') _      (`-.           _   .-')    _  .-')
        ( OO ) )   _(OO  )_        ( '.( OO )_ ( \( -O )
    ,--./ ,--,',--(_/   ,. \ ,-.-') ,--.   ,--.),------.   .-----.
    |   \ |  |\\   \   /(__/ |  |OO)|   `.'   | |   /`. ' '  .--./
    |    \|  | )\   \ /   /  |  |  \|         | |  /  | | |  |('-.
    |  .     |/  \   '   /,  |  |(_/|  |'.'|  | |  |_.' |/_) |OO  )
    |  |\    |    \     /__),|  |_.'|  |   |  | |  .  '.'||  |`-'|
    |  | \   |     \   /   (_|  |   |  |   |  | |  |\  \(_'  '--'\
    `--'  `--'      `-'      `--'   `--'   `--' `--' '--'  `-----'
--]]
--==================================================================

-- Cross-Platform Neovim Configuration
-- Compatible with macOS and Asahi Linux + Fedora

-- Dependencies: `git`, `make`, `unzip`, C Compiler (`gcc`), 'ripgrep'
-- Clipboard tool (pbcopy/pbpaste on macOS, xclip/xsel/wl-copy on Linux)

-- Platform detection
local is_macos = vim.fn.has('mac') == 1
local is_linux = vim.fn.has('unix') == 1 and not is_macos
local is_wsl = vim.fn.has('wsl') == 1

-- Set platform-specific variables
local function setup_platform()
    if is_macos then
        vim.g.platform = 'macos'
        vim.g.clipboard_cmd = 'pbcopy'
    elseif is_linux then
        vim.g.platform = 'linux'
        
        -- Check for Asahi Linux
        local cpuinfo = vim.fn.readfile('/proc/cpuinfo', '', 10)
        for _, line in ipairs(cpuinfo) do
            if string.match(line, 'Apple') then
                vim.g.is_asahi = true
                break
            end
        end
        
        -- Determine clipboard command
        if vim.fn.executable('wl-copy') == 1 then
            vim.g.clipboard_cmd = 'wl-copy'
        elseif vim.fn.executable('xclip') == 1 then
            vim.g.clipboard_cmd = 'xclip'
        elseif vim.fn.executable('xsel') == 1 then
            vim.g.clipboard_cmd = 'xsel'
        end
    elseif is_wsl then
        vim.g.platform = 'wsl'
        vim.g.clipboard_cmd = 'clip.exe'
    end
end

setup_platform()

--==================================================================
require "options"
--==================================================================
require "keymaps"
--==================================================================
require "autocommands"
--==================================================================

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

--==================================================================
-- [[ Configure and install plugins ]]
--  To check the current status of your plugins, run
--    :Lazy
--  You can press `?` in this menu for help. Use `:q` to close the window
--  To update plugins you can run
--    :Lazy update
require("lazy").setup("plugins", {
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or {
            cmd = '⌘',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀',
            task = '📌',
            lazy = '💤 ',
        },
    },
    -- Performance optimizations
    performance = {
        cache = {
            enabled = true,
        },
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
    -- Platform-specific plugin loading
    install = {
        colorscheme = { "lunaperche", "tokyonight" },
    },
})

-- Platform-specific optimizations
if vim.g.is_asahi then
    -- Asahi Linux specific optimizations
    vim.opt.lazyredraw = true
    vim.opt.ttyfast = true
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et