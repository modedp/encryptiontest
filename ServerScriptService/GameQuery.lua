local G_ = setmetatable({},{
	__index = function(self,name)
		local pass,service = pcall(game.GetService,game,string.upper(string.sub(name,1,1)) .. string.sub(name,2))
		if pass then
			self[name] = service
			return service
		end
	end,
})
local RS = G_.replicatedStorage
local SS = G_.serverStorage
local PLR = G_.Players
local ServerRemote = RS:FindFirstChild("GameQuery") or Instance.new("RemoteFunction",RS)
ServerRemote.Name = "GameQuery"
local ScoreCheck = RS:FindFirstChild("ScoreQuery") or Instance.new("RemoteEvent",RS)
ScoreCheck.Name = "ScoreQuery"
local CurrentPublicKey = RS:FindFirstChild("PublicKey") or Instance.new("StringValue",RS)
CurrentPublicKey.Value = tostring(math.floor(tick()))
local CurrentlyActive = RS:FindFirstChild("GameInitialized") or Instance.new("BoolValue",RS)
local CurrentVersion = RS.Version
local Algorithm = require(RS.Algorithm)
local KeyGenerator = require(SS.GenerateKeys)
local GKEYS = KeyGenerator()
local Private,Public,Shared = GKEYS.private,GKEYS.public,GKEYS.shared
local PPI = Algorithm(CurrentPublicKey)

local PlayerKeys = {}
local PlayerInstance = {}
local ServerInstanceKeys = {} -- Extremely Important
local WarningLog = {}

local function AccessTime()
	return os.time("%X")
end

local function PlayerData(plrId)
	local Data = PlayerInstance[plrId] or {
		JoinedBefore = false,
		Requested = false,
	}
end

local function AccessWarningLog(...)
	local PArgs = {...}
	local Permission,Entry,Value = PArgs[1],PArgs[2],PArgs[3]
	if Permission == "write" then
		local warningEntry = WarningLog[Entry] or {}
		warningEntry[AccessTime()] = Value
		WarningLog[Entry] = warningEntry
	elseif Permission == "read" then
		return WarningLog[Entry]
	end
end

local function WarningSystem(plr,kind,punishment)
	local MessageList = {
		"User %s already generated a player key. | System failed to generate new API key.",
		"User %s sent an incorrectly encrypted message. | Your client failed to respond a server message.",
		"User %s failed to respond API call. | Connection Reset.",
	}
	local plrName = plr.Name
	local plrId = plr.UserId
	local Reason = string.split(MessageList[kind],"|")
	local ConsoleCode = string.gsub(Reason[1],plrName)
	if punishment == "Kick" then
		plr:Kick("The server has ended connection to the client, Error Code:" .. Reason[2])
	end
	AccessWarningLog("write",plrId,ConsoleCode)
	warn(ConsoleCode)
end

local function KeyGeneration()
	return KeyGenerator()
end

local function StoreKey(Origin,KeyData)
	if string.find(Origin,"player") then
		PlayerKeys[string.split(Origin,".")[2]] = KeyData
	elseif Origin == "server" then
		ServerInstanceKeys = KeyData
	end
end

local function GeneratePlayerKey(plrUserId)
	local PlayerKey = KeyGeneration()
	StoreKey("player." .. plrUserId,PlayerKey)
	return PlayerKey
end

local function GetKeyPlayer(basePlayer)
	local UID = basePlayer.UserId
	if basePlayer and PlayerKeys[UID] then
		return PlayerKeys[UID]
	else
		return GeneratePlayerKey(UID)
	end
end

function PlayerCall(Plr,...)
	local Arguments = {...}
	if Arguments[1] == "ReceiveGameInformation" then
		local Data = PlayerData(Plr.UserId)
		if Data.Requested == false then
			
		else
			WarningSystem(Plr,1,"Kick")
		end
	end
end

function PlayerAdded(Player)
	local AccessData = PlayerData(Player.UserId)
	if not AccessData.JoinedBefore then
		AccessData.JoinedBefore = true
	else
		AccessData.Requested = false
	end
	PlayerInstance[Player.UserId] = AccessData
end

function PlayerDisconnect(Player)
	local AccessData = PlayerData(Player.UserId)
	PlayerInstance[Player.UserId] = AccessData
end

ServerRemote.OnClientInvoke = PlayerCall

PLR.PlayerRemoving:Connect(PlayerDisconnect)
PLR.PlayerAdded:Connect(PlayerAdded)
CurrentlyActive.Value = true
