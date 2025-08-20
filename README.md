# Lua-Error-Tracker

This module provides runtime Lua error tracking and orphaned addon detection for Garry's Mod servers. It logs detailed error reports and flags addon folders that contain active Lua files but are no longer mounted.

## Features

- Captures Lua errors via `OnLuaError` hook
- Logs error details with stack trace and realm
- Detects orphaned addon folders with Lua files
- Toggleable via `errortracker_toggle` console command

## Installation

1. Place `lua_error_tracker.lua` in your server's `lua/autorun/server/` directory.
2. Ensure the server has write access to `data/error_tracker_log.txt`.
3. Restart the server to activate the tracker.

## Usage

- Errors will be logged automatically to `data/error_tracker_log.txt`.
- Orphaned addon folders with Lua files will be flagged on startup.
- Use `errortracker_toggle` in the server console to enable/disable tracking.

## Compatibility

- Requires Garry's Mod with access to `hook`, `file`, and `engine` libraries.
- Designed for server-side use.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
