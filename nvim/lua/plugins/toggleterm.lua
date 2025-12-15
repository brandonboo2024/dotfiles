return {
    'akinsho/toggleterm.nvim', version = "*",
    config = function()
        require("toggleterm").setup({
            -- size can be a number or function which is passed the current terminal
            size = 12,          
            open_mapping = [[<c-y>]], -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
            hide_numbers = true, -- hide the number column in toggleterm buffers
            shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
            shading_factor = 2, -- the percentage by which to lighten dark terminal background, default: -30
            start_in_insert = true,
            insert_mappings = true, -- whether or not the open mapping applies in insert mode
            persist_size = true,
            direction = 'horizontal',
            close_on_exit = true, -- close the terminal window when the process exits
            -- Change the default shell. Can be a string or a function returning a string
            shell = vim.o.shell,
            float_opts = {
                -- The border key is *almost* the same as 'nvim_open_win'
                -- see :h nvim_open_win for details on borders however
                -- the 'curved' border is a custom border type
                -- not natively supported but implemented in this plugin.
                border = 'single',
                -- like `size`, width, height, row, and col can be a number or function which is passed the current terminal
            },
        })
    end,
}
