VERSION = "1.0.0"

local config = import("micro/config")
local util = import("micro/util")

function onBufferOpen(buf)
    local spaces, tabs = 0, 0
    local i = 0
    while spaces + tabs < 500 and i < 1000 and i < buf:LinesNum() do
        local r = util.RuneAt(buf:Line(i), 0)
        if r == " " then
            spaces = spaces + 1
        elseif r == "\t" then
            tabs = tabs + 1
        end
        i = i + 1
    end

    if spaces > tabs then
        buf.Settings["tabstospaces"] = true
    elseif tabs > spaces then
        buf.Settings["tabstospaces"] = false
    end
end

function init()
    config.AddRuntimeFile("detectindent", config.RTHelp, "help/detectindent.md")
end
