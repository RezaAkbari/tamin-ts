
local _CONST_TYPE_CENTER = {
    _AGENT = 0 ,
    _CENTER = 1
}

------------
local _tableName = "supply_unit_product_centers_percent";

function createTable()
    db.use_db("0000000_bot")
    local params = {
        name = _tableName,
        fields = " id BIGINT NOT NULL AUTO_INCREMENT ,ref_id bigint not null ,group_id bigint not null , percent int not null , type int default(0)  not null  ",
        index_items = {{1, "primary", "id"}}
    };
    db.check_table(params);
    db.use_db("0000000");
end

function selectData()
    createTable()
    db.use_db("0000000_bot")
    local param = {
        query = "SELECT id , ref_id , percent ,group_id,  type FROM " .. _tableName,
        params = {}
    }
    local result = {}
    db.query(param)
    local record = {}
    while db.query_fetch(record) do
        table.insert(result, {
            id = record[1],
            ref_id = record[2],
            percent = record[3],
            group_id = record[4],
            type = record[5],
        })
    end
    db.query_free()
    db.use_db("0000000");
    return result;
end


function executeData(listData)
    local listAgents = getListAgents();
    local listGroups = getListGroups();
    local listCenters = getListCenters();
    for i = 1 , #listData , 1 do
        local itemData = listData[i];

        --teamyar.write_log(json.encode(itemData))
        --teamyar.write_log(json.encode(checkExistData(listGroups ,  itemData.group_id)))
        --teamyar.write_log(json.encode(checkExistData(listAgents ,  itemData.ref_id)))
        --teamyar.write_log(json.encode(checkExistData(listCenters ,  itemData.ref_id)))

        if itemData.ref_id ~= nil and  itemData.percent ~= nil and  itemData.group_id ~= nil and  itemData.type ~= nil and
                checkExistData(listGroups ,  itemData.group_id) and
                ((itemData.type == _CONST_TYPE_CENTER._AGENT and checkExistData(listAgents ,  itemData.ref_id)) or (itemData.type == _CONST_TYPE_CENTER._CENTER and checkExistData(listCenters ,  itemData.ref_id)))then

            local checkExist = checkExistRow( itemData.ref_id,itemData.group_id, itemData.type );
            if checkExist== true then
                updateData(itemData.ref_id ,itemData.percent ,itemData.group_id ,itemData.type );
            else
                insertData(itemData.ref_id ,itemData.percent ,itemData.group_id ,itemData.type );
            end
        end
    end
end

function checkExistRow(ref_id ,group_id, type )
    createTable()
    db.use_db("0000000_bot")
    local param = {
        query = "SELECT id FROM " .. _tableName .. " where ref_id=? and group_id=? and type=?",
        params = {ref_id ,group_id ,  type  }
    }
    local result = {}
    db.query(param)
    local record = {}
    local result = db.query_fetch();
    db.query_free()
    db.use_db("0000000");

    if result ~= nil and result[1] ~= nil then
        return true
    end
    return false;
end

function insertData(ref_id , percent ,group_id ,  type)
    createTable();
    db.start();
    db.use_db("0000000_bot")
    local params = {
        query = "insert into " .. _tableName .. " (ref_id,percent ,group_id, type) values (?,?,?,?)",
        params = {ref_id, percent,group_id, type}
    };
    db.query_immediate(params)
    db.commit();
    db.use_db("0000000");
end

function updateData(ref_id , percent ,group_id, type )
    createTable();
    db.start();
    db.use_db("0000000_bot")
    local params = {
        query = "update " .. _tableName .. " set  percent=? where ref_id=? and group_id=? and type=?  ",
        params = { percent , ref_id ,group_id, type }
    };
    db.query_immediate(params)
    db.commit();
    db.use_db("0000000");
end

----------------------------------
function getListDataJson(file)
    local data = teamyar.get_attachment(file);
    data = json.decode(data);
    return data;
