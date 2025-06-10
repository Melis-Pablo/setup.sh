-- Cross-Platform Neovim Keymaps Configuration

-- Platform detection
local is_macos = vim.g.platform == 'macos'
local is_linux = vim.g.platform == 'linux'

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

--  Set highlight on search, then Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

--  The best remaps from ThePrimeagen
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Append line below to EOL" })

-- Keeps cursor in the same place while using ctrl-d & ctrl+u (half page jumps)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keeps search terms in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- When you copy allows to then select and delete without overwriting buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Neo-tree keymap
vim.keymap.set("n", "<leader>nt", ":Neotree toggle<CR>", { desc = "[N]eo[T]ree toggle" })

-- UndotreeToggle keymap
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle UndoTree" })

-- Vim Fugitive keymap
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git Status" })

-- Terminal keymaps with better cross-platform handling
-- Vertical split with 80 columns
vim.keymap.set("n", "<leader>ttv", function()
    vim.cmd "vnew +terminal | vertical resize 80"
end, { desc = "Open terminal in vertical split with 80 columns" })

-- Horizontal split with 30 rows
vim.keymap.set("n", "<leader>tth", function()
    vim.cmd "new +terminal | resize 30"
end, { desc = "Open terminal in horizontal split with 30 rows" })

-- Toggle transparency
vim.keymap.set("n", "<leader>ttp", ":TransparentToggle<CR>", { desc = "Toggle Transparency" })

-- Platform-specific keymaps
if is_macos then
    -- macOS-specific keymaps
    vim.keymap.set("n", "<D-s>", ":w<CR>", { desc = "Save file (Cmd+S)" })
    vim.keymap.set("i", "<D-s>", "<C-o>:w<CR>", { desc = "Save file (Cmd+S)" })
    vim.keymap.set("n", "<D-w>", ":q<CR>", { desc = "Close window (Cmd+W)" })
    vim.keymap.set("n", "<D-q>", ":qa<CR>", { desc = "Quit all (Cmd+Q)" })
    
    -- macOS copy/paste (if not using system clipboard)
    vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to system clipboard" })
    vim.keymap.set("n", "<D-v>", '"+p', { desc = "Paste from system clipboard" })
    vim.keymap.set("i", "<D-v>", '<C-r>+', { desc = "Paste from system clipboard" })
    
elseif is_linux then
    -- Linux-specific keymaps
    vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file (Ctrl+S)" })
    vim.keymap.set("i", "<C-s>", "<C-o>:w<CR>", { desc = "Save file (Ctrl+S)" })
    
    -- Linux copy/paste shortcuts
    vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })
    vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste from system clipboard" })
    vim.keymap.set("i", "<C-v>", '<C-r>+', { desc = "Paste from system clipboard" })
end

-- Buffer management
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>ba", ":bufdo bd<CR>", { desc = "Delete all buffers" })

-- Tab management
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { desc = "Close other tabs" })
vim.keymap.set("n", "<leader>tm", ":tabmove<Space>", { desc = "Move tab" })

-- Window management
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>wh", ":split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>wc", ":close<CR>", { desc = "Close window" })
vim.keymap.set("n", "<leader>wo", ":only<CR>", { desc = "Close other windows" })

-- Resize windows
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Quick save and quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>W", ":wa<CR>", { desc = "Save all files" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", ":qa!<CR>", { desc = "Quit all without saving" })

