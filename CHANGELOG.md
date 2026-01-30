# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
