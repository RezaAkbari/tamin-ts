
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

local _tableName = "supply_unit_product_result_targets";

function createTable()
    db.use_db("0000000_bot")
    local params = {
        name = _tableName,
        fields =" id BIGINT NOT NULL AUTO_INCREMENT ,product_id bigint not null ,product_manufactured int default(1)  not null ,product_active int default(0)  not null ,description text null ,center_value bigint default(0) not null ,center_after_edit_value bigint default(0) not null ,center_sazemani_value bigint default(0) not null ,center_sazemani_after_edit_value bigint default(0) not null ,after_edit_target bigint default(0) not null ,year bigint not null ,month  bigint not null",

        index_items = {{1, "primary", "id"}}
    };
    db.check_table(params);
    db.use_db("0000000");
end

function selectData(year , month )
    createTable()


    db.use_db("0000000_bot")
    local param = {
        query = "SELECT id , product_id , product_manufactured , product_active , description , center_value , center_after_edit_value , center_sazemani_value , center_sazemani_after_edit_value , after_edit_target, year, month FROM " .. _tableName .. " where year=? and month=? ",
        params = {year , month  }
    }
    local result = {}
    db.query(param)
    local record = {}
    while db.query_fetch(record) do
        table.insert(result, {
            id = record[1],
            product_id = record[2],
            product_manufactured = record[3],
            product_active = record[4],
            description = record[5],
            center_value = record[6],
            center_after_edit_value = record[7],
            center_sazemani_value = record[8],
            center_sazemani_after_edit_value = record[9],
            after_edit_target = record[10],
            year = record[11],
            month = record[12]
        })
    end
    db.query_free()
    db.use_db("0000000");
    return result;
end


function executeData(listData)

    for i = 1 , #listData , 1 do
        local itemData = listData[i];

        if  itemData.product_id ~= nil and itemData.product_manufactured ~= nil and itemData.product_active ~= nil and itemData.description ~= nil and itemData.center_value ~= nil and itemData.center_after_edit_value ~= nil and itemData.center_sazemani_value ~= nil and itemData.center_sazemani_after_edit_value ~= nil and itemData.after_edit_target ~= nil and itemData.year ~= nil and itemData.month ~= nil then
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

            local year = tonumber(itemData.year);
            local month = tonumber(itemData.month);

            local checkExist = checkExistRow( itemData.product_id,  year ,  month  );
            if checkExist== true then
                updateData(itemData.product_id ,product_manufactured ,product_active ,itemData.description ,itemData.center_value ,itemData.center_after_edit_value ,itemData.center_sazemani_value ,itemData.center_sazemani_after_edit_value ,itemData.after_edit_target , year, month  );
            else
                insertData(itemData.product_id ,product_manufactured ,product_active ,itemData.description ,itemData.center_value ,itemData.center_after_edit_value ,itemData.center_sazemani_value ,itemData.center_sazemani_after_edit_value ,itemData.after_edit_target , year , month  );
            end
        end
    end
end



function checkExistRow(product_id , year , month )
    createTable()
    db.use_db("0000000_bot")
    local param = {
        query = "SELECT id FROM " .. _tableName .. " where product_id=? and year=? and month=?",
        params = {product_id , year , month  }
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


function insertData(product_id , product_manufactured , product_active , description , center_value , center_after_edit_value , center_sazemani_value , center_sazemani_after_edit_value ,after_edit_target ,year ,month )
    createTable();
    db.start();
    db.use_db("0000000_bot")
    local params = {
        query = "insert into " .. _tableName .. " (product_id , product_manufactured , product_active , description , center_value , center_after_edit_value , center_sazemani_value , center_sazemani_after_edit_value ,after_edit_target ,year ,month  ) values (?,?,?,?,?,?,?,?,?,?,?)",
        params = {product_id , product_manufactured , product_active , description , center_value , center_after_edit_value , center_sazemani_value , center_sazemani_after_edit_value ,after_edit_target  ,year ,month }
    };
    db.query_immediate(params)
    db.commit();
    db.use_db("0000000");
end

function updateData( product_id , product_manufactured , product_active , description , center_value , center_after_edit_value , center_sazemani_value , center_sazemani_after_edit_value ,after_edit_target ,year ,month )
    createTable();
    db.start();
    db.use_db("0000000_bot")
    local params = {
        query = "update " .. _tableName .. " set  product_manufactured=? , product_active=? , description=? , center_value=? , center_after_edit_value=? , center_sazemani_value=? , center_sazemani_after_edit_value=? ,after_edit_target=?  where  product_id=? and year=? and month=? ",
        params = {product_manufactured , product_active , description , center_value , center_after_edit_value , center_sazemani_value , center_sazemani_after_edit_value ,after_edit_target , product_id , year , month  }
    };
    db.query_immediate(params)
    db.commit();
    db.use_db("0000000");
end

--function deleteData(id , product_id)
--    createTable();
--    db.start();
--    db.use_db("0000000_bot")
--    local params = {
--        query = "delete from " .. _tableName .. " where id=? and product_id=?",
--        params = {id , product_id }
--    };
--    db.query_immediate(params)
--    db.commit();
--    db.use_db("0000000");
--end
----------------------------------
function readyListProduct(year , month  )
    createTable();
    local listProduct = getProducts();
    listProduct = readyListProductWithAttr(listProduct);

    listProduct = readylistTaminProduct(listProduct , year , month  );

    return listProduct;
end


function getProducts()
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
            product_group_main_id = record[1],
            product_group_main_name = record[2],

            product_group_id = record[3],
            product_group_name = record[4],

            product_id = record[5],
            product_name  = record[6],
            product_full_code = record[7],

            product_manufactured = _CONST_PRODUCT_MANUFACTORED._N,
            product_active = _CONST_PRODUCT_ACTIVE._YES ,

            description = "",

            center_name =  record[8],
            center_value = 0,
            center_after_edit_value = 0,

            center_sazemani_name = "سازمانی",
            center_sazemani_value = 0,
            center_sazemani_after_edit_value = 0,

            after_edit_target = 0,

            year= nil,
            month= nil
        })
    end
    db.query_free()
    return listExp;