-- Search and replace
vim.keymap.set("n", "<leader>sr", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Search and replace word under cursor" })
vim.keymap.set("v", "<leader>sr", '"hy:%s/<C-r>h//gc<left><left><left>', { desc = "Search and replace selection" })

-- File operations
vim.keymap.set("n", "<leader>fn", ":enew<CR>", { desc = "New file" })
vim.keymap.set("n", "<leader>fs", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>fS", ":wa<CR>", { desc = "Save all files" })
vim.keymap.set("n", "<leader>fr", ":e!<CR>", { desc = "Reload file" })

-- Line operations
vim.keymap.set("n", "<leader>ld", "dd", { desc = "Delete line" })
vim.keymap.set("n", "<leader>ly", "yy", { desc = "Yank line" })
vim.keymap.set("n", "<leader>lp", "p", { desc = "Paste below" })
vim.keymap.set("n", "<leader>lP", "P", { desc = "Paste above" })

-- Text editing helpers
vim.keymap.set("n", "<leader>Y", "y$", { desc = "Yank to end of line" })
vim.keymap.set("n", "<leader>D", "d$", { desc = "Delete to end of line" })
vim.keymap.set("n", "<leader>C", "c$", { desc = "Change to end of line" })

-- Indentation
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
vim.keymap.set("n", "<leader>i=", "gg=G``", { desc = "Fix indentation for entire file" })

-- Clear trailing whitespace
vim.keymap.set("n", "<leader>cw", ":%s/\\s\\+$//e<CR>", { desc = "Clear trailing whitespace" })

-- Toggle settings
vim.keymap.set("n", "<leader>tw", ":set wrap!<CR>", { desc = "Toggle word wrap" })
vim.keymap.set("n", "<leader>tn", ":set number!<CR>", { desc = "Toggle line numbers" })
vim.keymap.set("n", "<leader>tr", ":set relativenumber!<CR>", { desc = "Toggle relative numbers" })
vim.keymap.set("n", "<leader>tl", ":set list!<CR>", { desc = "Toggle list chars" })
vim.keymap.set("n", "<leader>ts", ":set spell!<CR>", { desc = "Toggle spell check" })

-- Quickfix and location list
vim.keymap.set("n", "<leader>co", ":copen<CR>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>cc", ":cclose<CR>", { desc = "Close quickfix" })
vim.keymap.set("n", "<leader>cn", ":cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader>cp", ":cprev<CR>", { desc = "Previous quickfix item" })
vim.keymap.set("n", "<leader>lo", ":lopen<CR>", { desc = "Open location list" })
vim.keymap.set("n", "<leader>lc", ":lclose<CR>", { desc = "Close location list" })
vim.keymap.set("n", "<leader>ln", ":lnext<CR>", { desc = "Next location item" })
vim.keymap.set("n", "<leader>lp", ":lprev<CR>", { desc = "Previous location item" })

-- Plugin management (Lazy.nvim)
vim.keymap.set("n", "<leader>pl", ":Lazy<CR>", { desc = "Open Lazy plugin manager" })
vim.keymap.set("n", "<leader>pu", ":Lazy update<CR>", { desc = "Update plugins" })
vim.keymap.set("n", "<leader>ps", ":Lazy sync<CR>", { desc = "Sync plugins" })
vim.keymap.set("n", "<leader>pc", ":Lazy clean<CR>", { desc = "Clean plugins" })

-- Help and documentation
vim.keymap.set("n", "<leader>h", ":help<Space>", { desc = "Open help" })
vim.keymap.set("n", "<leader>hk", ":help keymaps<CR>", { desc = "Help for keymaps" })
vim.keymap.set("n", "<leader>ho", ":help options<CR>", { desc = "Help for options" })

-- Source current file (useful for config development)
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("source %")
    vim.notify("File sourced!")
end, { desc = "Source current file" })

-- Clipboard management with better cross-platform support
local function smart_paste()
    if vim.fn.mode() == 'i' then
        return '<C-r>+'
    else
        return '"+p'
    end
end

vim.keymap.set({"n", "v"}, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
vim.keymap.set({"n", "v"}, "<leader>d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })

-- System clipboard shortcuts
if is_macos then
    vim.keymap.set({"n", "v", "i"}, "<D-a>", function()
        if vim.fn.mode() == 'i' then
            return '<C-o>ggVG'
        else
            return 'ggVG'
        end
    end, { expr = true, desc = "Select all" })
elseif is_linux then
    vim.keymap.set({"n", "v"}, "<C-a>", "ggVG", { desc = "Select all" })
end

-- Enhanced navigation
vim.keymap.set("n", "<C-o>", "<C-o>zz", { desc = "Go back and center" })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { desc = "Go forward and center" })

-- Better command-line editing
vim.keymap.set("c", "<C-a>", "<Home>", { desc = "Go to beginning of line" })
vim.keymap.set("c", "<C-e>", "<End>", { desc = "Go to end of line" })
vim.keymap.set("c", "<C-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("c", "<C-l>", "<Right>", { desc = "Move right" })
vim.keymap.set("c", "<C-k>", "<C-f>", { desc = "Open command-line window" })

-- Insert mode enhancements
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" })
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" })
vim.keymap.set("i", "<C-a>", "<Home>", { desc = "Go to beginning of line" })
vim.keymap.set("i", "<C-e>", "<End>", { desc = "Go to end of line" })

-- Function to toggle between relative and absolute line numbers
local function toggle_line_numbers()
    if vim.opt.relativenumber:get() then
        vim.opt.relativenumber = false
        vim.opt.number = true
        vim.notify("Absolute line numbers")
    else
        vim.opt.relativenumber = true
        vim.opt.number = true
        vim.notify("Relative line numbers")
    end
end

vim.keymap.set("n", "<leader>tR", toggle_line_numbers, { desc = "Toggle relative/absolute line numbers" })

-- Zoom toggle for current window
local function toggle_zoom()
    if vim.t.zoomed and vim.t.zoomed == 1 then
        vim.cmd("tabclose")
        vim.t.zoomed = 0
    else
        vim.cmd("tabnew %")
        vim.t.zoomed = 1
    end
end

vim.keymap.set("n", "<leader>z", toggle_zoom, { desc = "Toggle zoom current window" })