hs.loadSpoon("LeftRightHotkey")

local lr = spoon.LeftRightHotkey
lr:start()

local function stroke(mods, key)
  -- Build the exact raw flag mask for desired modifiers only.
  -- This prevents physically-held keys (e.g. rcmd) from leaking into
  -- the synthetic event that the target application receives.
  local rfm = hs.eventtap.event.rawFlagMasks
  local modToRawFlags = {
    cmd   = (rfm.command   or 0) | (rfm.deviceLeftCommand or 0),
    alt   = (rfm.alternate or 0) | (rfm.deviceLeftAlternate or 0),
    shift = (rfm.shift     or 0) | (rfm.deviceLeftShift or 0),
    ctrl  = (rfm.control   or 0) | (rfm.deviceLeftControl or 0),
  }
  local rawFlags = 0
  for _, m in ipairs(mods) do
    rawFlags = rawFlags | (modToRawFlags[m] or 0)
  end

  return function()
    local down = hs.eventtap.event.newKeyEvent(key, true)
    down:rawFlags(rawFlags)
    down:post()
    local up = hs.eventtap.event.newKeyEvent(key, false)
    up:rawFlags(rawFlags)
    up:post()
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

-- 4) rcmd + LEFT control + LEFT option + hjkl => ctrl+alt+arrows (e.g. resize window in JetBrains)
bindArrows({ "rcmd", "lctrl", "lalt" }, { "ctrl", "alt" })

-- Optional: selections
bindArrows({ "rcmd", "lshift" }, { "shift" })
bindArrows({ "rcmd", "lalt", "lshift" }, { "alt", "shift" })
bindArrows({ "rcmd", "lcmd", "lshift" }, { "cmd", "shift" })
bindArrows({ "rcmd", "lctrl", "lalt", "lshift" }, { "ctrl", "alt", "shift" })

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

-- rcmd + lshift + n/m => scroll left/right (with hold/repeat)
local function hscroll(dx)
  return function()
    hs.eventtap.event.newScrollEvent({dx, 0}, {}, "line"):post()
  end
end

lr:bind({ "rcmd", "lshift" }, "n", hscroll(-3), nil, hscroll(-3))
lr:bind({ "rcmd", "lshift" }, "m", hscroll(3), nil, hscroll(3))
