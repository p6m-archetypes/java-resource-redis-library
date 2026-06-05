-- java-resource-redis-library standalone entry point.
local context = Context.new()
require("lib").run(context)
return context
