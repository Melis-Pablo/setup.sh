-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
    'nvim-neo-tree/neo-tree.nvim',
    lazy = false,
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
        'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
        { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
        filesystem = {
            width = 10,
            hijack_netrw_behavior = "open_current", -- netrw disabled, opening a directory opens within the window like netrw would, regardless of window.position
            window = {
                mappings = {
                    ["%"] = "add",           -- Create a new file
                    ["d"] = "add_directory", -- Create a new directory
                    ["D"] = "delete",        -- Delete a file or directory
                    ["r"] = "rename",        -- Rename a file or directory
                    ["q"] = "close_window",  -- Close Neotree window
                    ["<CR>"] = "open",       -- Open file or directory
                },
            },
        },
    },
}
