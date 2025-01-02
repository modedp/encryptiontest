local method = require(game.ServerStorage.GenerateKeys)() 
local x = require(game.ReplicatedStorage.Algorithm) 
local message = "I won the game. Score 1000"
local encrypted = x(message,method) 
local decryptmethod = method decryptmethod.public = nil 
local decrypted = x(encrypted,decryptmethod) 
print(decrypted)
