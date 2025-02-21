local mod = RegisterMod('Debug Shenanigans', 1)
local game = Game()

if REPENTOGON then
  function mod:onRender()
    mod:RemoveCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onRender)
    mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
    mod:setupImGui()
  end
  
  function mod:getKeys(tbl, val)
    local keys = {}
    
    for k, v in pairs(tbl) do
      if v == val and
         string.sub(k, 1, 8) ~= 'DISPLAY_' -- exclude RoomDescriptor DISPLAY_ flags
      then
        table.insert(keys, k)
      end
    end
    
    table.sort(keys)
    return keys
  end
  
  function mod:setupImGui()
    if not ImGui.ElementExists('shenanigansMenu') then
      ImGui.CreateMenu('shenanigansMenu', '\u{f6d1} Shenanigans')
    end
    ImGui.AddElement('shenanigansMenu', 'shenanigansMenuItemDebug', ImGuiElement.MenuItem, '\u{f188} Debug Shenanigans')
    ImGui.CreateWindow('shenanigansWindowDebug', 'Debug Shenanigans')
    ImGui.LinkWindowToElement('shenanigansWindowDebug', 'shenanigansMenuItemDebug')
    
    ImGui.AddTabBar('shenanigansWindowDebug', 'shenanigansTabBarDebug')
    ImGui.AddTab('shenanigansTabBarDebug', 'shenanigansTabDebug', 'Debug')
    ImGui.AddTab('shenanigansTabBarDebug', 'shenanigansTabGameState', 'Game State')
    ImGui.AddTab('shenanigansTabBarDebug', 'shenanigansTabLevelState', 'Level State')
    ImGui.AddTab('shenanigansTabBarDebug', 'shenanigansTabRoomState', 'Room State')
    ImGui.AddTab('shenanigansTabBarDebug', 'shenanigansTabWindowState', 'Window State')
    
    local debugs = {
      { id = DebugFlag.ENTITY_POSITIONS     , text = 'Entity Positions' },
      { id = DebugFlag.GRID                 , text = 'Grid' },
      { id = DebugFlag.INFINITE_HP          , text = 'Infinite HP' },
      { id = DebugFlag.HIGH_DAMAGE          , text = 'High Damage (+40)' },
      { id = DebugFlag.ROOM_INFO            , text = 'Show Room Info' },
      { id = DebugFlag.HITSPHERES           , text = 'Show Hitspheres' },
      { id = DebugFlag.DAMAGE_VALUES        , text = 'Show Damage Values' },
      { id = DebugFlag.INFINITE_ITEM_CHARGES, text = 'Infinite Item Charges' },
      { id = DebugFlag.HIGH_LUCK            , text = 'High Luck (+50)' },
      { id = DebugFlag.QUICK_KILL           , text = 'Quick Kill' },
      { id = DebugFlag.GRID_INFO            , text = 'Grid Info' },
      { id = DebugFlag.PLAYER_ITEM_INFO     , text = 'Player Item Info' },
      { id = DebugFlag.GRID_COLLISION_POINTS, text = 'Show Grid Collision Points' },
      { id = DebugFlag.LUA_MEMORY_USAGE     , text = 'Show Lua Memory Usage' },
    }
    
    local gameStates = {}
    for i = 0, GameStateFlag.NUM_STATE_FLAGS - 1 do
      if i == GameStateFlag.STATE_FAMINE_SPAWNED then
        table.insert(gameStates, { id = i, textLast = 'Angel Room Spawned' })
      elseif i == GameStateFlag.STATE_BOSSPOOL_SWITCHED then
        table.insert(gameStates, { id = i, textLast = 'True Co-op Disabled' })
      else
        table.insert(gameStates, { id = i })
      end
    end
    
    local levelStates = {}
    for i = 0, LevelStateFlag.NUM_STATE_FLAGS - 1 do
      table.insert(levelStates, { id = i })
    end
    
    local roomStates = {
      { id = RoomDescriptor.FLAG_CLEAR },
      { id = RoomDescriptor.FLAG_PRESSURE_PLATES_TRIGGERED },
      { id = RoomDescriptor.FLAG_SACRIFICE_DONE },
      { id = RoomDescriptor.FLAG_CHALLENGE_DONE },
      { id = RoomDescriptor.FLAG_SURPRISE_MINIBOSS },
      { id = RoomDescriptor.FLAG_HAS_WATER },
      { id = RoomDescriptor.FLAG_ALT_BOSS_MUSIC },
      { id = RoomDescriptor.FLAG_NO_REWARD },
      { id = RoomDescriptor.FLAG_FLOODED },
      { id = RoomDescriptor.FLAG_PITCH_BLACK },
      { id = RoomDescriptor.FLAG_RED_ROOM },
      { id = RoomDescriptor.FLAG_DEVIL_TREASURE },
      { id = RoomDescriptor.FLAG_USE_ALTERNATE_BACKDROP },
      { id = RoomDescriptor.FLAG_CURSED_MIST },
      { id = RoomDescriptor.FLAG_MAMA_MEGA },
      { id = RoomDescriptor.FLAG_NO_WALLS },
      { id = RoomDescriptor.FLAG_ROTGUT_CLEARED },
      { id = RoomDescriptor.FLAG_PORTAL_LINKED },
      { id = RoomDescriptor.FLAG_BLUE_REDIRECT },
    }
    
    for i, v in ipairs({
                        { tbl = debugs     , keyTbl = DebugFlag     , tab = 'shenanigansTabDebug'     , chkIdPrefix = 'shenanigansChkDebug'     , startAtZero = false },
                        { tbl = gameStates , keyTbl = GameStateFlag , tab = 'shenanigansTabGameState' , chkIdPrefix = 'shenanigansChkGameState' , startAtZero = true },
                        { tbl = levelStates, keyTbl = LevelStateFlag, tab = 'shenanigansTabLevelState', chkIdPrefix = 'shenanigansChkLevelState', startAtZero = true },
                        { tbl = roomStates , keyTbl = RoomDescriptor, tab = 'shenanigansTabRoomState' , chkIdPrefix = 'shenanigansChkRoomState' , startAtZero = true },
                      })
    do
      for j, w in ipairs(v.tbl) do
        local keys = mod:getKeys(v.keyTbl, w.id)
        if #keys > 0 then
          if w.text then
            table.insert(keys, 1, w.text)
          end
          if w.textLast then
            table.insert(keys, w.textLast)
          end
          local id = v.startAtZero and j - 1 or j
          local chkId = v.chkIdPrefix .. id
          ImGui.AddCheckbox(v.tab, chkId, id .. '.' .. table.remove(keys, 1), nil, false)
          if #keys > 0 then
            ImGui.SetHelpmarker(chkId, table.concat(keys, ', '))
          end
          ImGui.AddCallback(chkId, ImGuiCallback.Render, function()
            if i == 1 then
              ImGui.UpdateData(chkId, ImGuiData.Value, game:GetDebugFlags() & w.id == w.id)
            elseif i == 2 then
              ImGui.UpdateData(chkId, ImGuiData.Value, game:GetStateFlag(w.id))
            elseif i == 3 then
              local level = game:GetLevel()
              ImGui.UpdateData(chkId, ImGuiData.Value, level:GetStateFlag(w.id))
            elseif i == 4 then
              local level = game:GetLevel()
              local roomDesc = level:GetCurrentRoomDesc() -- read-only
              ImGui.UpdateData(chkId, ImGuiData.Value, roomDesc.Flags & w.id == w.id)
            end
          end)
          ImGui.AddCallback(chkId, ImGuiCallback.Edited, function(b)
            if Isaac.IsInGame() then
              if i == 1 then
                Isaac.ExecuteCommand('debug ' .. id) -- game:AddDebugFlags
              elseif i == 2 then
                game:SetStateFlag(w.id, b)
              elseif i == 3 then
                local level = game:GetLevel()
                level:SetStateFlag(w.id, b)
              elseif i == 4 then
                local level = game:GetLevel()
                local roomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex(), -1) -- read/write
                if b then
                  roomDesc.Flags = roomDesc.Flags | w.id
                else
                  roomDesc.Flags = roomDesc.Flags & ~w.id
                end
              end
            end
          end)
        end
      end
    end
    
    local txtWindowTitleId = 'shenanigansTxtWindowTitle'
    ImGui.AddInputText('shenanigansTabWindowState', txtWindowTitleId, 'Window Title', nil, '', '')
    ImGui.AddCallback(txtWindowTitleId, ImGuiCallback.Render, function()
      ImGui.UpdateData(txtWindowTitleId, ImGuiData.Value, Isaac.GetWindowTitle())
    end)
    ImGui.AddCallback(txtWindowTitleId, ImGuiCallback.Edited, function(s)
      Isaac.SetWindowTitle(s)
    end)
  end
  
  -- launch options allow you to skip the menu
  mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onRender)
  mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
end