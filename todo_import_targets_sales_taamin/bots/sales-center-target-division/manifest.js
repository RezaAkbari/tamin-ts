let urlRequest ="/bot/run/332/sales_final_target_status" , defaultFileName = "تارگت اصلاحیه نهایی" ,isFormula=false;

function setListDataExcel(exp){

    const year = getYearShamsi();
    const month = getMonthShamsi();

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
        "center_value" : "center_value" ,
        "center_percent" : "center_percent" ,
        "center_after_edit_value_offer" : "center_after_edit_value_offer" ,
        "center_after_edit_value" : "center_after_edit_value" ,

        "center_sazemani_name" : "center_sazemani_name" ,
        "center_sazemani_value" : "center_sazemani_value" ,
        "center_sazemani_percent" : "center_sazemani_percent" ,
        "center_sazemani_after_edit_value_offer" : "center_sazemani_after_edit_value_offer" ,
        "center_sazemani_after_edit_value" : "center_sazemani_after_edit_value",

        "first_target" : "first_target",
        "after_edit_target" : "after_edit_target",

        "left_over_after_edit_target" : "left_over_after_edit_target" ,

        "year" : "year",
        "month" : "month"

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
        "center_value" : "تارگت مرکز فروش" ,
        "center_percent" : "درصد مرکز فروش" ,
        "center_after_edit_value_offer" : "پیشنهاد اصلاحیه مرکز فروش" ,
        "center_after_edit_value" : "تارگت اصلاحیه مرکز فروش" ,

        "center_sazemani_name" : "واحد سازمانی" ,
        "center_sazemani_value" : "تارگت واحد سازمانی" ,
        "center_sazemani_percent" : "درصد سازمانی" ,
        "center_sazemani_after_edit_value_offer" : "پیشنهاد تارگت اصلاحیه واحد سازمانی" ,
        "center_sazemani_after_edit_value" : "تارگت اصلاحیه واحد سازمانی" ,

        "first_target" : "مجموع تارگت اولیه",
        "after_edit_target" : "مجموع تارگت اصلاحیه",
        "left_over_after_edit_target" : "باقی مانده تارگت اصلاحیه" ,

        "year" : "سال",
        "month" : "ماه"
    }




    const excel = [];
    for (let i = 0; i < exp.length; i++) {
        const item = exp[i];
        const itemIndex = (i+3).toString();
        excel.push({
            "product_group_main_id": {
                t: "s" ,
                v: item["product_group_main_id"],
                s: {
                    font: {
                        name: '宋体',
                        sz: 24,
                        bold: true,
                        color: { rgb: "FFFFAA00" }
                    },
                },
                protection: {
                    locked: true // قفل کردن سلول
                }
            }, // a
            "product_group_main_name": item["product_group_main_name"],  // b

            "product_group_id": item["product_group_id"], //c
            "product_group_name": item["product_group_name"], //d

            "product_id": item["product_id"],  // e
            "product_name": item["product_name"], //f
            "product_full_code": item["product_full_code"],//g

            "product_manufactured": item["product_manufactured"],//h
            "product_active": item["product_active"],//i
            "description": item["description"],//j


            "center_name": item["center_name"],//k
            "center_value": item["center_value"],//l
            "center_percent":   { t: "n", f:  "=ROUND(((L"+itemIndex+"/U"+itemIndex+")*100), 2)"  }    ,//m   =ROUND(((H18/T18)*100), 2)
            "center_after_edit_value_offer": { t: "n", f:  "=ROUNDDOWN((m"+itemIndex+"*v"+itemIndex+")/100, 0)" },//n  =ROUNDDOWN((I2*U2)/100, 0)
            "center_after_edit_value": item["center_after_edit_value"],//o


            "center_sazemani_name": item["center_sazemani_name"], //p
            "center_sazemani_value": item["center_sazemani_value"], //q
            "center_sazemani_percent" : { t: "n", f:  "=ROUND(((Q"+itemIndex+"/U"+itemIndex+")*100), 2)"  }  , //r     =ROUND(((H18/T18)*100), 2)
            "center_sazemani_after_edit_value_offer": { t: "n", f:  "=ROUNDUP((R"+itemIndex+"*V"+itemIndex+")/100, 0)" } , //s  =ROUNDUP((I2*U2)/100, 0)
            "center_sazemani_after_edit_value": item["center_sazemani_after_edit_value"] ,//t


            "first_target": { t: "n", f:  "SUM(L"+itemIndex+"+Q"+itemIndex+")" },//u
            "after_edit_target": item["after_edit_target"], //v
            "left_over_after_edit_target": { t: "n", f:  "=V"+itemIndex+"-T"+itemIndex+"-O"+itemIndex  }  , //w     =V3-T3-O3


            "year" : item["year"] == null ? year : item["year"],//x
            "month" : item["month"] == null ? month : item["month"],//y
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


