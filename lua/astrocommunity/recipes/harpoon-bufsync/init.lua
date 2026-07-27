return {
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      opts.mappings = opts.mappings or {}
      opts.mappings.n = opts.mappings.n or {}

      -- ── <Leader><Leader>b: Reset Harpoon from open buffers ──────
      opts.mappings.n["<Leader><Leader>b"] = {
        function()
          local harpoon = require "harpoon"
          local list = harpoon:list()
          local buffer = require "astrocore.buffer"

          -- Remember where we are
          local current_buf = vim.api.nvim_get_current_buf()

          -- Nuke existing Harpoon marks
          list.items = {}

          -- Re-add each open buffer, preserving tabline order
          for _, bufnr in ipairs(vim.t.bufs or {}) do
            if buffer.is_valid(bufnr) then
              local path = vim.api.nvim_buf_get_name(bufnr)
              if path ~= "" and vim.fn.filereadable(path) == 1 then
                -- Switch to this buffer so Harpoon's add() picks it up
                pcall(vim.api.nvim_set_current_buf, bufnr)
                list:add()
              end
            end
          end

          -- Restore the buffer we started on
          pcall(vim.api.nvim_set_current_buf, current_buf)

          -- Quick feedback
          vim.notify("Harpoon marks reset: " .. #list.items .. " files from tabline", vim.log.levels.INFO)
        end,
        desc = "Reset Harpoon from buffers",
      }

      -- ── <Leader>bsh: Sync tabline to Harpoon order ─────────────
      opts.mappings.n["<Leader>bsh"] = {
        function()
          local harpoon = require "harpoon"
          local harpoon_items = harpoon:list().items

          -- Build path -> harpoon index map
          local harpoon_order = {}
          for i, item in ipairs(harpoon_items) do
            local path = vim.fn.fnamemodify(item.value, ":p")
            harpoon_order[path] = i
          end

          -- Get current tab's buffer list (this IS the tabline order)
          local bufs = vim.t.bufs or {}

          -- Close buffers NOT in Harpoon list
          for _, bufnr in ipairs(bufs) do
            if require("astrocore.buffer").is_valid(bufnr) then
              local buf_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")
              if not harpoon_order[buf_path] then require("astrocore.buffer").close(bufnr) end
            end
          end

          -- Open Harpoon files that aren't open yet
          local open_paths = {}
          for _, bufnr in ipairs(vim.t.bufs or {}) do
            open_paths[vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")] = true
          end

          for _, item in ipairs(harpoon_items) do
            local path = vim.fn.fnamemodify(item.value, ":p")
            if not open_paths[path] and vim.fn.filereadable(path) == 1 then
              vim.cmd("edit " .. vim.fn.fnameescape(path))
            end
          end

          -- Re-sort vim.t.bufs by Harpoon order
          local new_order = {}
          for _, bufnr in ipairs(vim.t.bufs or {}) do
            local buf_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")
            if harpoon_order[buf_path] then
              table.insert(new_order, { idx = harpoon_order[buf_path], bufnr = bufnr })
            end
          end
          table.sort(new_order, function(a, b) return a.idx < b.idx end)

          -- Write back the sorted order
          vim.t.bufs = vim.tbl_map(function(item) return item.bufnr end, new_order)

          -- Refresh the tabline
          vim.cmd "redrawtabline"
        end,
        desc = "Sort by Harpoon",
      }
    end,
  },
}
