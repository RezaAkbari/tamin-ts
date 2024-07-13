local _CONST_PRODUCT_MANUFACTORED = {
    _N = "N" ,
    _Y = "Y" ,
    _P = "P" ,
    _M = "M" ,

}

local _CONST_PRODUCT_ACTIVE = {
    _NO = "N" ,
    _YES = "Y"
}



----------------
local all = false;
local accessGroupId =12648;
----------------

local _tableName = "supply_unit_product_result_target_accepts";

function createTable()
    db.use_db("0000000_bot")
    local params = {
        name = _tableName,
        fields =" id BIGINT NOT NULL AUTO_INCREMENT , target_id  BIGINT NOT NULL , agent_id bigint not null , agent_value bigint default(0)  , agent_percent bigint default(0)   ",

        index_items = {{1, "primary", "id"}}
    };
    db.check_table(params);
    db.use_db("0000000");
end




function selectData()
    createTable()

    db.use_db("0000000_bot")

    local param = {
        query = "SELECT id , target_id  , agent_id , agent_value  , agent_percent  FROM " .. _tableName,
        params = { }
    }
    local result = {}
    db.query(param)
    local record = {}
    while db.query_fetch(record) do
        table.insert(result, {
            id = record[1],
            target_id = record[2],
            agent_id = record[3],
            agent_value = record[4],
            agent_percent = record[5]
        })
    end
    db.query_free()
    db.use_db("0000000");
    return result;
end


function executeData(listData)

    for i = 1 , #listData , 1 do
        local itemData = listData[i];

        if  itemData.product_id ~= nil and itemData.agent_id ~= nil and itemData.agent_value ~= nil and itemData.agent_percent ~= nil then

            local year = tonumber(itemData.year);
            local month = tonumber(itemData.month);

            --[[local accessFull , accessDownload , agentMembers = checkAccessClient()
            local listAgents = checkAgentMembers(agentMembers);

            local existAgent = false;
            for x = 1 , #listAgents , 1 do
                local itemAgent = listAgents[x];
                if itemAgent ~= nil then
                    existAgent = true;
                    break;
                end
            end

            if existAgent == true then
                local targetId = getTargetId( itemData.product_id ,  year ,  month);
                if targetId ~= nil and targetId > 0 then
                    deleteRecordTargetSelected(targetId)
                    insertData(targetId , itemData.agent_id ,itemData.agent_value ,itemData.agent_percent );
                end
            end]]


        end
    end
end

function getTargetId(product_id , year , month  )
    createTable()
    db.use_db("0000000_bot")

    local query = teamyar.get_attachment("query_check_exist_target_accept.txt");
    query = string.gsub(query , "{{whereTargets}}" , " where  product_id=? and year=? and month=? ")

    local param = {
        query = query ,
        param = {
            product_id , year , month
        }
    }
    local result = {}
    db.query(param)
    local record = {}
    local result = db.query_fetch();
    db.query_free()
    db.use_db("0000000");

    if result ~= nil and result[1] ~= nil then
        return result[1];
    end
    return nil;
end

function deleteRecordTargetSelected(targetId)
    createTable();
    db.start();
    db.use_db("0000000_bot")
    local params = {
        query = "delete from " .. _tableName .. " where target_id=?",
        params = {targetId}
    };
    db.query_immediate(params)
    db.commit();
    db.use_db("0000000");
end

function insertData(target_id , agent_id , agent_value ,agent_percent  )
    createTable();
    db.start();
    db.use_db("0000000_bot")
    local params = {
        query = "insert into " .. _tableName .. " (target_id  , agent_id , agent_value , agent_percent) values (?,?,?,?)",
        params = {target_id  , agent_id , agent_value , agent_percent }
    };
    db.query_immediate(params)
    db.commit();
    db.use_db("0000000");
end


----------------------------------
function readyListProduct(year , month )
    createTable();
    local listProduct = getProductGroupSelected();
    local listProductTamin = getListProductTamin(year , month);
    listProduct = readyListWithProductTamin(listProduct , listProductTamin);
    listProduct = readyListWithAgents(listProduct)

    local listAgents = getListAgents();

    --- اضافه شدن رکورد قبلی که ذخیره شده است
    return {
        list = listProduct ,
        agents = listAgents
    };
end


function getProductGroupSelected()
    local groupData = teamyar.get_attachment("groups.json");
    groupData = json.decode(groupData);

    local query = teamyar.get_attachment("query_products_in_group_selected.txt");
    local status = false;
    if all== true then
        local ids = {};
        for i = 1 , #groupData, 1 do
            local itemGroup = groupData[i];
            if itemGroup.id ~= nil  then
                table.insert(ids , itemGroup.id);
            end
        end
        query , status = getQuerySelectGroup(query  , ids , "")
    else
        for i = 1 , #groupData, 1 do
            local itemGroup = groupData[i];
            if itemGroup.id ~= nil and itemGroup.name~=nil and itemGroup.id == accessGroupId then
                query ,status= getQuerySelectGroup(query  , itemGroup.id , itemGroup.name);
                break;
            end
        end
    end

    local listExp = {};
    if status == true then

        local param = {
            query = query ,
            param = {}
        }
        db.query(param)
        local record = {}
        while db.query_fetch(record) do
            table.insert(listExp, {
                id = 0,
                product_group_main_id = record[1],
                product_group_main_name = record[2],

                product_group_id = record[3],
                product_group_name = record[4],

                product_id = record[5],
                product_name = record[6],
                product_full_code = record[7],

                product_manufactured = _CONST_PRODUCT_MANUFACTORED._N,
                product_active = _CONST_PRODUCT_ACTIVE._NO,
                description = "",

                center_name = record[8] ,
                center_first = 0 ,
                center_value = 0 ,
                center_total = 0 ,

                year = "",
                month ="" ,
                agents = {}
            })
        end

    end

    return listExp
