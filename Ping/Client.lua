local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PingServer = ReplicatedStorage:WaitForChild("PingServer")
local PingClient = ReplicatedStorage:WaitForChild("PingClient")

PingServer.OnClientEvent:Connect(function()
	PingClient:FireServer()
end)
