for _, child in ipairs(workspace.RobloxLogo:GetChildren()) do
	child.Transparency = 1
end

for _, child in ipairs(workspace.StudioLogo:GetChildren()) do
	child.Transparency = 1
end

workspace.StudioPart:Destroy()
workspace.RobloxPart:Destroy()