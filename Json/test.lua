local userInfo = teamyar.get_user_info()
local userId = 776271
--[[
if userInfo ~= nil and userInfo.id ~= nil then
    userId = sales_center_id
end
-- userId = 776271
--  10675   ثمانه فروزنده بهبهانی
-- 849958   نازنین بیداری
-- 712532  صادقی
-- 16447 جمالی
-- 15984 اردبیلی
]]
local listAgents = teamyar.get_attachment("agentsMember.json");
listAgents = json.decode(listAgents);

local agentsSelected = getAgentRemembers(userId , listAgents);
function getAgentRemembers(agentId , agents)
    for i=0, #agents, 1  do
        local item = agents[i];
        if item.agentId ~= nil and agentId == userId and  item.members ~= nil then
            return item.members;
        end
    end
    return nil;
end


local sqlWhereIn = readySqlWhereIn("sce.REFERE_ID" , agentsSelected);
function readySqlWhereIn(column , agents)
    local str = column .. " in ( ";
    for i=0, #agents, 1  do
        local item = agents[i];
        if item ~= nil  then
            str  = str .. tostring(item);
        end
        if i == #agentsSelected then
            str = str .. " , ";
        end
    end
    str = str .. " ) ";
    return nil;
end

teamyar.write_log(json.encode(agentsSelected))
teamyar.write_log(json.encode(sqlWhereIn))

