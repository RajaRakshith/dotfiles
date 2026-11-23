return {
    {
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        config = function()
            local mc = require("multicursor-nvim")
            mc.setup()

            local set = vim.keymap.set

            set({ "n", "x" }, "<up>", function() mc.lineAddCursor(-1) end, { desc = "Multi: cursor above" })
            set({ "n", "x" }, "<down>", function() mc.lineAddCursor(1) end, { desc = "Multi: cursor below" })
            set({ "n", "x" }, "<leader><up>", function() mc.lineSkipCursor(-1) end, { desc = "Multi: skip line above" })
            set({ "n", "x" }, "<leader><down>", function() mc.lineSkipCursor(1) end, { desc = "Multi: skip line below" })

            set({ "n", "x" }, "<leader>n", function() mc.matchAddCursor(1) end, { desc = "Multi: add match" })
            set({ "n", "x" }, "<leader>s", function() mc.matchSkipCursor(1) end, { desc = "Multi: skip match" })
            set({ "n", "x" }, "<leader>N", function() mc.matchAddCursor(-1) end, { desc = "Multi: add prev match" })
            set({ "n", "x" }, "<leader>S", function() mc.matchSkipCursor(-1) end, { desc = "Multi: skip prev match" })
            set({ "n", "x" }, "<leader>A", mc.matchAllAddCursors, { desc = "Multi: all matches" })

            set("n", "<c-leftmouse>", mc.handleMouse)
            set("n", "<c-leftdrag>", mc.handleMouseDrag)
            set("n", "<c-leftrelease>", mc.handleMouseRelease)

            set({ "n", "x" }, "<c-q>", mc.toggleCursor, { desc = "Multi: toggle cursors" })

            mc.addKeymapLayer(function(layerSet)
                layerSet({ "n", "x" }, "<left>", mc.prevCursor)
                layerSet({ "n", "x" }, "<right>", mc.nextCursor)
                layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor, { desc = "Multi: delete cursor" })

                layerSet("n", "<esc>", function()
                    if not mc.cursorsEnabled() then
                        mc.enableCursors()
                    else
                        mc.clearCursors()
                    end
                end, { desc = "Multi: clear cursors" })
            end)

            set("n", "<leader>gv", mc.restoreCursors, { desc = "Multi: restore cursors" })

            local hl = vim.api.nvim_set_hl
            hl(0, "MultiCursorCursor", { reverse = true })
            hl(0, "MultiCursorVisual", { link = "Visual" })
            hl(0, "MultiCursorSign", { link = "SignColumn" })
            hl(0, "MultiCursorMatchPreview", { link = "Search" })
            hl(0, "MultiCursorDisabledCursor", { reverse = true })
            hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
            hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
        end,
    },
}
