let urlRequest ="/bot/run/332/sales_accept_final_target_status" , defaultFileName = "نتیجه تارگت نهایی" ,isFormula=false;

function setListDataExcel(exp){

    const year = getYearShamsi();
    const month = getMonthShamsi();
    const day = getDayShamsi();

    const keys = {
        "product_group_main_id": "product_group_main_id",
        "product_group_main_name": "product_group_main_name",

        "product_group_id": "product_group_id",
        "product_group_name": "product_group_name",

        "product_id": "product_id",
        "product_name": "product_name",
        "product_full_code": "product_full_code",

        "product_manufactured": "product_manufactured" ,
        "product_active": "product_active" ,

        "description" : "description" ,

        "center_name" : "center_name" ,
        "center_first" : "center_first" ,
        "center_value" : "center_value" ,
        "center_total" : "center_total" ,


        "year" : "year",
        "month" : "month",
        "day" : "day",

    };


    const headers = {
        "product_group_main_id": "شناسه گروه اصلی",
        "product_group_main_name": "نام گروه اصلی",

        "product_group_id": "شناسه گروه",
        "product_group_name": "نام گروه",

        "product_id": "شناسه کالا",
        "product_name": "نام کالا",
        "product_full_code": "کد 3 کالا",

        "product_manufactured": "وضعیت تولید کالا" ,
        "product_active": "وضعیت کالا" ,
        "description" : "توضیحات" ,


        "center_name" : "نام مرکز فروش" ,
        "center_first" : "تارگت اولیه" ,
        "center_value" : "تارگت اصلاحیه" ,
        "center_total" : "مجموع تارگت اصلاحیه" ,


        "year" : "سال",
        "month" : "ماه",
        "day" : "روز",
    }




    const excel = [];
    for (let i = 0; i < exp.length; i++) {
        const item = exp[i];
        const itemIndex = (i+3).toString();
        excel.push({
            "product_group_main_id":  parseInt(item["product_group_main_id"]) , // a
            "product_group_main_name": item["product_group_main_name"]  ,  // b

            "product_group_id": item["product_group_id"], //c
            "product_group_name": item["product_group_name"], //d

            "product_id": item["product_id"],  // e
            "product_name": item["product_name"], //f
            "product_full_code": item["product_full_code"],//g

            "product_manufactured": item["product_manufactured"],//h
            "product_active": item["product_active"],//i
            "description": item["description"],//j


            "center_name": item["center_name"],//k
            "center_first": item["center_first"],//l
            "center_value": item["center_value"],//m
            "center_total": item["center_total"],//n


            "year" : item["year"] == null ? year : item["year"],//o
            "month" : item["month"] == null ? month : item["month"],//p
            "day" : item["day"] == null ? day : item["day"],//q
        })
    }

    return {keys , headers , excel}
}
//{ t: "n", f:  "SUM(H"+(i+2).toString()+"+J"+(i+2).toString()+")" },

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


