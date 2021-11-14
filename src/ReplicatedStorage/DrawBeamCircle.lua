-- https://gist.github.com/EthanCurtiss/a9e616dc74830bb95f9bbf976fdc9bbc
--[[
	Creates a circle out of Beams.
	
	You can let it use a default Beam object, but you probably want to pass it
	your own via the BeamObject parameter.

	local BeamCircle, Attachments, Beams = DrawBeamCircle({
		[REQUIRED]
		CFrame = CFrame of center of circle,
		Radius = Radius of circle,

		[OPTIONAL]
		BeamObject = Beam Instance to be cloned for circle's Beams,
		NumBeams = Number of beams that make up the circle,
		Parent = Parent of BeamCircle,
		TiltAngle = Tilts the beam (measured in radians)
	})
]]

local DEFAULT_BEAM_OBJECT = Instance.new("Beam")
local DEFAULT_CFRAME = CFrame.new()
local DEFAULT_NUM_BEAMS = 3
local DEFAULT_TILT_ANGLE = 0

return function(options)
	local beamObject = options.BeamObject or DEFAULT_BEAM_OBJECT
	local cframe = options.CFrame or DEFAULT_CFRAME
	local numBeams = options.NumBeams or DEFAULT_NUM_BEAMS
	local radius = options.Radius
	local tiltAngle = options.TiltAngle or DEFAULT_TILT_ANGLE

	numBeams = math.max(2, numBeams) -- doesn't work with 1 beam

	local primaryPart = Instance.new("Part")
	primaryPart.Name = "BeamCircle"
	primaryPart.Anchored = true
	primaryPart.CFrame = cframe
	primaryPart.CanCollide = false
	primaryPart.CanTouch = false
	primaryPart.Size = Vector3.new(1, 1, 1)
	primaryPart.Transparency = 1

	-- https://stackoverflow.com/questions/1734745/
	local curveSize = 4 / 3 * math.tan(math.pi / 2 / numBeams) * radius
	local segmentAngle = 2 * math.pi / numBeams

	local attachments = table.create(numBeams)
	local beams = table.create(numBeams)
	local firstAttachment
	local previousAttachment
	for i = 1, numBeams do
		local theta = (i - 1) * segmentAngle
		local attachment = Instance.new("Attachment")
		attachment.Name = "Attachment" .. i
		attachment.CFrame = CFrame.new(
			cframe.RightVector * math.cos(theta) * radius
				+ cframe.LookVector * math.sin(theta) * radius
		) * CFrame.fromEulerAnglesYXZ(tiltAngle, theta - math.pi / 2, 0)
		attachment.Parent = primaryPart
		attachments[i] = attachment

		if i == 1 then
			firstAttachment = attachment
		else
			local beam = beamObject:Clone()
			beam.Name = "Beam" .. i - 1
			beam.Attachment0 = attachment
			beam.Attachment1 = previousAttachment
			beam.CurveSize0 = curveSize
			beam.CurveSize1 = curveSize
			beam.Parent = primaryPart
			beams[i - 1] = beam
		end

		previousAttachment = attachment
	end

	-- connect the last attachment to the first
	local finalBeam = beamObject:Clone()
	finalBeam.Name = "Beam" .. numBeams
	finalBeam.Attachment0 = firstAttachment
	finalBeam.Attachment1 = previousAttachment
	finalBeam.CurveSize0 = curveSize
	finalBeam.CurveSize1 = curveSize
	finalBeam.Parent = primaryPart
	beams[numBeams] = finalBeam

	primaryPart.Parent = options.Parent

	return primaryPart, attachments, beams
end