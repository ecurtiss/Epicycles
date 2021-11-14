--[[
	This was my second attempt using complex coefficients.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CatRom = require(ReplicatedStorage.CatRom)
local DrawBeamCircle = require(ReplicatedStorage.DrawBeamCircle)
local Integrate = require(ReplicatedStorage.CatRom.Integrate)
local gizmo = require(ReplicatedStorage.gizmo)

-- Settings
local POINTS_CONTAINER = workspace.RobloxLogo
local NUM_CYCLES = 80
local FREQUENCY = 1 / 8 -- revolutions per second
local INTEGRATION_STEPS = 1000

local ORIGIN = POINTS_CONTAINER:GetModelCFrame().Position
local TAU = 2 * math.pi

-- Create spline
local Points = {}
for i = 1, #POINTS_CONTAINER:GetChildren() do
	Points[i] = POINTS_CONTAINER:FindFirstChild(i).Position - ORIGIN
end
local Spline = CatRom.new(Points)

-- Calculate c_n
local c = table.create(NUM_CYCLES)

for i = 1, NUM_CYCLES do
	local n = i - math.ceil(NUM_CYCLES / 2)
	c[i] = {
		Integrate.Simp38Comp(function(t)
			local pos = Spline:SolvePosition(t)
			local theta = -n * TAU * t
			return Vector3.new(
				pos.X * math.cos(theta) - pos.Z * math.sin(theta),
				0,
				pos.X * math.sin(theta) + pos.Z * math.cos(theta)
			)
		end, 0, 1, INTEGRATION_STEPS),
		n
	}
end

table.sort(c, function(a, b) -- Sort the beams by length for aesthetic
	return a[1].Magnitude > b[1].Magnitude
end)

-- Visuals
local BeamCircles = table.create(NUM_CYCLES) do
	local beamObject = Instance.new("Beam")
	beamObject.Transparency = NumberSequence.new(0)
	beamObject.Width0 = 0.04
	beamObject.Width1 = 0.04
	beamObject.Color = ColorSequence.new(Color3.new())

	local beamFolder = Instance.new("Folder")
	beamFolder.Name = "Circles"

	for i = 1, NUM_CYCLES do
		BeamCircles[i] = DrawBeamCircle({
			BeamObject = beamObject,
			Radius = c[i][1].Magnitude,
			TiltAngle = math.pi / 2,
			Parent = beamFolder
		})
	end

	beamFolder.Parent = workspace
end

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

	local trail = Instance.new("Trail")
	trail.Lifetime = 1 / FREQUENCY
	trail.FaceCamera = true
	trail.Transparency = NumberSequence.new(0, 1)
	trail.Attachment0 = trailAttachment0
	trail.Attachment1 = trailAttachment1
	trail.Parent = Pencil
end

-- Run
local startTime = tick()
RunService.Heartbeat:Connect(function()
	local t = (tick() - startTime) % (1 / FREQUENCY) * FREQUENCY
	local sum = ORIGIN
	
	for i = 1, NUM_CYCLES do
		local c_i = c[i][1]
		local n = c[i][2]

		local theta = n * TAU * t
		local summand = Vector3.new(
			c_i.X * math.cos(theta) - c_i.Z * math.sin(theta),
			0,
			c_i.X * math.sin(theta) + c_i.Z * math.cos(theta)
		)
		BeamCircles[i].CFrame = CFrame.new(sum)
		if c[i][1].Magnitude > 0.2 then
			-- Don't draw the really small arrows
			gizmo.drawRay(sum, summand)
		end
		
		sum += summand
	end

	Pencil.CFrame = CFrame.new(sum)
end)