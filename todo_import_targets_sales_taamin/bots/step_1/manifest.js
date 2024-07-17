let urlRequest ="/bot/run/332/supply_unit_product_attr" , defaultFileName = "وضعیت  کالاها - تامین" ,isFormula=false;

function setListDataExcel(exp){
    const keys = [
        "product_id",
        "full_code",
        "product_name",
        "product_manufactured",
        "product_active",
        "product_active_system",
        "product_total"
    ];


    const headers = {
        "product_id": "شناسه کالا",
        "full_code": "فول کد کالا",
        "product_name": "نام کالا",
        "product_manufactured": "وضعیت تولید کالا",
        "product_active": "وضعیت کالا" ,
        "product_active_system": "وضعیت سیستمی کالا" ,
        "product_total": "موجودی کالا" ,
    }


    const excel = [];
    for (let i = 0; i < exp.length; i++) {
        const item = exp[i];
        excel.push({
            "product_id": item["product_id"],
            "full_code": item["full_code"],
            "product_name": item["product_name"],
            "product_manufactured": item["product_manufactured"],
            "product_active": item["product_active"] ,
            "product_active_system": parseInt(item["active"]) == 1 ? "✔" : "✘" ,
            "product_total": item["total"] ,
        })
    }

    return {keys , headers , excel}
}


function getDefaultFileName(){
    return defaultFileName;
}
function getUrlRequestGet(){
    return urlRequest+"?method=get";
}
function getUrlRequestInsert(){
    return urlRequest+"?method=insert";
}
function getIsFormula(){
    return isFormula;
}
