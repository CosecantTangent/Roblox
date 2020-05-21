local module = {}
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PingServer = ReplicatedStorage.PingServer -- Server --> Client
local PingClient = ReplicatedStorage.PingClient -- Client --> Server
local ThresholdPing = 1
local YieldTime = 1

local PingTable = setmetatable({}, {__mode = "k"})

function module.AddPlayer(Player)
	PingTable[Player] = {WaitingForResponse = false, LastPingTimeStamp = 0, Ping = 0, Requests = 0}
end

function module.RemovePlayer(Player)
	PingTable[Player] = nil
end

function module.ReturnPing(Player)
	return PingTable[Player].Ping
end

PingClient.OnServerEvent:Connect(function(Player)
	local ServerTime = tick()
	local PlayerPingTable = PingTable[Player]
	
	if PlayerPingTable.WaitingForResponse then
		PlayerPingTable.WaitingForResponse = false
		PlayerPingTable.Ping = math.clamp((ServerTime - PlayerPingTable.LastPingTimeStamp)/2, 0, ThresholdPing)
		PlayerPingTable.Requests = 0
	end
end)

coroutine.wrap(function()
	while true do
		for Player, PlayerPingTable in pairs(PingTable) do
			PlayerPingTable.LastPingTimeStamp = tick()
			PingServer:FireClient(Player)
			PlayerPingTable.WaitingForResponse = true
			if PlayerPingTable.Requests == 3 then
				PlayerPingTable.Ping = ThresholdPing
				PlayerPingTable.Requests = PlayerPingTable.Requests + 1
			else
				PlayerPingTable.Requests = PlayerPingTable.Requests + 1
			end
		end
		wait(YieldTime)
	end
end)()

return module
