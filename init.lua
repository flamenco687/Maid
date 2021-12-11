-- finobinos - Original author - 16 October 2021
-- flamenco687 - Modified for personal use - 1 November 2021

--[[
	-- Static methods:

	Maid.new() --> table
	Maid.IsMaid(self : any) --> boolean

	-- Instance methods:

	Maid:Add(Task : table | function | RBXScriptConnection | Instance) --> Task
	Maid:Cleanup() --> ()
	Maid:End(Task: table | function | RBXScriptConnection | Instanceble) --> ()
	Maid:Remove(Task: table | function | RBXScriptConnection | Instance) --> ()
	Maid:LinkToInstance(Instance: Instance) --> (Instance, ManualConnection)
		ManualConnection:Disconnect() --> ()
		ManualConnection:IsConnected() --> boolean
	Maid:Destroy() --> ()
]]

--[=[
	@class Maid
	Maids track Tasks and clean them when needed.

	For e.g:
	```lua
	local maid = Maid.new()
	local connection = workspace.ChildAdded:Connect(function()

	end)
	maid:Add(connection)
	maid:Cleanup()

	-- Connections aren't necessarily immediately disconnected when `Disconnect` is called on the.
	-- Much reliable to check in the next engine execution step:
	task.defer(function()
		print(connection.Connected) --> false
	end)
	```
]=]

local Players = game:GetService("Players")

type ManualConnection = {
	_IsConnected: boolean,
}

export type Maid = {
	_Tasks: table,
}

local Maid = {}
Maid.__index = Maid

local LocalConstants = {
	ErrorMessages = {
		InvalidArgument = "Invalid argument#%d to %s: expected %s, got %s",
	},
}

local function IsInstanceDestroyed(Instance: Instance): boolean
	-- This function call is used to determine if an Instance is ALREADY destroyed,
	-- and has been edited to be more reliable but still quite hacky due to Roblox
	-- not giving us a method to determine if an Instance is already destroyed
	local _, Response = pcall(function()
		Instance.Parent = Instance
	end)

	return (Response:find("locked") and Response:find("NULL") or nil) ~= nil
end

local function DisconnectTask(Task: RBXScriptConnection | table | Instance | any)
	if typeof(Task) == "function" then
		Task()
	elseif typeof(Task) == "RBXScriptConnection" then
		-- Task was a RBXScriptConneciton or a table with a Disconnect method
		Task:Disconnect()
	else
		if Task.Destroy then
			Task:Destroy()
		else
			Task:Disconnect()
		end
	end
end

--[=[
	A constructor method which creates a new maid.

	@return Maid
]=]

function Maid.new(): Maid
	return setmetatable({
		_Tasks = {},
	}, Maid)
end

--[=[
	Checks if the given argument is a maid or not.

	@param self any
	@return boolean
]=]

function Maid.IsMaid(self: table): boolean
	return getmetatable(self) == Maid
end

--[=[
	Checks the "classname" of the given argument.

	@param self any
	@return boolean
]=]

function Maid.Is(self: table): (string, Maid)
	return "Maid", getmetatable(self)
end

--[=[
	Adds a Task for the maid to cleanup. Note that `table` must have a `Destroy` or `Disconnect` method.

	@tag Maid
	@param Task function | RBXScriptConnection | table | Instance
	@return Task
]=]

function Maid:Add(Task: RBXScriptConnection | table | Instance | any)
	assert(
		typeof(Task) == "function"
			or typeof(Task) == "RBXScriptConnection"
			or typeof(Task) == "table" and (typeof(Task.Destroy) == "function" or typeof(Task.Disconnect) == "function")
			or typeof(Task) == "Instance",

		LocalConstants.ErrorMessages.InvalidArgument:format(
			1,
			"Maid:Add()",
			"function or RBXScriptConnection or Instance or table with Destroy or Disconnect method",
			typeof(Task)
		)
	)

	self._Tasks[Task] = Task

	return Task
end

--[=[
	Removes the Task so that it will not be cleaned up.

	@tag Maid
	@param Task function | RBXScriptConnection | table | Instance
]=]

function Maid:Remove(Task: RBXScriptConnection | table | Instance | any)
	self._Tasks[Task] = nil
end

