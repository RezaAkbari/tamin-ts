let urlRequest ="/bot/run/332/supply_unit_product_centers" , defaultFileName = "لیست درصد مراکز فروش" ,isFormula=false;

function setListDataExcel(exp){

    let keys = ["ref_id", "ref_name", "type"];

    let headers = {
        "ref_id": "شناسه عامل فروش/مرکز",
        "ref_name": "نام عامل فروش/مرکز",
        "type": "نام عامل فروش/مرکز",
    }

    const excel = [];
    const sums = [];

    if (exp.hasOwnProperty("listGroups") && exp.hasOwnProperty("listGroups")){
        const listExp = exp.listExp;
        const listGroups = exp.listGroups;

        for (let i = 0; i < listGroups.length; i++) {
            const itemId = + listGroups[i]["id"];
            keys.push("group_name_"+ itemId);
            keys.push("group_percent_"+ itemId);

            sums.push("group_percent_"+ itemId);

            headers["group_name_"+ itemId ] = "نام گروه "+ itemId;
            headers["group_percent_" + itemId ] = "درصد گروه "+ itemId;
        }


        for (let i = 0; i < listExp.length; i++) {
            const item = listExp[i];
            const refId = parseInt(item["ref_id"]);

            let exist = false;
            for (let x = 0; x < excel.length; x++) {
                if (excel[x].ref_id ===  refId){
                    exist = true;
                    break;
                }
            }

            if (!exist){
                let itemExcel = {
                    "ref_id":refId,
                    "ref_name": item["ref_name"],
                    "type": item["type"],
                };

                excel.push(itemExcel)
            }

        }


        for (let i = 0; i < excel.length; i++) {
            const item = excel[i];

            for (let x = 0; x < listGroups.length; x++) {
                const itemGroup = listGroups[x];
                excel[i]["group_name_"+ itemGroup.id] = itemGroup.title;
                excel[i]["group_percent_"+ itemGroup.id] = 0;


                for (let y = 0; y < listExp.length; y++) {
                    const itemExp = listExp[y];
                    if ( item.hasOwnProperty("ref_id") && item.hasOwnProperty("type") && itemGroup.hasOwnProperty("id") &&
                        itemExp.hasOwnProperty("ref_id") && itemExp.hasOwnProperty("type") && itemExp.hasOwnProperty("group_id") && itemExp.hasOwnProperty("percent") &&
                        item.ref_id ===  itemExp.ref_id && item.type ===  itemExp.type && itemGroup.id ===  itemExp.group_id  ){

                        excel[i]["group_percent_"+ itemGroup.id] = itemExp.percent;
                        break;
                    }
                }
            }

        }
    }

    return {keys , headers , excel , sums}
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


