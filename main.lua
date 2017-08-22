-- Power tools

-- UUID -> player & { tools -> actions }
g_BoundTools = {}

function Initialize(Plugin)
  Plugin:SetName("PowerTools")
  Plugin:SetVersion(1)

  cPluginManager.BindCommand("/pt", "pt", PowerToolsCommand, "Bind a command to a tool")
  cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_ANIMATION, OnPlayerAnimation)

  LOG("Initialized " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
  return true
end

function PowerToolsCommand(Split, Player)
  local toolId = Player:GetEquippedItem().m_ItemType

  if Split[2] == nil then
    Player:SendMessageFailure("Please specify the command to run")
  elseif toolId == -1 then
    Player:SendMessageFailure("No item selected in hotbar")
  elseif Split[2] == "clear" then
    SetBind(Player, toolId, nil)
  else
    local i = 2
    local cmd = {}
    while Split[i] ~= nil do
      cmd[i - 1] = Split[i]
      i = i + 1
    end
    SetBind(Player, toolId, cmd)
  end
  return true
end

function OnPlayerAnimation(Player, Animation)
  local cmd = GetBind(Player, Player:GetEquippedItem().m_ItemType)
  if cmd ~= nil then
    local cmdStr = "/" .. cmd[1]
    local i = 2
    while cmd[i] ~= nil do
      cmdStr = cmdStr .. " " .. cmd[i]
      i = i + 1
    end
    
    local result = cPluginManager.ExecuteCommand(cPluginManager:Get(), Player, cmdStr)
    
    if result ~= 0 then
      ReportError(Player, cmd[1], result)
    end    
  end
  return false
end

function ReportError(Player, CmdName, Result)
  local errMsg = "Unknown error"
  if Result == 0 then
    -- No error
    return
  elseif Result == 1 then
    errMsg = "Unknown command"
  elseif Result == 2 then
    errMsg = "Command handler error"
  elseif Result == 3 then
    errMsg = "Blocked by plugin"
  elseif Result == 4 then
    errMsg = "No permission"
  end
  Player:SendMessageFailure(CmdName .. ": " .. errMsg);
end

function SetBind(Player, ToolId, Cmd)
  if Cmd == nil then
    Player:SendMessageSuccess("Removed bind for " .. ToolId)
  else
    Player:SendMessageSuccess("Bound " .. ToolId .. " to " .. Cmd[1])
  end
  local uuid = Player:GetUUID()

  if g_BoundTools[uuid] == nil then
    g_BoundTools[uuid] = {}
  end

  g_BoundTools[uuid][ToolId] = Cmd
end

function GetBind(Player, ToolId)
  local uuid = Player:GetUUID()
  if g_BoundTools[uuid] == nil then
    return nil
  end
  return g_BoundTools[uuid][ToolId]
end
