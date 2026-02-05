<h1 align="center">ts-node-select.</h1>

<p align="center">
  🌳 <b>Modern incremental selection for Neovim using the new Tree-sitter API</b> 🌳
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/shreyanshvyas414/ts-node-select?style=flat-square" />
  <img src="https://img.shields.io/github/issues/shreyanshvyas414/ts-node-select?style=flat-square" />
  <img src="https://img.shields.io/github/license/shreyanshvyas414/ts-node-select?style=flat-square" />
</p>

<p align="center">
    Built with the new <code>vim.treesitter</code> API ·
    Deterministic selection ·
    Hackable & lightweight
</p>

---

## Why ts-node-select?

`nvim-treesitter` deprecated and removed the old `incremental_selection` module.
This plugin exists to:

- Restore incremental syntax selection
- Use the new official Tree-sitter API
- Work with **all programming languages** (Lua, Rust, Python, JavaScript, Go, C/C++, and more!)
- Include comments, punctuation, and unnamed nodes
- Avoid frozen or deprecated APIs
- Stay small, predictable, and hackable

If you previously used `init_selection`, `node_incremental`, and
`node_decremental`, this is the modern replacement.

---

## ✨ Features

- **Incremental selection** using real Tree-sitter nodes
-  **Universal language support** - works with any language that has a Tree-sitter parser
-  **Optimized performance** - hybrid approach for fast node detection
-  **Lightweight** - minimal dependencies, clean code
-  Selects the smallest syntax unit under the cursor
-  Expands selection to parent nodes incrementally
-  Shrinks selection step-by-step
-  Skips parents with identical ranges (prevents stuck expansion)
-  Buffer-local keymaps
-  Activates only when a Tree-sitter parser is available

---

## 📦 Installation

### lazy.nvim

```lua
{
 "shreyanshvyas414/ts-node-select",
  version = "release/v0.1.2", -- Recommended use for latest(neovim nightly builds) v(0.1.2).
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("ts-node-select").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "shreyanshvyas414/ts-node-select",
  requires = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("ts-node-select").setup()
  end,
}
```

Make sure `nvim-treesitter` is installed and Tree-sitter parsers are available for your languages.

---

## ⚙️ Setup

### Minimal setup

```lua
require("ts-node-select").setup()
```

### Custom keymaps

```lua
require("ts-node-select").setup({
  keymaps = {
    init   = "<CR>",   -- Initialize selection (normal mode)
    expand = "<CR>",   -- Expand selection (visual mode)
    shrink = "<BS>",   -- Shrink selection (visual mode)
  },
})
```

### Exclude specific filetypes or buftypes

```lua
require("ts-node-select").setup({
  exclude = {
    filetypes = { "alpha", "dashboard" },  -- Additional filetypes to exclude
    buftypes = { "terminal" },              -- Additional buftypes to exclude
  },
})
```

All keymaps are buffer-local and enabled only when a Tree-sitter parser is available.

---

## ⌨️ Default Keymaps

|  Mode  |   Key   |      Action       |
|:------:|:-------:|:-----------------:|
| Normal | `<CR>`  | Init selection    |
| Visual | `<CR>`  | Expand selection  |
| Visual | `<BS>`  | Shrink selection  |

---

## 🎬 Usage Examples

### Basic Usage

```lua
-- In any file with Tree-sitter support
-- Place cursor on a variable, function, or any syntax element

-- Press <CR> in normal mode → Selects node under cursor
-- Press <CR> again in visual mode → Expands to parent
-- Press <CR> again → Expands to next parent
-- Press <BS> → Shrinks back one level
```

### Example: Rust

```rust
fn calculate(x: i32, y: i32) -> i32 {
    let result = x + y;
    println!("Result: {}", result);
    return result;
}
```

**Cursor on `result` inside `let result = x + y;`:**
1. Press `<CR>` → Selects `result`
2. Press `<CR>` → Expands to `result = x + y`
3. Press `<CR>` → Expands to `let result = x + y;`
4. Press `<CR>` → Expands to function body
5. Press `<CR>` → Expands to entire function
6. Press `<BS>` → Shrinks back step by step

### Example: Python

```python
def greet(name):
    message = f"Hello, {name}!"
    print(message)
    return message
```

**Cursor on `message`:**
1. Press `<CR>` → Selects `message`
2. Press `<CR>` → Expands to `message = f"Hello, {name}!"`
3. Press `<CR>` → Expands to full assignment
4. Press `<CR>` → Expands to function body
5. Press `<CR>` → Expands to entire function

### Example: JavaScript

```javascript
function processData(items) {
    const filtered = items.filter(item => item.active);
    return filtered.map(item => item.value);
}
```

**Works perfectly with modern JS syntax, arrow functions, and more!**

---

## 🔧 How it works

1. **Finds the smallest Tree-sitter node** under the cursor using optimized detection
2. **Stores selection history** per buffer for predictable shrinking
3. **Expands selection** to parent nodes incrementally
4. **Skips parents** with identical ranges to prevent stuck expansion
5. **Shrinks selection** using stored history for precise control

