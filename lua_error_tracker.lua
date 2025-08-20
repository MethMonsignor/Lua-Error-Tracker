--[[
Lua Error Tracker
Copyright (c) 2025 Meth Monsignor, Emporium Server Owner
Licensed under the MIT License.
Free to use, modify, and distribute with attribution.
]]
-- lua_error_tracker.lua
local ErrorTracker = {}
ErrorTracker.enabled = true
ErrorTracker.logFile = "error_tracker_log.txt"

-- Writes to log
local function logError(msg)
    if not file.Append then
        print("[ErrorTracker] file.Append unavailable. Message:\n" .. msg)
        return
    end
    file.Append(ErrorTracker.logFile, os.date("[%Y-%m-%d %H:%M:%S] ") .. msg .. "\n")
end

-- Safe hook registration
if hook and hook.Add then
    hook.Add("OnLuaError", "ErrorTracker_Capture", function(err, realm, stack, addendum)
        if not ErrorTracker.enabled then return end

        local report = {}
        table.insert(report, "Lua Error Detected:")
        table.insert(report, "Realm: " .. (realm or "unknown"))
        table.insert(report, "Error: " .. err)

        if stack then
            table.insert(report, "Stack Trace:")
            for _, frame in ipairs(stack) do
                local src = frame.short_src or "unknown"
                local line = frame.currentline or "?"
                local name = frame.name or "?"
                table.insert(report, string.format("  %s:%s in function '%s'", src, line, name))
            end
        end

        if addendum then
            table.insert(report, "Addendum: " .. addendum)
        end

        logError(table.concat(report, "\n"))
    end)
else
    print("[ErrorTracker] 'hook' library not available. Skipping error hook.")
end

-- addon residue detection
local function getOrphanedAddonFolders()
    if not engine or not engine.GetAddons then return {} end

    local mounted = {}
    for _, addon in ipairs(engine.GetAddons()) do
        if addon.title then
            mounted[addon.title] = true
        end
    end

    local orphaned = {}
    local folders = file.Find("addons/*", "GAME")
    for _, folder in ipairs(folders) do
        if not mounted[folder] then
            table.insert(orphaned, folder)
        end
    end
    return orphaned
end

local function scanForLuaInOrphans(orphaned)
    local flagged = {}
    for _, folder in ipairs(orphaned) do
        local files, _ = file.Find("addons/" .. folder .. "/lua/**/*.lua", "GAME")
        if files and #files > 0 then
            flagged[folder] = files
        end
    end
    return flagged
end

-- Start orphan scan on startup
if hook and hook.Add then
    hook.Add("Initialize", "ErrorTracker_OrphanScan", function()
        if not ErrorTracker.enabled then return end

        local orphans = getOrphanedAddonFolders()
        local flagged = scanForLuaInOrphans(orphans)

        for folder, files in pairs(flagged) do
            logError("[ErrorTracker] Orphaned addon '" .. folder .. "' contains active Lua files:")
            for _, file in ipairs(files) do
                logError("  - " .. file)
            end
        end
    end)
end

-- Command to toggle tracker
if concommand and concommand.Add then
    concommand.Add("errortracker_toggle", function(ply, cmd, args)
        ErrorTracker.enabled = not ErrorTracker.enabled
        print("[ErrorTracker] Enabled:", ErrorTracker.enabled)
    end)
end


return ErrorTracker
