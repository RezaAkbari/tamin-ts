local userParams = teamyar.get_input();
local fileName = userParams["file_name"];

local total_param = teamyar.get_input ()
local query = teamyar.get_attachment("query_groups_parent_product.txt");
local param = {
    query = query ,
    param = {}
}
local result = {}
db.query(param)
local record = {}
while db.query_fetch(record) do
    table.insert(result, {
        group_product_id = record[1],
        group_product_name = record[2],
        product_id = record[3],
        product_full_Name = record[4],
        group_main_id = record[5],
        center_name  = record[6],
        group_main_name = record[7],
    })
end
db.query_free()
local resultExp = result
local jsonResult = json.encode(resultExp);


local timeCurrent = time.current()
local querySelectTime = teamyar.get_attachment("query_day_selected.txt");
querySelectTime = string.gsub(querySelectTime ,"{{whereDimDate}}" , "DATEKEY <= "..tostring(timeCurrent).." and DATEKEY+24*60*60*10000000 >= "..tostring(timeCurrent));

local paramSelectTime = {
    query= querySelectTime,
    params={}
}
db.query(paramSelectTime);
local resultSelectTime = db.query_fetch();
db.query_free();
local year = resultSelectTime[2];
local month = resultSelectTime[3];
fileName = fileName.."-"..tostring(year).."-"..tostring(month)..".xlsx";

local dataExp = {};
for i = 1, #result, 1 do
    local item = result[i];
    if  item.product_id ~= nil and
            item.product_full_Name ~= nil and
            item.group_product_id ~= nil and
            item.group_product_name ~= nil and
            item.group_main_id ~= nil and
            item.center_name ~= nil and
            item.group_main_name ~=  nil then



        table.insert(dataExp ,{
            group_product_id = item.group_product_id,
            group_product_name = item.group_product_name,
            product_id = item.product_id,
            product_full_Name = item.product_full_Name,
            group_main_id = item.group_main_id,
            group_main_name = item.group_main_name ,
            center_name = item.center_name ,
            center_value = 0 ,
            center_sazemani_name = "واحد سازمانی" ,
            center_sazemani_value = 0 ,
            year = year,
            month = month,
            description = "",
            first_target = 0,
            after_edit_target = 0,
            manufactured_product = "",
            active_product = "",
        });
    end
end


teamyar.write_result("Creating file excel: ".. fileName )

local template = teamyar.get_attachment("template_index.html");
template = string.gsub(template ,"{{dataTamin}}" , json.encode(dataExp) )
template = string.gsub(template ,"{{file_name}}" , fileName)

teamyar.write_result(template)