end

function checkExistData(list , dataId)
    for i = 1 , #list , 1 do
        local itemData = list[i];
        if itemData~=nil and itemData.id~=nil and itemData.id == dataId then
            return true;
        end
    end
    return false;
end

function getListAgents()
    return getListDataJson("Agents.json");
end

function getListGroups()
    return getListDataJson("groups.json");
end

function getListCenters()
    return getListDataJson("sales_center.json");
end



----------------------------------
function readyListProduct()
    createTable();
    local listExp = readyListCenters();
    listExp = readyListDataFromDataBase(listExp);

    return {
        listExp = listExp ,
        listGroups = getListGroups()
    };
end

function readyListCenters()
    local listExp = {};

    local listAgents = getListAgents();
    local listCenters = getListCenters();
    for i = 1 , #listAgents , 1 do
        listExp = readyItemInListCenters(listExp , listAgents[i] ,_CONST_TYPE_CENTER._AGENT);
    end
    for i = 1 , #listCenters , 1 do
        listExp = readyItemInListCenters(listExp ,listCenters[i] ,_CONST_TYPE_CENTER._CENTER);
    end

    return listExp;
end
function readyItemInListCenters(listExp , itemData , type)
    local listGroups = getListGroups();
    for i = 1 , #listGroups , 1 do
        table.insert(listExp ,
                {
                    ref_id = itemData.id ,
                    ref_name = itemData.title ,
                    percent = 0,
                    group_id = listGroups[i].id ,
                    group_name = listGroups[i].title ,
                    type = type
                }
        );
    end
    return listExp;
end


function readyListDataFromDataBase(listExp)
    local listDataBase = selectData();

    for i = 1 , #listExp , 1 do
        local itemExp = listExp[i];
        for x = 1 , #listDataBase , 1 do
            local itemDataBase = listDataBase[x];
            if itemExp.ref_id ~= nil and  itemExp.group_id ~= nil and itemExp.type ~= nil  and
                    itemDataBase.ref_id ~= nil and itemDataBase.percent ~= nil and  itemDataBase.group_id ~= nil and itemDataBase.type ~= nil  and
                    itemDataBase.ref_id ~= itemExp.ref_id and itemDataBase.group_id ~= itemExp.group_id  and itemDataBase.type ~= itemDataBase.type  then

                listExp[i].percent = itemDataBase.percent;
                break;
            end
        end
    end
    return listExp;
end


----------------------------------
function readyGetData(data)
    local dataExp = {};
    for i = 1 , #data, 1 do
        local itemData = data[i];

        if itemData ~= nil and itemData.ref_id ~= nil and itemData.ref_id ~= "" and itemData.type ~= nil then
            local ref_id =  itemData.ref_id;
            local type =  itemData.type;

            for key, value in pairs(itemData) do
                if string.match(key, "group_percent_") then
                    local group =  explodeToArray(key , "_");
                    local result = {
                        ref_id = ref_id ,
                        type = type ,
                        group_id = tonumber(group[3]) ,
                        percent = value
                    };
                    teamyar.write_log(json.encode(result))
                    table.insert(dataExp , result)
                end
            end
        end
    end
    return dataExp;
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

if method == "" or method == nil then
    local template = teamyar.get_attachment("template.html")
    teamyar.write_result(template)
elseif method == "get" then
    local listProduct = readyListProduct();
    teamyar.write_result(json.encode(listProduct))
elseif method == "insert" then
    local response = {
        msg = "مشکلی در انجام عملیات رخ داده است." ,
        status = false
    }
    if params.__data__ ~= nil  then
        local jsonData = params.__data__;
        --local jsonData = json.decode(params.__data__);
        jsonData = readyGetData(jsonData)
        executeData(jsonData);
        response.msg = "عملیات با موفقیت انجام شد.";
        response.status = true;
    end
    teamyar.write_result(json.encode(response))
end

