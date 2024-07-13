let urlRequest ="/bot/run/332/sales_accept_final_target_status" , defaultFileName = "نتیجه تارگت نهایی" ,isFormula=false;

function setListDataExcel(exp){

    const year = getYearShamsi();
    const month = getMonthShamsi();
    const day = getDayShamsi();

    const keys = [
        "product_group_main_id", // a
        "product_group_main_name", // b

        "product_group_id", // c
        "product_group_name", // d

        "product_id", // e
        "product_name",  // f
        "product_full_code", // g

        "product_manufactured" , // h
        "product_active" ,  // i

        "description"  , // j

        "center_name"  , // k
        "center_first"  ,// l
        "center_value"  ,// m
        "center_total"  ,// n

        "year" ,// o
        "month" ,// p
        "day" ,// q
    ];

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
        "center_value" :  "تارگت اصلاحیه ",
        "center_total" : "مجموع تارگت اصلاحیه" ,

        "year" : "سال",
        "month" : "ماه",
        "day" : "روز",
    }

    const excel = [];
    const alphabetSizeFirst = keys.length-1;
    const alphabets = getAlphabet();

    if (exp.hasOwnProperty("list") && exp.hasOwnProperty("agents")){
        const list=  exp.list;
        const agents=  exp.agents;

        for (let i = 0; i < agents.length; i++) {
            const item = agents[i];
            const itemId = item["ref_id"];
            keys.push("agent_name_"+ itemId);
            keys.push("agent_percent_"+ itemId);
            keys.push("agent_offer_"+ itemId);
            keys.push("agent_value_"+ itemId);

            headers["agent_name_"+ itemId ] = "نام عامل  "+ itemId;
            headers["agent_percent_" + itemId ] = "درصد عامل  "+ itemId;
            headers["agent_offer_" + itemId ] = " پیشنها سهم عامل "+ itemId;
            headers["agent_value_" + itemId ] = "سهم عامل  "+ itemId;
        }


        keys.push("total_agent_percent");
        keys.push("total_agent_value");


        headers["total_agent_percent" ] ="مجموع درصد عاملین ";
        headers["total_agent_value" ] ="مجموع سهم عاملین";


        for (let i = 0; i < list.length; i++) {
            const item = list[i];
            const itemIndex = (i+3).toString();
            let resultRow = {
                "product_group_main_id": item["product_group_main_id"],
                "product_group_main_name": item["product_group_main_name"],

                "product_group_id": item["product_group_id"],
                "product_group_name":item["product_group_name"],

                "product_id":item["product_id"],
                "product_name":{
                    t: "s" ,
                    v: item["product_name"],
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
                },



                "product_full_code":item["product_full_code"],

                "product_manufactured":item["product_manufactured"],
                "product_active":item["product_active"],
                "description" :item["description"],

                "center_name" :item["center_name"],
                "center_first" :item["center_first"],
                "center_value" :item["center_value"],
                "center_total" :item["center_total"],

                "year" :item["year"],
                "month" :item["month"],
                "day" :item["day"],
            }
            let indexAlphabet = alphabetSizeFirst;
            let listSumPercent = [];
            let listSumValue = [];
            for (let x = 0; x < agents.length; x++) {
                const itemAgent = agents[x];
                let agentName = itemAgent.ref_name;
                let agentPercent = itemAgent.percent;
                let agentValue = Math.round((item["center_value"] * agentPercent) / 100);

                let agentSelected = null;
                if (item.hasOwnProperty("agents")){
                    const listAgentExist = item.agents;
                    for (let y=0; y < listAgentExist.length ; y++){
                        const itemExistAgent = listAgentExist[y];
                        if (itemExistAgent != null &&
                            itemExistAgent.hasOwnProperty("id") && itemExistAgent.hasOwnProperty("percent") && itemExistAgent.hasOwnProperty("value") &&
                            itemExistAgent.id === itemAgent.ref_id){
                            console.log(itemExistAgent)
                            agentSelected = itemExistAgent;
                        }
                    }
                }

                if (agentSelected != null){
                    agentPercent = agentSelected.percent;
                    agentValue = agentSelected.value;
                }

                resultRow["agent_name_"+ itemAgent.ref_id] =agentName;
                indexAlphabet ++;

                resultRow["agent_percent_"+ itemAgent.ref_id] =agentPercent;
                indexAlphabet ++;
                listSumPercent.push(alphabets[indexAlphabet]+itemIndex);

                resultRow["agent_offer_"+ itemAgent.ref_id] =  { t: "n", f:  "=ROUND((M"+itemIndex+"*"+alphabets[indexAlphabet]+itemIndex+") /100 , 0 )" };
                indexAlphabet ++;

                resultRow["agent_value_"+ itemAgent.ref_id] =  agentValue  ;
                indexAlphabet ++;
                listSumValue.push(alphabets[indexAlphabet]+itemIndex);


                /*for (let y = 0; y < listExp.length; y++) {
                    const itemExp = listExp[y];
                    if ( item.hasOwnProperty("ref_id") && item.hasOwnProperty("type") && itemGroup.hasOwnProperty("id") &&
                        itemExp.hasOwnProperty("ref_id") && itemExp.hasOwnProperty("type") && itemExp.hasOwnProperty("group_id") && itemExp.hasOwnProperty("percent") &&
                        item.ref_id ===  itemExp.ref_id && item.type ===  itemExp.type && itemGroup.id ===  itemExp.group_id  ){

                        excel[i]["group_percent_"+ itemGroup.id] = itemExp.percent;
                        break;
                    }
                }*/

            }


            let sumPercentFormula = "=";
            for (let x=0; x< listSumPercent.length; x++){
                const itemSum = listSumPercent[x];
                sumPercentFormula += itemSum;
                if (x < listSumPercent.length-1){
                    sumPercentFormula += "+";
                }
            }
            resultRow["total_agent_percent" ] = { t: "n", f:  sumPercentFormula};
            indexAlphabet ++;



            let sumValueFormula = "=";
            for (let x=0; x< listSumValue.length; x++){
                const itemSum = listSumValue[x];
                sumValueFormula += itemSum;
                if (x < listSumValue.length-1){
                    sumValueFormula += "+";
                }
            }
            resultRow["total_agent_value" ] = { t: "n", f:  sumValueFormula};
            indexAlphabet ++;




            excel.push(resultRow);

        }
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


