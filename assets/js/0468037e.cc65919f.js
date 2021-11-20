"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[27],{29498:function(e){e.exports=JSON.parse('{"functions":[{"name":"new","desc":"A constructor method which creates a new maid.","params":[],"returns":[{"desc":"","lua_type":"Maid"}],"function_type":"static","source":{"line":85,"path":"src/Maid.lua"}},{"name":"IsMaid","desc":"A method which is used to check if the given argument is a maid or not.","params":[{"name":"self","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"static","source":{"line":98,"path":"src/Maid.lua"}},{"name":"Add","desc":"Adds a Task for the maid to cleanup. Note that `table` must have a `Destroy` or `Disconnect` method.","params":[{"name":"Task","desc":"","lua_type":"function | RBXScriptConnection | table | Instance"}],"returns":[{"desc":"","lua_type":"Task"}],"function_type":"method","tags":["Maid"],"source":{"line":110,"path":"src/Maid.lua"}},{"name":"Remove","desc":"Removes the Task so that it will not be cleaned up.","params":[{"name":"Task","desc":"","lua_type":"function | RBXScriptConnection | table | Instance"}],"returns":[],"function_type":"method","tags":["Maid"],"source":{"line":137,"path":"src/Maid.lua"}},{"name":"Cleanup","desc":"Cleans up all the added Tasks.\\n\\n| Task      | Type                          |\\n| ----------- | ------------------------------------ |\\n| `function`  | The function will be called.  |\\n| `table`     | Any `Destroy` or `Disconnect` method in the table will be called. |\\n| `Instance`    | The Instance will be destroyed. |\\n| `RBXScriptConnection`    | The connection will be disconnected. |","params":[],"returns":[],"function_type":"method","tags":["Maid"],"source":{"line":153,"path":"src/Maid.lua"}},{"name":"End","desc":"Disconnect a specific Task","params":[{"name":"Task","desc":"Task to disconnect","lua_type":"function | RBXScriptConnection | table | Instance"}],"returns":[],"function_type":"method","tags":["Maid"],"source":{"line":177,"path":"src/Maid.lua"}},{"name":"Destroy","desc":"Destroys the maid by first cleaning up all Tasks, and then setting all the Keys in it to `nil`\\nand lastly, sets the metatable of the maid to `nil`.\\n\\n:::warning\\nTrivial errors will occur if your code unintentionally works on a destroyed maid, only call this method when you\'re done working with the maid.\\n:::","params":[],"returns":[],"function_type":"method","tags":["Maid"],"source":{"line":193,"path":"src/Maid.lua"}},{"name":"LinkToInstance","desc":"Links the given Instance to the maid so that the maid will clean up all the Tasks once the Instance has been destroyed\\nvia `Instance:Destroy`. The connection returned by this maid contains the following methods:\\n\\n| Methods      | Description                          |\\n| ----------- | ------------------------------------ |\\n| `Disconnect`  | The connection will be disconnected and the maid will unlink to the Instance it was linked to.  |\\n| `IsConnected` | Returns a boolean indicating if the connection has been disconnected. |\\n\\nNote that the maid will still unlink to the given Instance if it has been cleaned up!","params":[{"name":"Instance","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"Connection"}],"function_type":"method","source":{"line":235,"path":"src/Maid.lua"}}],"properties":[],"types":[],"name":"Maid","desc":"Maids track Tasks and clean them when needed.\\n\\nFor e.g:\\n```lua\\nlocal maid = Maid.new()\\nlocal connection = workspace.ChildAdded:Connect(function()\\n\\nend)\\nmaid:Add(connection)\\nmaid:Cleanup()\\n\\n-- Connections aren\'t necessarily immediately disconnected when `Disconnect` is called on the.\\n-- Much reliable to check in the next engine execution step:\\ntask.defer(function()\\n\\tprint(connection.Connected) --\x3e false\\nend)\\n```","source":{"line":42,"path":"src/Maid.lua"}}')}}]);