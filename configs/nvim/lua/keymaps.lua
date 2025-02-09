-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

--  Set highlight on search, then Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

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




--  Old Config -> still need to add

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })

--  The best remaps of your life -TheVimagen
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("n", "J", "mzxJ'z", { desc = "appends line bellow to EOL" })
-- keeps cursor in the same place while using ctrl-d & ctrl+u (half page jumps)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- keeps search terms in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
-- when you copy allows to then select and delete without overwriting buffer
vim.keymap.set("x", "<leader>p", '"_dP')
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Neotree keymap
vim.keymap.set("n", "<leader>nt", ":Neotree toggle<CR>", { desc = "[T]oggle Side [B]ar" })
--  Keymap for UndotreeToggle
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toogle UndoTree" })
--  Keymap for VimFugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git Status" })
-- Terminal keymap
-- Vertical split with 80 columns
vim.keymap.set("n", "<leader>ttv", function()
    vim.cmd "vnew +terminal | vertical resize 80"
end, { desc = "Open terminal in vertical split with 80 columns" })
-- Horizontal split with 30 rows
vim.keymap.set("n", "<leader>tth", function()
    vim.cmd "new +terminal | resize 30"
end, { desc = "Open terminal in horizontal split with 30 rows" })
-- Toggle transparency
vim.keymap.set("n", "<leader>ttp", ":TransparentToggle<CR>", { desc = "[T]oggle [T]rans[p]arency" })
