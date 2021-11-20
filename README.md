# Maid
Roblox library to manage connections and tasks. Compatible with [Moonwave](https://github.com/UpliftGames/moonwave).

```lua

local maid = Maid.new()

local connection = workspace.ChildAdded:Connect(function()

end)

maid:Add(connection)
maid:Cleanup()

-- Connections aren't necessarily immediately disconnected when `Disconnect` is called on them
-- Much reliable to check in the next engine execution step:
task.defer(function()
  print(connection.Connected) --> false
end)
```
