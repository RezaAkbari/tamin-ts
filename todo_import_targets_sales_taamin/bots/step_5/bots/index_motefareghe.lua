local params = {
    groupId = 18721 ,
    allGroups = false
}
local path = "332/sales_accept_final_target_status"
result = teamyar.run_command(path, params)
teamyar.write_result(result)

