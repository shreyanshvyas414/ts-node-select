<h1 align="center">ts-node-select.</h1>

<p align="center">
  🌳 <b>Modern incremental selection for Neovim using the new Tree-sitter API</b> 🌳
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/shrey99sh/ts-node-select?style=flat-square" />
  <img src="https://img.shields.io/github/issues/shrey99sh/ts-node-select?style=flat-square" />
  <img src="https://img.shields.io/github/license/shrey99sh/ts-node-select?style=flat-square" />
</p>

<p align="center">
    Built with the new <code>vim.treesitter</code> API ·
    Deterministic selection ·
    Hackable & lightweight
</p>

---

`nvim-treesitter` removed the old `incremental_selection` module. This plugin brings it back using the new `vim.treesitter` API — works with every language, stays small, and just works.

---

## Installation

### lazy.nvim

```lua
{
  "shrey99sh/ts-node-select",
  version = "release/v0.1.2",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("ts-node-select").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "shrey99sh/ts-node-select",
  requires = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("ts-node-select").setup()
  end,
}
```

---

## Usage

| Mode   | Key    | Action           |
|:------:|:------:|:----------------:|
| Normal | `<CR>` | Init selection   |
| Visual | `<CR>` | Expand selection |
| Visual | `<BS>` | Shrink selection |

Place your cursor on any syntax element and press `<CR>` to start selecting. Keep pressing to expand, press `<BS>` to shrink back.

---

## Custom Keymaps

```lua
require("ts-node-select").setup({
  keymaps = {
    init   = "<leader>si",
    expand = "<leader>se",
    shrink = "<leader>ss",
  },
})
```

---

## Requirements

- Neovim 0.11+
- `nvim-treesitter`
- Tree-sitter parser for your language (`:TSInstall <language>`)

---

## Troubleshooting

If the plugin isn't working, check that the parser is installed and loaded:

```vim
:TSInstallInfo
:lua print(vim.treesitter.get_parser(0):lang())
```

---

## Contributing

Clone the repo, make your changes, and open a pull request. Bug fixes, features, docs — all welcome!

```bash
git clone https://github.com/shrey99sh/ts-node-select.git
```

---

## License

MIT License © 2026 Shreyansh Vyas
