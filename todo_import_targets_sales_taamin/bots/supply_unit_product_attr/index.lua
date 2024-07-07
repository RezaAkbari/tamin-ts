
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

local _tableName = "supply_unit_product_attrs";

function createTable()
    db.use_db("0000000_bot")
    local params = {
        name = _tableName,
        fields = " id BIGINT NOT NULL AUTO_INCREMENT ,product_id bigint not null , product_manufactured int default(1)  not null , product_active int default(0)  not null  ",
        index_items = {{1, "primary", "id"}}
    };
    db.check_table(params);
    db.use_db("0000000");
end

function selectData()
    createTable()
    db.use_db("0000000_bot")
    local param = {
        query = "SELECT id , product_id , product_manufactured ,  product_active FROM " .. _tableName,
        params = {}
    }
    local result = {}
    db.query(param)
    local record = {}
    while db.query_fetch(record) do
        table.insert(result, {
            id = record[1],
            product_id = record[2],
            product_manufactured = record[3],
            product_active = record[4]
        })
    end
    db.query_free()
    db.use_db("0000000");
    return result;
end


function executeData(listData)
    emptyData();
    for i = 1 , #listData , 1 do
        local itemData = listData[i];
        if itemData.product_id ~= nil and  itemData.product_manufactured ~= nil and  itemData.product_active ~= nil then

            local product_active = 0
            if itemData.product_active == _CONST_PRODUCT_ACTIVE._YES then
                product_active = 1
            end

            local product_manufactured = 0
            if itemData.product_manufactured == _CONST_PRODUCT_MANUFACTORED._Y then
                product_manufactured = 1
            elseif itemData.product_manufactured == _CONST_PRODUCT_MANUFACTORED._P then
                product_manufactured = 2
            elseif itemData.product_manufactured == _CONST_PRODUCT_MANUFACTORED._M then
                product_manufactured = 3
            end


            insertData(itemData.product_id  , product_manufactured  , product_active );
        end
    end
end

function insertData(product_id , product_manufactured , product_active)
    createTable();
    db.start();
    db.use_db("0000000_bot")
    local params = {
        query = "insert into " .. _tableName .. " (product_id,product_manufactured , product_active) values (?,?,?)",
        params = {product_id, product_manufactured, product_active}
    };
    db.query_immediate(params)
    db.commit();
    db.use_db("0000000");
end

function emptyData()
    createTable();
    db.start();
    db.use_db("0000000_bot")
    local params = {
        query = "delete from " .. _tableName,
        params = {}
    };
    db.query_immediate(params)
    db.commit();
    db.use_db("0000000");
end
----------------------------------
function readyListProduct()
    createTable();
    local listProduct = getProduct();
    listProduct = getListStatusProduct(listProduct);
    return listProduct;
end


function getProduct()
    local listExp = {};

    local query = teamyar.get_attachment("query_get_product.txt");
    local param = {
        query = query ,
        param = {}
    }
    db.query(param)
    local record = {}
    while db.query_fetch(record) do
        table.insert(listExp, {

            product_id  = record[1],
            product_name = record[2],
            full_code  = record[3],
            product_manufactured = _CONST_PRODUCT_MANUFACTORED._N,
            product_active = _CONST_PRODUCT_ACTIVE._NO
        })
    end
    db.query_free()
    return listExp;
end
function getListStatusProduct(listExp)
    local listProductAttr = selectData();

    for i = 1 , #listExp , 1 do
        local itemProduct = listExp[i];

        for x = 1 , #listProductAttr , 1 do
            local itemProductAttr = listProductAttr[x];

            if itemProduct.product_id ~= nil and itemProductAttr.product_id ~= nil and tonumber( itemProduct.product_id ) == tonumber(itemProductAttr.product_id) and
                    itemProductAttr.product_manufactured ~= nil and
                    itemProductAttr.product_active ~= nil then

                local product_active = _CONST_PRODUCT_ACTIVE._NO
                if itemProductAttr.product_active == 1 then
                    product_active = _CONST_PRODUCT_ACTIVE._YES
                end
                listExp[i]["product_active"] = product_active

                local product_manufactured = _CONST_PRODUCT_MANUFACTORED._N
                if itemProductAttr.product_manufactured == 1 then
                    product_manufactured = _CONST_PRODUCT_MANUFACTORED._Y
                elseif itemProductAttr.product_manufactured == 2 then
                    product_manufactured = _CONST_PRODUCT_MANUFACTORED._P
                elseif itemProductAttr.product_manufactured == 3 then
                    product_manufactured = _CONST_PRODUCT_MANUFACTORED._M
                end
                    listExp[i]["product_manufactured"] = product_manufactured
            end
        end
    end

    return listExp;
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
        executeData(jsonData);
        response.msg = "عملیات با موفقیت انجام شد.";
        response.status = true;
    end
    teamyar.write_result(json.encode(response))
end
