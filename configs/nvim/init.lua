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

-- Depencencies: `git`, `make`, `unzip`, C Compiler (`gcc`), 'ripgrep'
-- Clipboard tool (xclip/xsel/win32yank or other depending on the platform)
-- https://learnxinyminutes.com/docs/lua/
-- :help lua-guide
-- :Tutor
-- <leader>sh to [s]earch the [h]elp documentation.

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
require("lazy").setup "plugins"
require('lazy').setup {
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
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
