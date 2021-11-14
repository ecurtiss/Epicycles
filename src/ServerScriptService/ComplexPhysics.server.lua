--[[
	This was my third attempt using complex coefficients and physics.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CatRom = require(ReplicatedStorage.CatRom)
local Integrate = require(ReplicatedStorage.CatRom.Integrate)

-- Settings
local POINTS_CONTAINER = workspace.StudioLogo
local NUM_CYCLES = 100
local FREQUENCY = 1 / 16 -- revolutions per second
local INTEGRATION_STEPS = 1000

local ORIGIN = Vector3.new(0, 15, 0)
local TAU = 2 * math.pi

-- Create spline
local Points = {}
for i = 1, #POINTS_CONTAINER:GetChildren() do
	Points[i] = POINTS_CONTAINER:FindFirstChild(i).Position
end
local Spline = CatRom.new(Points)

-- Calculate c_n
local c = table.create(NUM_CYCLES)

for i = 1, NUM_CYCLES do
	local n = i - NUM_CYCLES / 2
	local c_n = Integrate.Simp38Comp(function(t)
		local pos = Spline:SolvePosition(t)
		local theta = -n * TAU * t
		return Vector3.new(
			-pos.Z * math.cos(theta) + pos.X * math.sin(theta),
			0,
			-pos.Z * math.sin(theta) - pos.X * math.cos(theta)
		)
	end, 0, 1, INTEGRATION_STEPS)
	c[i] = {c_n, n}
end

table.sort(c, function(a, b)
	return a[1].Magnitude > b[1].Magnitude
end)

-- Construct mechanics
workspace.Gravity = 0

local OriginAttachment = Instance.new("Attachment")
OriginAttachment.Name = "Tip"
OriginAttachment.CFrame = CFrame.new(ORIGIN)
OriginAttachment.Parent = workspace.Terrain

local RodsContainer = Instance.new("Folder")
RodsContainer.Name = "Rods"
RodsContainer.Parent = workspace

local Rods = table.create(NUM_CYCLES)

for i = 1, NUM_CYCLES do
	local c_n = c[i][1]
	local n = c[i][2]
	local length = c_n.Magnitude
	local prevRod = if i == 1 then workspace.Terrain else Rods[i - 1]
	
	local rod = Instance.new("Part")
	rod.Size = Vector3.new(1, 1, 1)
	rod.Anchored = false
	rod.CanCollide = false
	rod.CFrame = CFrame.new(prevRod.Tip.WorldPosition)
		* CFrame.Angles(math.atan2(c_n.Z, c_n.X), 0, 0) -- Initial angle
	rod.CustomPhysicalProperties = PhysicalProperties.new(
		length * 2, -- I don't know if this actually helps
		0,
		0
	)
	
	local blockMesh = Instance.new("BlockMesh")
	blockMesh.Scale = Vector3.new(0.2, 0.2, length)
	blockMesh.Offset = Vector3.new(0, 0, -length / 2)
	blockMesh.Parent = rod
	
	local tail = Instance.new("Attachment")
	tail.Name = "Tail"
	tail.CFrame = CFrame.new()
	tail.Parent = rod
	
	local tip = Instance.new("Attachment")
	tip.Name = "Tip"
	tip.CFrame = CFrame.new(0, 0, -length)
	tip.Parent = rod
	
	local hinge = Instance.new("HingeConstraint")
	hinge.Attachment0 = prevRod.Tip
	hinge.Attachment1 = tail
	hinge.Parent = prevRod
	
	local angularVelocity = Instance.new("AngularVelocity")
	angularVelocity.Attachment0 = tail
	angularVelocity.AngularVelocity = Vector3.new(n * TAU * FREQUENCY, 0, 0)
	angularVelocity.MaxTorque = 1e4
	angularVelocity.Parent = rod
	
	rod.Parent = RodsContainer
	Rods[i] = rod
end

RodsContainer.Parent = workspace

-- Visuals
local LastPart = Rods[NUM_CYCLES]
do
	local trailAttachment0 = Instance.new("Attachment")
	trailAttachment0.CFrame = LastPart.Tip.CFrame + Vector3.new(0, -0.2, 0)
	trailAttachment0.Parent = LastPart

	local trailAttachment1 = Instance.new("Attachment")
	trailAttachment1.CFrame = LastPart.Tip.CFrame + Vector3.new(0, 0.2, 0)
	trailAttachment1.Parent = LastPart

	local trail = Instance.new("Trail")
	trail.Lifetime = 1 / FREQUENCY
	trail.FaceCamera = true
	trail.Transparency = NumberSequence.new(0, 1)
	trail.Attachment0 = trailAttachment0
	trail.Attachment1 = trailAttachment1
	trail.Parent = LastPart
end