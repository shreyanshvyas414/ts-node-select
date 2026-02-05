# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [release/v0.1.2] - 2026-02-04

### Fixed
- **CRITICAL**: Fixed Compatiblity with the nightly builds
  - Corrected `nvim_create_autocmd` API usage in `core.lua`.
    (events must be passed as table)
  - Fixed typo: `ger_parser` => `get_parser` in parser detection.
  - Fixed typo: `ft == 0` => `ft == ""` in filetype validation in `keymaps.lua`.
  - Fixed variable name: `buf` => `bufnr` in node selection in `selection.lua`.

### Technical Details
**Why the plugin crashed on Neovim nightly:**
    - The `nvim_create_autocmd` API signature changed to require event as
    a table, Old (incorrect) `nvim_create_autocmd("BufEnter", "FileType", {...})`
    New (correct) `vim_create_autocmd({"BufEnter", "FileType"}, {...})`.

    **Additional bugs fixed:**
    - Typo in `vim.treesitter.get_parser` call prevented parser detection.
    - Incorrect type comparison for filetype (number vs string).
    - Wrong variable name in expand selection logic.

    These fixes ensure compatibility with both stable and nightly Neovim versions.


## [0.1.1] - 2026-01-30

### Fixed
- **BREAKING FIX**: Plugin now works correctly with all languages, not just Lua
  - Fixed treesitter parser detection across multiple filetypes
  - Improved node detection using `named_descendant_for_range` for better accuracy
  - Added proper parser validation before enabling keymaps

### Changed
- Improved treesitter initialization timing with `BufEnter` event in addition to `FileType`
- Enhanced node selection logic to handle edge cases in different languages
- Better error handling for invalid or stale tree-sitter nodes

### Added
- `has_parser()` function in core module for reliable parser detection
- Duplicate keymap prevention to avoid setting keymaps multiple times
- Better buffer validation checks (valid, loaded, has filetype)

### Technical Details
**Why it only worked with Lua before:**
1. The `FileType` autocmd wasn't consistently firing for all languages
2. `vim.treesitter.get_node()` had inconsistent behavior across parsers
3. Parser availability wasn't properly validated before setting up keymaps

**What was fixed:**
1. Added `BufEnter` event alongside `FileType` for more reliable initialization
2. Replaced `vim.treesitter.get_node()` with proper parser-based node detection
3. Added `has_parser()` validation to ensure parser exists before setup
4. Improved node detection using tree root and descendant search

## [0.1.0] - 2026-01-25

### Added
- Initial release
- Tree-sitter based node selection
- Support for init, expand, and shrink selection
- Configurable keymaps
- Buffer and filetype exclusion support
