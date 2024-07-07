local total_param = teamyar.get_input ()
local query = teamyar.get_attachment("query_product_groups.txt");
query = string.gsub(query ,"{{whereGroupSalesId}}" , "and MODULE_PARENT_ID="..tostring(12905)  )
local param = {
    query = query ,
    param = {}
}
teamyar.write_log(json.encode(param))
local result = {}
db.query(param)
local record = {}
while db.query_fetch(record) do
    table.insert(result, {
        id = record[1],
        name = record[2]
    })
end
db.query_free()
local resultExp = result
local jsonResult = json.encode(resultExp);

teamyar.write_result(json.encode(jsonResult))