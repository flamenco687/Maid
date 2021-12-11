## [1.5.1] - 2021-12-11

### Changed
- Maid type is now exported instead of only local

### Fixed
- Some type annotations were not written correctly
- `IsInstanceDestroyed()` returned value type was wrong

## [1.5.0] - 2021-11-25

### Added
- Added new method: `:Is()` to get the class name (_Maid_) and the metatable as second argument

### Changed
- Renamed ManualConnection (Found inside `LinkToInstance`) to NewManualConnection to avoid class shadowing
- Moved player service up to the top to match the style guide and to take it out of the class scope

### Improved
- Added type annotations
- Added custom types for each class
- Formatted code with StyLua base configurations