end
function getQuerySelectGroup(query , id , name)
    local status = false;

    query = string.gsub(query , "{{selectGroupName}}" , name);

    local str ="";
    if all==true then
        str =" ( ";
        for i=1, #id , 1 do
            status = true;
            local item = id[i];
            if item ~= nil then
                str = str .. tostring(item);
            end
            if i < #id then
                str = str .. " , ";
            end
        end
        str = str .. " ) ";

        query = string.gsub(query , "{{selectGroupId}}" , "null");
    else
        str = "("..tostring(id)..")"
        query = string.gsub(query , "{{selectGroupId}}" , (id));
        status = true;
    end
    query = string.gsub(query , "{{selectGroupIds}}" , str);


    return query , status;
end


function getListProductTamin(year , month)
    local resultExp = {};


    local param = {
        query = teamyar.get_attachment("query_list_procut_tamin.txt") ,
        params = {year , month }
    }

    db.use_db("0000000_bot")
    db.query(param)
    local record = {}
    while db.query_fetch(record) do
        table.insert(resultExp, {
            id =record[1],
            product_id =record[2],
            product_manufactured =record[3],
            product_active =record[4],
            description =record[5],
            center_value =record[6],
            center_after_edit_value =record[7],
            center_sazemani_value =record[8],
            center_sazemani_after_edit_value =record[9],
            after_edit_target =record[10],
            year =record[11],
            month =record[12]
        })
    end
    db.use_db("0000000")

    return resultExp;
end
function readyListWithProductTamin(listProduct , listProductTamin)

    local resultExp = {};

    for x = 1 , #listProductTamin , 1 do
        local itemProductTamin = listProductTamin[x];

        for i = 1 , #listProduct , 1 do
            local itemProduct = listProduct[i];

            if itemProduct.product_id == itemProductTamin.product_id then

                itemProduct.id = itemProductTamin.id

                itemProduct.description = itemProductTamin.description

                local product_manufactured = _CONST_PRODUCT_MANUFACTORED._N
                if itemProductTamin.product_manufactured == 1 then
                    product_manufactured = _CONST_PRODUCT_MANUFACTORED._Y
                elseif itemProductTamin.product_manufactured == 2 then
                    product_manufactured = _CONST_PRODUCT_MANUFACTORED._P
                elseif itemProductTamin.product_manufactured == 3 then
                    product_manufactured = _CONST_PRODUCT_MANUFACTORED._M
                end
                itemProduct.product_manufactured = product_manufactured


                local product_active = _CONST_PRODUCT_ACTIVE._NO
                if itemProductTamin.product_active == 1 then
                    product_active = _CONST_PRODUCT_ACTIVE._YES
                end
                itemProduct.product_active = product_active


                if all == true then
                    itemProduct.center_first = itemProductTamin.center_sazemani_value
                    itemProduct.center_value = itemProductTamin.center_sazemani_after_edit_value
                else
                    itemProduct.center_first = itemProductTamin.center_value
                    itemProduct.center_value = itemProductTamin.center_after_edit_value
                end
                itemProduct.center_total = itemProductTamin.after_edit_target


                itemProduct.year = itemProductTamin.year
                itemProduct.month = itemProductTamin.month

                table.insert(resultExp , itemProduct);
                break;
            end
        end

    end

    return resultExp;
end

function readyListWithAgents(listProduct)
    local listRecords = selectData();

    for i = 1 , #listProduct , 1 do
        local itemProduct = listProduct[i];
        if itemProduct ~= nil and itemProduct.id ~= nil then
            for x= 1 , #listRecords , 1 do
                local itemRecord = listRecords[x];



                if itemRecord ~= nil and itemRecord.target_id~= nil and itemRecord.target_id == itemProduct.id and
                        itemRecord.agent_id ~= nil and itemRecord.agent_value ~= nil and itemRecord.agent_percent ~= nil  then

                    teamyar.write_log(json.encode(itemRecord));
                    table.insert(listProduct[i].agents , {
                        id = itemRecord.agent_id ,
                        value = itemRecord.agent_value ,
                        percent = itemRecord.agent_percent
                    })
                end

            end
        end
    end

    return listProduct;
end





