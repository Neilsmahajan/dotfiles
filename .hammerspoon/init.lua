hs.loadSpoon("LeftRightHotkey")

local lr = spoon.LeftRightHotkey
lr:start()

local function stroke(mods, key)
  return function()
    hs.eventtap.keyStroke(mods, key, 0)
  end
end

local function bindArrows(matchMods, outMods)
  lr:bind(matchMods, "h", stroke(outMods, "left"), nil, stroke(outMods, "left"))
  lr:bind(matchMods, "j", stroke(outMods, "down"), nil, stroke(outMods, "down"))
  lr:bind(matchMods, "k", stroke(outMods, "up"), nil, stroke(outMods, "up"))
  lr:bind(matchMods, "l", stroke(outMods, "right"), nil, stroke(outMods, "right"))
end

-- 1) rcmd + hjkl => arrows
bindArrows({ "rcmd" }, {})

-- 2) rcmd + LEFT option + hjkl => option+arrows (jump by word, etc.)
-- Matches physical LEFT option (lalt), emits logical option (alt)
bindArrows({ "rcmd", "lalt" }, { "alt" })

-- 3) rcmd + LEFT command + hjkl => cmd+arrows (start/end of line in many apps)
-- Matches physical LEFT command (lcmd), emits logical command (cmd)
bindArrows({ "rcmd", "lcmd" }, { "cmd" })

-- 4) rcmd + LEFT option + LEFT command + hjkl => opt+cmd+arrows (e.g. shift tab in browser)
bindArrows({ "rcmd", "lalt", "lcmd" }, { "alt", "cmd" })

-- Optional: selections
bindArrows({ "rcmd", "lshift" }, { "shift" })
bindArrows({ "rcmd", "lalt", "lshift" }, { "alt", "shift" })
bindArrows({ "rcmd", "lcmd", "lshift" }, { "cmd", "shift" })
bindArrows({ "rcmd", "lalt", "lcmd", "lshift" }, { "alt", "cmd", "shift" })

-- Optional: if you want right-option/right-command to also work, add:
-- bindArrows({ "rcmd", "ralt" }, { "alt" })
-- bindArrows({ "rcmd", "rcmd" }, { "cmd" }) -- don't do this; it's nonsensical
-- bindArrows({ "rcmd", "rcmd" }, ...)       -- (leaving here as a warning)
-- Instead, for right command + right command isn't a thing; use lcmd/rcmd combos.

-- rcmd + u/o => page up/down (with hold/repeat)
lr:bind({ "rcmd" }, "u", stroke({}, "pageup"), nil, stroke({}, "pageup"))
lr:bind({ "rcmd" }, "o", stroke({}, "pagedown"), nil, stroke({}, "pagedown"))

-- rcmd + n/m => scroll down/up (with hold/repeat)
local function scroll(dy)
  return function()
    hs.eventtap.event.newScrollEvent({0, dy}, {}, "line"):post()
  end
end

lr:bind({ "rcmd" }, "n", scroll(-3), nil, scroll(-3))
lr:bind({ "rcmd" }, "m", scroll(3), nil, scroll(3))
