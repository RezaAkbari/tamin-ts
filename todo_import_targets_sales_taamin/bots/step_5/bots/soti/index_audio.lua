local params = teamyar.get_input();

function getTaskData()
    local task_id = 0;
    local task_step_id = 0;
    ---
    if params.task_id ~= nil then
        task_id = params.task_id;
    end
    if params.task_step_id ~= nil then
        task_step_id = params.task_step_id;
    end
    return task_id , task_step_id;
end

local task_id , task_step_id = getTaskData();

local params = {
    task_id=task_id,
    task_step_id=task_step_id,
    groupId = 13076 ,
    allGroups = false
}
local path = "258/sales_accept_final_target_status"
result = teamyar.run_command(path, params)
teamyar.write_result(result)