function getListAgents()
    local resultExp = {};
    local param = {
        query = teamyar.get_attachment("query_get_list_agent.txt") ,
        params = {accessGroupId  }
    }
    db.use_db("0000000_bot")
    db.query(param)
    local record = {}
    while db.query_fetch(record) do
        table.insert(resultExp, {
            id =record[1],
            ref_id =record[2],
            ref_name =record[3],
            group_id =record[4],
            percent =record[5]

        })
    end
    db.use_db("0000000")
    return resultExp;
end



----------------------------------
function checkAccessClient(listAgents)
    local accessFull = false;
    local accessDownload = false;

    local user = teamyar.get_user_info();
    if user.id ~= nil then
        local userId = user.id

        local accessData = teamyar.get_attachment("Agents.json");
        accessData = json.decode(accessData);
        if accessData ~= nil and type(accessData) == "table" then

            for i = 1 , #accessData , 1 do
                local itemAccess = accessData[i];

                if ( (all==false and itemAccess.groupId ~= nil and itemAccess.groupId == accessGroupId) or (all == true and itemAccess.all ~= nil and itemAccess.all==true) ) then

                    if itemAccess.agents_full ~= nil and type(itemAccess.agents_full ) == "table"  then
                        local listAccessFull = itemAccess.agents_full;
                        for x = 1 , #listAccessFull , 1 do
                            local itemAccessFull = listAccessFull[x];
                            if itemAccessFull ~= nil and type(itemAccessFull) == "number" and itemAccessFull == userId then
                                accessFull = true;
                                break;
                            end
                        end
                    end

                    if itemAccess.agents_download ~= nil and type(itemAccess.agents_download ) == "table"  then
                        local listAccessDownload = itemAccess.agents_download;
                        for y = 1 , #listAccessDownload , 1 do
                            local itemAccessDownload = listAccessDownload[y];
                            if itemAccessDownload ~= nil and type(itemAccessDownload) == "number" and itemAccessDownload == userId then
                                accessDownload = true;
                                break;
                            end
                        end
                    end

                    break;
                end
            end

        end

    end

    return accessFull , accessDownload;
end


----------------------------------

function readyStepOneListAgents(data)
    local listAgents = getListAgentsValidates();

    local listExp = {};
    local status=true;
    local msg = "";
    for i = 1 , #data , 1 do
        local itemData = data[i];
        local resData = perperationItemDataProduct(itemData , index+2 , listAgents);
        if resData~=nil then

        end
    end
end
function perperationItemDataProduct(itemData , index  ,   listAgents )
    local exp = nil;
    local status = false;
    local msg =  "پارامتر ورودی کالای ردیف" .. index .. "داده غلط وارد شده است .";
    if itemData.product_id ~= nil then
        local agents = perperationItemDataAgents(itemData , index  ,  listAgents);
        status = agents.status;
        msg = agents.msg;
        if exp ~= nil and status== true  then
            exp = {
                product_group_main_id = itemData.product_group_main_id ,
                product_group_id = itemData.product_group_id ,
                product_id = itemData.product_id ,
                month = itemData.month ,
                year = itemData.year ,
                agents = agents.exp
            };
        end
    end
    return exp , status , msg ,
end
function perperationItemDataAgents(itemData , index , listAgents)
    local expAgents = {};
    for key, value in pairs(itemData) do
        if string.match(key, "agent_percent_") then
            local agentArray =  explodeToArray(key , "_");
            local result = {
                ref_id = ref_id ,
                ref_name = ref_name ,
                type = type ,
                group_id = tonumber(group[3]) ,
                percent = value
            };
            table.insert(dataExp , result)
        end
    end
    return expAgents = {};
end
function checkG



function getListAgentsValidates()
    local resultExp = {};
    local param = {
        query = teamyar.get_attachment("query_get_list_agents_in_group.txt") ,
        params = {accessGroupId}
    }
    db.use_db("0000000_bot")
    db.query(param)
    local record = {}
    while db.query_fetch(record) do
        table.insert(resultExp, {
            ref_id =record[1]
        })
    end
    db.use_db("0000000")
    return resultExp;
end



function explodeToArray (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end



----------------------------------
local params = teamyar.get_input();
local method = params.method;


if params.groupId ~= nil then
    accessGroupId = params.groupId;
end
local accessFull , accessDownload = checkAccessClient();

if method == "" or method == nil then
    local template = teamyar.get_attachment("template.html")
    template = string.gsub(template , "{{accessFull}}" , tostring(accessFull));
    template = string.gsub(template , "{{accessDownload}}" , tostring(accessDownload));
    teamyar.write_result(template)
elseif method == "get" and params.year~=nil and params.month~=nil and ( (accessFull or accessDownload)) then
    local listProduct = readyListProduct(params.year , params.month);
    teamyar.write_result(json.encode(listProduct))
elseif method == "insert" then
    local response = {
        msg = "مشکلی در انجام عملیات رخ داده است." ,
        status = false
    }
    if params.__data__ ~= nil and accessFull  then
        local jsonData = params.__data__;
        --local jsonData = json.decode(params.__data__);
        teamyar.write_log(json.encode(jsonData))
        --executeData(jsonData);
        response.msg = "عملیات با موفقیت انجام شد.";
        response.status = true;
    end
    teamyar.write_result(json.encode(response))
end








