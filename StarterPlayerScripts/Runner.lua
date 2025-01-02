local Meta = setmetatable({},{
	__index = function(self,name)
		name = string.lower(string.sub(name,1,1)) .. string.sub(name,2)
		local pass,result = pcall(function(key) 
			local indexing = string.split(key,".")
			local Match = nil
			for i=1,#indexing do
				local Library = {
					math = math,
					instance = Instance,
					string = string,
					enum = Enum,
					script = script,
					table = table,
					game = setmetatable({},{
						__index = function(self,name)
							local pass,service = pcall(game.GetService,game,string.upper(string.sub(name,1,1)) .. string.sub(name,2))
							if pass then
								self[name] = service
								return service
							end
						end,
					})
				}
				if not Match then
					Match = Library[indexing[i]]
				else
					Match = Match[indexing[i]]
				end
			end
			if Match == nil then
				error(key .. " | This Value Does Not Exist.")
			end
			return Match
		end,name)
		if pass then
			self[name] = result
			return result
		end
	end,
})
local l_Replicated_l = Meta.game.replicatedStorage
local MainServer = l_Replicated_l.GameQuery
local GameStarted = l_Replicated_l.GameInitialized
if not GameStarted.Value then
	repeat wait() until GameStarted.Value
end
local Modules = {
	Algorithm = require(l_Replicated_l.Algorithm),
}
local GeneratedKeys,PublicKey = MainServer:InvokeServer("ReceiveGameInformation")
local LeaderboardKeys = {public=GeneratedKeys.public,private=GeneratedKeys.private,["shared"]=GeneratedKeys.shared}
local Keys = tostring(LeaderboardKeys.public) .. "/" .. tostring(LeaderboardKeys.private) .. "/" .. tostring(LeaderboardKeys.shared)
local EncryptedKeysWithPublicKey = Modules.Algorithm(Keys,PublicKey)
local TemporaryTick = nil
local GameVersion = Meta.game.replicatedStorage.Version.Value
local AttemptKey = "Game Version: Nice Try, There Is Nothing Here, Except You Exploiter."
print(Meta.string.sub(AttemptKey,1,13),GameVersion)

