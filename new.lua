local DS = game:GetService("DataStoreService")
local PlayersGold = DS:GetOrderedDataStore("PlayersGold")
local PlayersSize = DS:GetOrderedDataStore("PlayersSize")
local PlayersKill =DS:GetOrderedDataStore("PlayersKill")

local PlayerTotalSizeStore = DS:GetDataStore("PlayerTotalSizeStore")
local PlayerTotalkillStore = DS:GetDataStore("PlayerTotalkillStore")

local PlayerProfileStore = DS:GetDataStore("PlayerProfileStore")

local Players = game:GetService("Players")
local RPS = game:GetService("ReplicatedStorage")
local ss = game:GetService("ServerStorage")

local PlayersScoreFol = ss:WaitForChild("PlayersScoreFol")

local MakeGlBre = RPS:WaitForChild("DSEvents").MakeGlBre

local success4, AllProfileUrls = pcall(function()
	return PlayerProfileStore:GetAsync("PlayersProfileURL")

end)

local maxItems = 10
local minValueDisplay = 0
local maxValueDisplay = 10e15
local abbreviateValue = true
local updateEvery = 1

local ProfileURLTable = {}

local function LoadTotalScore(player)
	
	local playerScoresFold = PlayersScoreFol:WaitForChild(player.Name)

	local CheckTotalSize = playerScoresFold:FindFirstChild("TotalSize")
	local CheckTotalKills = playerScoresFold:FindFirstChild("TotalKills")
	
	if CheckTotalKills then return end

	local TotalSize
	if not CheckTotalSize then

		TotalSize = Instance.new("IntValue",playerScoresFold)
		TotalSize.Name = "TotalSize"
	end

	local TotalKills
	if not CheckTotalKills then

		TotalKills = Instance.new("IntValue",playerScoresFold)
		TotalKills.Name = "TotalKills"
	end
	
	local Key = player.UserId
	
	local success, PlayerTotalSize = pcall(function()
		
		return PlayersSize:GetAsync(Key)
	end)
	
	local success2, PlayerTotalKills = pcall(function()

		return PlayersKill:GetAsync(Key)
	end)
	
	if success and PlayerTotalSize then
		
		if CheckTotalSize then
			CheckTotalSize.Value = PlayerTotalSize
		else
			if TotalSize then
				TotalSize.Value = PlayerTotalSize
			end
		end
	end
	
	if success2 and PlayerTotalKills then
		
		if CheckTotalKills then
			CheckTotalKills.Value = PlayerTotalKills
		else
			if TotalKills then
				TotalKills.Value = PlayerTotalKills
			end
		end
	end
end

local function SaveTotalScore(player)
	
	local playerScoresFold = PlayersScoreFol:FindFirstChild(player.Name)

	local CheckTotalSize = playerScoresFold:FindFirstChild("TotalSize")
	local CheckTotalKills = playerScoresFold:FindFirstChild("TotalKills")

	local TotalSize
	if not CheckTotalSize then

		TotalSize = Instance.new("IntValue",playerScoresFold)
		TotalSize.Name = "TotalSize"
	end

	local TotalKills
	if not CheckTotalKills then

		TotalKills = Instance.new("IntValue",playerScoresFold)
		TotalKills.Name = "TotalKills"
	end
	
	local Key = "PlayersProfileURL"
	
	local success, Error = pcall(function()
		PlayersSize:UpdateAsync(Key, function()
			local no = CheckTotalSize ~= nil and CheckTotalSize.Value or TotalSize.Value
			local Value = no
			return Value
		end)
	end)

	local success2, Error2 = pcall(function()
		PlayersKill:UpdateAsync(Key, function()
			local no = CheckTotalKills ~= nil and CheckTotalKills.Value or TotalKills.Value
			local Value = no
			return Value
		end)
	end)
	
	local success3, PlayerProfileSave = pcall(function()
		
		local url, success = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		
		if not AllProfileUrls[url] then
			table.insert(ProfileURLTable,url)
			return PlayerProfileStore:SetAsync(Key,ProfileURLTable)
		end
	end)

end

