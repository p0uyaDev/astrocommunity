# Harpoon BufSync

Sync your AstroNvim buffer tabline to your Harpoon marks — close, open, and sort buffers based on your pinned files.

## Overview

Harpoon lets you pin frequently-used files for quick navigation. But your tabline (Heirline) doesn't reflect that order — it tracks buffers by open-time and internal buffer ID. This recipe bridges that gap: with a single keybind (`<Leader>bsh`), it closes non-Harpoon buffers, opens missing Harpoon files, and sorts the tabline to match your Harpoon order.

## Requirements

- [Harpoon v2](https://github.com/ThePrimeagen/harpoon) (branch `harpoon2`)
- [AstroCore](https://github.com/AstroNvim/astrocore) (bundled with AstroNvim)
- [Heirline](https://github.com/rebelot/heirline.nvim) (AstroNvim default tabline)

## Installation

Add to your `community.lua`:

```lua
{ import = "astrocommunity.recipes.harpoon-bufsync" },
```
