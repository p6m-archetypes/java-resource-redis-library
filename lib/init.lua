-- java-resource-redis-library main module.
-- Renders the RedisConfig.java into the server module's cache package.
--
-- The calling archetype is responsible for adding the corresponding
-- Maven dependency to the server module's pom.xml:
--   redis:  spring-boot-starter-data-redis
--
-- API:
--   local redis = require("java-resource-redis")
--   redis.render(context, { destination = context:get("project-name") })
--
-- Context contract (prompt() fills if absent):
--   prefix-name     — kebab-case first segment (e.g. "billing")
--   suffix-name     — kebab-case second segment (e.g. "service")
--   group_id        — Maven groupId (e.g. "dev.p6m.billing")
--   root_directory  — group_id with dots→slashes (e.g. "dev/p6m/billing")

local M = {}

function M.prompt(context)
    if not context:get("prefix-name") then
        context:prompt_text("Service Prefix:", "prefix_name", {
            cases = Cases.programming(),
            placeholder = "billing",
        })
    end
    if not context:get("suffix-name") then
        context:prompt_select("Service Suffix:", "suffix_name", {
            "service", "orchestrator", "adapter",
        }, { default = "service", cases = Cases.programming() })
    end
    if not context:get("group_id") then
        context:prompt_text("Maven Group ID:", "group_id", {
            default = "dev.p6m." .. context:get("prefix-name"),
            placeholder = "dev.p6m.billing",
        })
    end
    if not context:get("root_directory") then
        context:set("root_directory", (string.gsub(context:get("group_id"), "%.", "/")))
    end
    if not context:get("project-name") then
        context:set("project-name", context:get("prefix-name") .. "-" .. context:get("suffix-name"))
    end
    return context
end

function M.render(context, opts)
    opts = opts or {}
    local d = opts.destination
    if d and d ~= "" then
        directory.render("contents", context, { destination = d })
    else
        directory.render("contents", context)
    end
    return context
end

function M.run(context, opts)
    M.prompt(context, opts)
    M.render(context, opts)
    return context
end

return M