local function CallClientMakeGLB(player)
		
	local success, SortedGoldData = pcall(function()
		local sortedGoldData = PlayersGold:GetSortedAsync(false, maxItems, minValueDisplay, maxValueDisplay)
		return sortedGoldData
	end)
	
	local success2, SortedSizedata = pcall(function()

		return PlayersSize:GetSortedAsync(false, maxItems, minValueDisplay, maxValueDisplay)
	end)
	
	local success3, SortedKillsdata = pcall(function()

		return PlayersKill:GetSortedAsync(false, maxItems, minValueDisplay, maxValueDisplay)
	end)
	
	local success4, PlayerProfileLoad = pcall(function()
		return PlayerProfileStore:GetAsync("PlayersProfileURL")
		
	end)
	
	if success4 and PlayerProfileLoad then

		ProfileURLTable = PlayerProfileLoad
	end
		
	if success and SortedGoldData then
		local GoldtopPage = SortedGoldData:GetCurrentPage()
		
		for _, player in pairs(Players:GetPlayers()) do
			
			task.spawn(function()
				MakeGlBre:FireClient(player, GoldtopPage,"Gold",ProfileURLTable)
			end)
		end		
	end
	
	if success2 and SortedSizedata then
		local SizetopPage = SortedSizedata:GetCurrentPage()
		
		for _, player in pairs(Players:GetPlayers()) do
			
			task.spawn(function()
				MakeGlBre:FireClient(player, SizetopPage,"Size",ProfileURLTable)
			end)
		end		
	end
	
	if success3 and SortedKillsdata then
		local KiilstopPage = SortedKillsdata:GetCurrentPage()
		
		for _, player in pairs(Players:GetPlayers()) do
			
			task.spawn(function()
				MakeGlBre:FireClient(player, KiilstopPage,"Kills",ProfileURLTable)
			end)
		end		
	end
end

local function onPlayerRemoving(player)
	
	local playerScoresFold = PlayersScoreFol:FindFirstChild(player.Name)

	local CheckTotalSize = playerScoresFold:FindFirstChild("TotalSize")
	local CheckTotalKills = playerScoresFold:FindFirstChild("TotalKills")
	
	local TotalSize
	if not CheckTotalSize then

		TotalSize = Instance.new("IntValue",playerScoresFold)
		TotalSize.Name = "TotalSize"
	end

	local TotalKills
	if not CheckTotalKills then

		TotalKills = Instance.new("IntValue",playerScoresFold)
		TotalKills.Name = "TotalKills"
	end

	local ScoreInt = playerScoresFold:FindFirstChild("Score")

	local Key = player.UserId

	pcall(function()
		-- Use PlayersGold:IncrementAsync if you want to increment the score instead of overriding
		PlayersGold:UpdateAsync(Key, function()
			return tonumber(ScoreInt.Value)
		end)

		PlayersSize:UpdateAsync(Key,function()
			local Value = TotalSize ~= nil and TotalSize.Value or CheckTotalSize.Value
			return Value
		end)

		PlayersKill:UpdateAsync(Key,function()
			local Value = TotalKills ~= nil and TotalKills.Value or CheckTotalKills.Value
			return Value
		end)
	end)
end

Players.PlayerAdded:Connect(function(player)
	print("player added")
	CallClientMakeGLB(player)

	task.spawn(function()
		LoadTotalScore(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	
	task.spawn(function()
		onPlayerRemoving(player)
	end)
	
	task.spawn(function()
		SaveTotalScore(player)
	end)
end)


while wait(updateEvery) do
	
	updateEvery = 60
	
	for _, playerFold in ipairs(PlayersScoreFol:GetChildren()) do
		
		local GroundType = playerFold:FindFirstChild("GroundType")
		
		if GroundType then
			
			if GroundType.Value == "MG" or "BG" then  --- ihave put both the type so it can save all the values, doesnt matter in which mode you are i still save the values.
				
				local CheckTotalSize = playerFold:FindFirstChild("TotalSize")
				local CheckTotalKills = playerFold:FindFirstChild("TotalKills")

				local TotalSize
				local TotalKills
				
				local playerObject = Players:FindFirstChild(playerFold.Name)

				if not CheckTotalSize then

					TotalSize = Instance.new("IntValue",playerFold)
					TotalSize.Name = "TotalSize"
				end

				if not CheckTotalKills then

					TotalKills = Instance.new("IntValue",playerFold)
					TotalKills.Name = "TotalKills"
				end

				if workspace:FindFirstChild(playerFold.Name,true) then


					local ScoreInt = playerFold:FindFirstChild("Score")

					local Key = playerObject and Players[playerFold.Name].UserId or playerFold.Name

					local success, err = pcall(function()
						PlayersGold:UpdateAsync(Key, function()
							if not ScoreInt then return end
							return ScoreInt.Value
						end)
					end)

					local success2, err = pcall(function()
						PlayersSize:UpdateAsync(Key,function()
							if not ScoreInt then print(playerFold.Name.." Returnin not score int") return end
							local no = TotalSize ~= nil and TotalSize.Value or CheckTotalSize.Value
							local Value = no
							return Value
						end)
					end)

					local success3, err = pcall(function()
						PlayersKill:UpdateAsync(Key,function()
							if not ScoreInt then print(playerFold.Name.." Returnin not score int") return end
							local no = TotalKills ~= nil and TotalKills.Value or CheckTotalKills.Value
							local Value = no
							return Value
						end)
					end)
				end
			end
		end
	end
		
	CallClientMakeGLB()
end
