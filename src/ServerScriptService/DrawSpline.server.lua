local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CatRom = require(ReplicatedStorage.CatRom)
local gizmo = require(ReplicatedStorage.gizmo)

local N = 400

RunService.Heartbeat:Connect(function()
	local points = {}
	for i, child in ipairs(workspace.StudioLogo:GetChildren()) do
		points[i] = child.Position
	end
	local spline = CatRom.new(points)
	
	for i = 0, N - 1 do
		gizmo.drawPoint(spline:SolvePosition(i / (N - 1)))
	end
end)