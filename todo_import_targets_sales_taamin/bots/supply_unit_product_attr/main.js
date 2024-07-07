

$.Teamyar.layout({
    type:'COL-1',
    class_name: 'w-75 mx-auto px-0 pb-2 rounded  bg-white' ,
    id: "tester",
    selector: "#test_controller",
    controls: [

        $.Teamyar.layout({
            type:'COL-1',
            class_name: ' mx-0 mt-2 px-4 pb-2 border-bottom' ,
            controls: [
                "<p>برای دریافت فایل اکسل روی دکمه زیر کلیک کنید.</p>",
                $.Teamyar.layout({
                    type:'COL-3',
                    class_name: '' ,
                    controls: [

                        $.Teamyar.input.text({
                            name:'file_name',
                            id:'file_name',
                            title:'نام فایل',
                            value:getDefaultFileName(),
                            }),

                        $.Teamyar.button({
                            title: "دانلود ",
                            type: 'button' ,
                            events:{ "onclick": [ "ty__main.downloadFileExcel" ]}
                        })

                    ]
                })
            ]
        }),

        $.Teamyar.layout({
            type:'COL-1',
            class_name: ' mx-0 mt-2 px-4 pb-2' ,
            controls: [

                "<p>برای آپلود فایل اکسل روی دکمه زیر کلیک کنید.</p>",

                $.Teamyar.layout({
                    type:'COL-3',
                    class_name: '' ,
                    controls: [

                        $.Teamyar.input.file({ name:'file', title:'file' , id:"file_excel"}),

                        $.Teamyar.button({
                            title: "آپلود ",
                            type: 'button' ,
                            events:{ "onclick": [ "ty__main.uploadFileExcel" ]}
                        })

                    ]
                })

            ]
        })

    ]
});


//---------------------------

ty__main.downloadFileExcel = function (){
    $.Teamyar.ajax({
            options: {
                url: getUrlRequestGet() ,
                type: 'GET',
                dataType:"json"
            },
            events:{success:['ty__main.successGetDataProduct']},
            block_holder:'body'
        })
}

ty__main.successGetDataProduct = function (p1 , p2){
    if (p2.hasOwnProperty("response")) {
        const exp = p2.response;
        const dataExp = setListDataExcel(exp);
        const keys = dataExp["keys"];
        const headers = dataExp["headers"];
        const excel = dataExp["excel"];
        let data = [headers];
        data = data.concat(excel);

        const fileName = $.trim($("#file_name").val());

        const isFormula = getIsFormula();
        if (isFormula){
            convertToExcelFormula(keys, data, fileName+".xlsx");
        }
        else{
            convertToExcel(keys, data, fileName+".xlsx");
        }

    }
}



//---------------------------


ty__main.uploadFileExcel = function (){

    const file = $('#file_excel')[0].files[0];

    convertExcelToJson(file ,
        (json) => {

        // remove fa titles
        if (json != null && json.length > 0){
            const dataJson = [];
            for (let i=0; i<json.length; i++){
                const item = json[i];
                if (i >0){
                    dataJson.push(item);
                }
            }
            requestInsertData({__data__: dataJson , method: "insert"} , getUrlRequestInsert());
        }
    });
}

function requestInsertData(json , url ) {

    fetchData(url , json )
        .then((result) => {
            $.Teamyar.confirm({
                message: "عملیات با موفقیت انجام شد"
            });
    });

}





