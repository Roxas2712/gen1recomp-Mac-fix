-- Native AI item history is a battle-long byte cache, not an inventory peek.
local K = {}
local State = require("src.core.game3.battle.state")
local function emerald()
  return require("src.core.GameVersion").get() == "emerald"
end
function K.item(b)
  local mon = b and b.mon
  local value = b and (b.item or mon and (mon.item or mon.heldItem))
  return tonumber(value) or value and require("src.core.game3.items_data").toNumericId(value) or 0
end
function K.raw(st, item)
  item = tonumber(item) or 0
  if item == 0 then
    return 0
  end
  local info = require("src.core.game3.items_data").info(item)
  if info and tonumber(info.holdEffect) then
    return tonumber(info.holdEffect)
  end
  -- The AI's raw item-table read does not resolve a saved Enigma berry.
  if item == 175 then
    return 0
  end
  local effect = require("src.core.game3.battle.held_items").effectOf(item, st and st.session)
  return tonumber(effect) or 0
end
function K.record(st, b, effect)
  local id = State.idOf(b)
  if not st or id == nil then
    return
  end
  if not emerald() then
    if id % 2 ~= 0 then
      return
    end
    id = 0 -- FireRed's native side-wide player history.
  end
  st._aiHistory = st._aiHistory or {}
  local h = st._aiHistory
  h.itemEffects = h.itemEffects or {}
  h.itemEffects[id] = effect
end
function K.observed(st, b)
  local h = st and st._aiHistory
  local id = State.idOf(b)
  return tonumber(h and h.itemEffects and id ~= nil and h.itemEffects[id]) or 0
end
function K.get(vm, which)
  local b = (which == 1 or which == "AI_USER") and vm.user or vm.target
  if not b then
    return 0
  end
  if emerald() then
    -- The native command passes a cached EFFECT byte to the ITEM reader.
    local item = State.idOf(b) == State.idOf(vm.user) and K.item(b) or K.observed(vm.st, b)
    return K.raw(vm.st, item)
  end
  local id = State.idOf(b)
  if id and id % 2 == 0 then
    local h = vm.st and vm.st._aiHistory
    return tonumber(h and h.itemEffects and h.itemEffects[0]) or 0
  end
  return K.raw(vm.st, K.item(b))
end
return K
