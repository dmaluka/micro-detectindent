VERSION = "1.0.0"

local config = import("micro/config")
local util = import("micro/util")

function onBufferOpen(buf)
    local spaces, tabs = 0, 0
    local space_count, prev_space_count = -1, -1
    local tabsizes = {}
    local i = 0
    while spaces + tabs < 500 and i < 1000 and i < buf:LinesNum() do
        space_count = -1
        local line = buf:Line(i)
        local r = util.RuneAt(line, 0)
        if r == " " then
            spaces = spaces + 1
            space_count = string.len(util.GetLeadingWhitespace(line))
            -- count blank/empty lines as having the same indentation as the last one
            if string.len(line) == space_count then
                space_count = prev_space_count
            end
        elseif r == "\t" then
            tabs = tabs + 1
        end
        -- count the change in indentation between non-empty indented lines
        if prev_space_count >= 0 and space_count > prev_space_count then
            local t = space_count - prev_space_count
            if tabsizes[t] == nil then
                tabsizes[t] = 1
            else
                tabsizes[t] = tabsizes[t] + 1
            end
        end
        prev_space_count = space_count
        i = i + 1
    end

    if spaces > tabs then
        buf.Settings["tabstospaces"] = true
        -- get the indentation change used for the largest number of lines
        tabsize = -1
        maxcount = 0
        for t, count in pairs(tabsizes) do
            if count > maxcount then
                maxcount = count
                tabsize = t
            end
        end
        if tabsize > 0 then
            buf.Settings["tabsize"] = tabsize
        end
    elseif tabs > spaces then
        buf.Settings["tabstospaces"] = false
    end
end

function init()
    config.AddRuntimeFile("detectindent", config.RTHelp, "help/detectindent.md")
end
