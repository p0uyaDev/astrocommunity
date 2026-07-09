return {
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      opts.mappings = opts.mappings or {}
      opts.mappings.n = opts.mappings.n or {}

      -- Sync tabline buffers to Harpoon mark order
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
