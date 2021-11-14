--[[
	This was my first attempt using real coefficients. The epicycles actually
	look like ellipses.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CatRom = require(ReplicatedStorage.CatRom)
local Integrate = require(ReplicatedStorage.CatRom.Integrate)
local gizmo = require(ReplicatedStorage.gizmo)

-- Settings
local POINTS_CONTAINER = workspace.StudioLogo
local NUM_CYCLES = 100
local FREQUENCY = 1 / 10 -- revolutions per second
local INTEGRATION_STEPS = 1000

local ORIGIN = POINTS_CONTAINER:GetModelCFrame().Position
local TAU = 2 * math.pi
local PROJ_VEC = Vector3.new(1, 0, 1)

-- Create spline
local Points = {}
for i = 1, #POINTS_CONTAINER:GetChildren() do
	Points[i] = POINTS_CONTAINER:FindFirstChild(i).Position - ORIGIN
end
local Spline = CatRom.new(Points)

-- Calculate a_n and b_n
local a = {}
local b = {}

for n = 0, NUM_CYCLES do
	a[n] = 2 * Integrate.Simp38Comp(function(t)
		return Spline:SolvePosition(t) * PROJ_VEC * math.cos(n * TAU * t)
	end, 0, 1, INTEGRATION_STEPS)
	b[n] = 2 * Integrate.Simp38Comp(function(t)
		return Spline:SolvePosition(t) * PROJ_VEC * math.sin(n * TAU * t)
	end, 0, 1, INTEGRATION_STEPS)
end

-- Visuals
local Pencil do
	Pencil = Instance.new("Part")
	Pencil.Size = Vector3.new()
	Pencil.Anchored = true
	Pencil.Transparency = 1
	Pencil.Parent = workspace

	local trailAttachment0 = Instance.new("Attachment")
	trailAttachment0.CFrame = CFrame.new(-0.2, 0, 0)
	trailAttachment0.Parent = Pencil

	local trailAttachment1 = Instance.new("Attachment")
	trailAttachment1.CFrame = CFrame.new(0.2, 0, 0)
	trailAttachment1.Parent = Pencil

	local Trail = Instance.new("Trail")
	Trail.Lifetime = 1 / FREQUENCY
	Trail.FaceCamera = true
	Trail.Transparency = NumberSequence.new(0, 1)
	Trail.Attachment0 = trailAttachment0
	Trail.Attachment1 = trailAttachment1
	Trail.Parent = Pencil
end

-- Run
local startTime = tick()
RunService.Heartbeat:Connect(function()
	local t = (tick() - startTime) % (1 / FREQUENCY) * FREQUENCY
	
	local sum = ORIGIN + a[0] / 2
	gizmo.drawArrow(Vector3.new(), sum)
	
	for n = 1, NUM_CYCLES do
		local summand = 
			  a[n] * math.cos(n * TAU * t)
			+ b[n] * math.sin(n * TAU * t)
		if n < 10 then
			gizmo.drawRay(sum, summand)
		end
		
		sum += summand
	end

	Pencil.CFrame = CFrame.new(sum)
end)