end


function getProductAttrs()
    local listExp = {};
    local query = teamyar.get_attachment("query_get_list_supply_unit_product_attrs.txt");
    db.use_db("0000000_bot")
    local param = {
        query = query ,
        param = {}
    }
    db.query(param)
    local record = {}
    while db.query_fetch(record) do
        table.insert(listExp, {
            product_id  = record[1],
            product_manufactured = record[2],
            product_active = record[3],
        })
    end
    db.query_free()
    db.use_db("0000000")
    return listExp;
end
function readyListProductWithAttr(listProduct)
    local listProductAttr = getProductAttrs();

    local listExp = {};
    if listProduct ~= nil then
        for i = 1 , #listProduct , 1 do
            local itemProduct = listProduct[i];

            local exist = false;
            for x = 1 , #listProductAttr , 1 do
                local itemProductAttr = listProductAttr[x];

                if itemProduct.product_id ~= nil and itemProductAttr.product_id ~= nil and tonumber( itemProduct.product_id ) == tonumber(itemProductAttr.product_id) and
                        itemProductAttr.product_manufactured ~= nil and
                        itemProductAttr.product_active ~= nil then
                    exist = true;
                    if itemProductAttr.product_active == _CONST_PRODUCT_ACTIVE._YES or itemProductAttr.product_active == 1 then
                        local product_manufactured = _CONST_PRODUCT_MANUFACTORED._N
                        if itemProductAttr.product_manufactured == 1 then
                            product_manufactured = _CONST_PRODUCT_MANUFACTORED._Y
                        elseif itemProductAttr.product_manufactured == 2 then
                            product_manufactured = _CONST_PRODUCT_MANUFACTORED._P
                        elseif itemProductAttr.product_manufactured == 3 then
                            product_manufactured = _CONST_PRODUCT_MANUFACTORED._M
                        end
                        itemProduct.product_manufactured = product_manufactured

                        table.insert(listExp , itemProduct);
                    end
                    break;
                end
            end

            if exist == false then
                table.insert(listExp , itemProduct);
            end

        end
    end

    return listExp;
end


function readylistTaminProduct(listProduct , year , month  )
    local listTaminProduct = selectData(year , month  );
    teamyar.write_log(json.encode(listTaminProduct))

    if listProduct ~= nil then
        for i = 1 , #listProduct , 1 do
            local itemProduct = listProduct[i];

            for x = 1 , #listTaminProduct , 1 do
                local itemProductAttr = listTaminProduct[x];

                if itemProduct.product_id ~= nil and itemProductAttr.product_id ~= nil and tonumber( itemProduct.product_id ) == tonumber(itemProductAttr.product_id)  then

                    if itemProductAttr.product_manufactured ~= nil then
                        local product_manufactured = _CONST_PRODUCT_MANUFACTORED._N
                        if itemProductAttr.product_manufactured == 1 then
                            product_manufactured = _CONST_PRODUCT_MANUFACTORED._Y
                        elseif itemProductAttr.product_manufactured == 2 then
                            product_manufactured = _CONST_PRODUCT_MANUFACTORED._P
                        elseif itemProductAttr.product_manufactured == 3 then
                            product_manufactured = _CONST_PRODUCT_MANUFACTORED._M
                        end
                        listProduct[i]["product_manufactured"] = product_manufactured;
                    end

                    if itemProductAttr.product_active ~= nil then
                        local product_active = _CONST_PRODUCT_ACTIVE._NO
                        if itemProductAttr.product_active == 1 then
                            product_active = _CONST_PRODUCT_ACTIVE._YES
                        end
                        listProduct[i]["product_active"] = product_active
                    end

                    if itemProductAttr.description ~= nil then
                        listProduct[i]["description"] = itemProductAttr.description
                    end

                    if itemProductAttr.center_name ~= nil then
                        listProduct[i]["center_name"] = itemProductAttr.center_name
                    end
                    if itemProductAttr.center_value ~= nil then
                        listProduct[i]["center_value"] = itemProductAttr.center_value
                    end
                    if itemProductAttr.center_after_edit_value ~= nil then
                        listProduct[i]["center_after_edit_value"] = itemProductAttr.center_after_edit_value
                    end

                    if itemProductAttr.center_sazemani_value ~= nil then
                        listProduct[i]["center_sazemani_value"] = itemProductAttr.center_sazemani_value
                    end
                    if itemProductAttr.center_sazemani_after_edit_value ~= nil then
                        listProduct[i]["center_sazemani_after_edit_value"] = itemProductAttr.center_sazemani_after_edit_value
                    end

                    if itemProductAttr.after_edit_target ~= nil then
                        listProduct[i]["after_edit_target"] = itemProductAttr.after_edit_target
                    end

                    break;
                end
            end
        end
    end

    return listProduct;
end

----------------------------------
local params = teamyar.get_input();
local method = params.method;


if method == "" or method == nil then
    local template = teamyar.get_attachment("template.html")
    teamyar.write_result(template)
elseif method == "get" and params.year~=nil and params.month~=nil then
    local listProduct = readyListProduct(params.year , params.month);
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