--[=[
	Cleans up all the added Tasks.
	@tag Maid

	| Task      | Type                          |
	| ----------- | ------------------------------------ |
	| `function`  | The function will be called.  |
	| `table`     | Any `Destroy` or `Disconnect` method in the table will be called. |
	| `Instance`    | The Instance will be destroyed. |
	| `RBXScriptConnection`    | The connection will be disconnected. |
]=]

function Maid:Cleanup()
	-- Next allows us to easily traverse the table accounting for more values being added. This allows us to clean
	-- up Tasks spawned by the cleaning up of current Tasks.

	local Tasks = self._Tasks
	local Key, Task = next(Tasks)

	while Task do
		Tasks[Key] = nil

		DisconnectTask(Task)

		Key, Task = next(Tasks)
	end
end

--[=[
	@tag Maid

	Disconnects a specific Task

	@param Task function | RBXScriptConnection | table | Instance -- Task to disconnect
]=]

function Maid:End(Task: RBXScriptConnection | table | Instance | any)
	self._Tasks[Task] = nil
	DisconnectTask(Task)
end

--[=[
	@tag Maid

	Destroys the maid by first cleaning up all Tasks, and then setting all the Keys in it to `nil`
	and lastly, sets the metatable of the maid to `nil`.

	:::warning
	Trivial errors will occur if your code unintentionally works on a destroyed maid, only call this method when you're done working with the maid.
	:::
]=]

function Maid:Destroy(): nil
	self:Cleanup()

	setmetatable(self, nil)
	self = nil

	return nil
end

local ManualConnection = {}
ManualConnection.__index = ManualConnection

do
	function ManualConnection.new(): ManualConnection
		return setmetatable({ _IsConnected = true }, ManualConnection)
	end

	function ManualConnection:Disconnect()
		self._IsConnected = false
	end

	function ManualConnection:IsConnected(): boolean
		return self._IsConnected
	end
end

--[=[
	Links the given Instance to the maid so that the maid will clean up all the Tasks once the Instance has been destroyed
	via `Instance:Destroy`. The connection returned by this maid contains the following methods:

	| Methods      | Description                          |
	| ----------- | ------------------------------------ |
	| `Disconnect`  | The connection will be disconnected and the maid will unlink to the Instance it was linked to.  |
	| `IsConnected` | Returns a boolean indicating if the connection has been disconnected. |

	Note that the maid will still unlink to the given Instance if it has been cleaned up!

	@param Instance Instance
	@return Connection
]=]

function Maid:LinkToInstance(Instance: Instance): ManualConnection
	assert(
		typeof(Instance) == "Instance",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "Maid:LinkToInstance()", "Instance", typeof(Instance))
	)

	local NewManualConnection = ManualConnection.new()
	self:Add(NewManualConnection)

	local function TrackInstanceConnectionForCleanup(MainConnection: RBXScriptConnection)
		while MainConnection.Connected and not Instance.Parent and NewManualConnection:IsConnected() do
			task.wait()
		end

		if not Instance.Parent and NewManualConnection:IsConnected() then
			self:Cleanup()
		end
	end

	local MainConnection
	MainConnection = self:Add(Instance:GetPropertyChangedSignal("Parent"):Connect(function()
		if not Instance.Parent then
			task.defer(function()
				if not NewManualConnection:IsConnected() then
					return
				end

				-- If the connection has also been disconnected, then its
				-- guaranteed that the Instance has been destroyed through
				-- Destroy():
				if not MainConnection.Connected then
					self:Cleanup()
				else
					-- The Instance was just parented to nil:
					TrackInstanceConnectionForCleanup(MainConnection)
				end
			end)
		end
	end))
	self:Add(MainConnection)

	-- Special case for players as they are destroyed late when they leave
	if Instance:IsA("Player") then
		self:Add(Players.PlayerRemoving:Connect(function(RemovedPlayer: Player)
			if Instance == RemovedPlayer and NewManualConnection:IsConnected() then
				self:Cleanup()
			end
		end))
	end

	if not Instance.Parent then
		task.spawn(TrackInstanceConnectionForCleanup, MainConnection)
	end

	if IsInstanceDestroyed(Instance) then
		self:Cleanup()
	end

	return NewManualConnection
end

return Maid