### Technical Details

- Uses the **new Tree-sitter API**:
  - `vim.treesitter.get_node()` for fast path (O(depth))
  - `named_descendant_for_range()` for fallback (O(tree walk))
  - `vim.treesitter.get_parser()` for reliable parser access
- **Hybrid node detection** for optimal performance (50x faster in typical cases)
- **Event-based initialization** (`BufEnter` + `FileType`) for reliability across all languages
- This makes selection **accurate, fast, and future-proof**

---

## 📊 Comparison

### vs. old `incremental_selection`

|        Old Treesitter        |        ts-node-select        |
|:----------------------------:|:----------------------------:|
| Deprecated API               |  Uses New API                   |
| Named nodes only             |  Includes comments & punctuation |
| Sometimes stuck              |  Deterministic expansion   |
| Frozen                       |  Actively maintained       |
| Lua-focused                  |  All languages supported   |

### vs. other selection plugins

- **More reliable**: Better Tree-sitter parser detection and initialization
- **Faster**: Optimized hybrid node detection approach
- **Simpler**: Minimal configuration, just works
- **Modern**: Built on latest Neovim Tree-sitter APIs

---

## 🔌 API

### Programmatic Usage

```lua
local ts = require("ts-node-select")

-- Initialize selection at cursor
ts.init()

-- Expand current selection
ts.expand()

-- Shrink current selection
ts.shrink()
```

### Manual Setup

```lua
-- Setup core functionality
require("ts-node-select").setup()

-- Or use individual components
local core = require("ts-node-select.core")
local selection = require("ts-node-select.selection")
local keymaps = require("ts-node-select.keymaps")

core.setup()
keymaps.setup({
  init = "<leader>si",
  expand = "<leader>se",
  shrink = "<leader>ss",
})
```

---

## 📋 Requirements

- **Neovim 0.11+** (uses latest Tree-sitter API)
- **nvim-treesitter** (for parser management)
- **Tree-sitter parsers** installed for your languages

Install parsers with:
```vim
:TSInstall <language>

" Examples:
:TSInstall lua
:TSInstall rust
:TSInstall python
:TSInstall javascript
```

---

## 🐛 Troubleshooting

### Plugin doesn't work in my language

1. Check if Tree-sitter parser is installed:
   ```vim
   :TSInstallInfo
   ```

2. Verify parser is loaded:
   ```vim
   :lua print(vim.treesitter.get_parser(0):lang())
   ```

3. Check keymaps are set:
   ```vim
   :nmap <CR>
   :xmap <CR>
   ```

### Selection feels slow

Make sure you're on v0.1.1 which includes performance optimizations.

### Keymaps conflict with other plugins

Customize the keymaps:
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

## 📝 Version History

### release/v0.1.2 - Neovim Nightly Compatibility & Bug Fixes (2025-02-04)

## What's Fixed:

-  This release resolves critical compatibility issues with Neovim 
    nightly builds and fixes several runtime bugs.

**Critical Fixes:**
- Fixed `E5113` error on Neovim nightly (incorrect `nvim_create_autocmd` API usage).
- Fixed parser detection typo preventing treesitter validation
- Fixed filetype comparison type error
- Fixed undefined variable in expand selection logic

**Compatibility:**
- Works on Neovim stable (0.11+).
- Works on Neovim nightly
- All language support and maintained.

### Upgrade Instructions
Update your `lazy.nvim` config to use `version = "release/v0.1.2"`

See [CHANGELOG.md](CHANGELOG.md) for complete details.

### v0.1.1 - Multi-Language Support & Performance (2026-01-30)

**Major improvements:**
-  Fixed plugin to work with **all programming languages** (was Lua-only)
-  Improved Tree-sitter initialization for reliable cross-language support
-  Optimized node detection with hybrid approach (50x faster)
-  Better event handling (`BufEnter` + `FileType`)
-  Enhanced parser validation

**Technical changes:**
- Rewrote node detection for compatibility across all parsers
- Added `has_parser()` validation function
- Improved buffer validation and initialization timing
- Added fast path for node detection with fallback

See [CHANGELOG.md](CHANGELOG.md) for complete details.

### v0.1.0 - Initial Release

- Core incremental selection functionality
- Buffer-local keymaps
- Basic Tree-sitter integration

---

## Contributing

Issues and pull requests are welcome! Areas of interest:

- **Language edge cases** - Report issues with specific languages
- **Performance** - Suggestions for optimization
- **Documentation** - Examples, tutorials, screencasts
- **Testing** - Help test with different languages and edge cases

### Development

```bash
# Clone the repo
git clone https://github.com/shreyanshvyas414/ts-node-select.git

# Test locally
nvim --cmd "set rtp+=." test.lua
```

---
## ❤️ Motivation

This is my first open-source Neovim plugin, built to learn, share, and give back to the community.
If this helps you — that’s already a win ✨

---

## License
MIT License © 2026 Shreyansh Vyas
