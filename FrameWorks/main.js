let existError = false;
let templateDownload = "";
let templateUpload = "";
let templateError = "";
if (typeof accessDownload !== 'undefined' && typeof accessFull !== 'undefined' ){
    if (accessFull ){
        readyTemplateDownload();
        readyTemplateUpload();
    }
    else if (accessDownload){
        readyTemplateDownload();
    }
    else {
        existError = true;
        readyTemplateError();
    }
}
else{
    readyTemplateDownload();
    readyTemplateUpload();
}


function readyTemplateDownload(){
    templateDownload = $.Teamyar.layout({
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
    });
}
function readyTemplateUpload(){
    templateUpload = $.Teamyar.layout({
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
    });
}
function readyTemplateError(){
    templateError = $.Teamyar.layout({
        type:'COL-1',
        class_name: ' mx-0 mt-2 px-4 pb-2' ,
        controls: [
            "<p>خطایی رخ داده است، بطفا دوباره تلاش نمایید</p>",
        ]
    });
}


console.log(existError)
console.log(templateDownload)
console.log(templateUpload)
console.log(templateError)

$.Teamyar.layout({
    type:'COL-1',
    class_name: 'w-75 mx-auto px-0 pb-2 rounded  bg-white' ,
    id: "tester",
    selector: "#test_controller",
    controls: !existError ? [templateDownload , templateUpload] : [templateError]
});


//---------------------------

ty__main.downloadFileExcel = function (){
    $.Teamyar.ajax({
            options: {
                url: getUrlRequestGet() ,
                data: {
                    year: getYearShamsi() ,
                    month: getMonthShamsi() ,
                    day: getDayShamsi()
                } ,
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
        const sums = dataExp["sums"];
        let data = [headers];
        data = data.concat(excel);

        const fileName = $.trim($("#file_name").val());

        const fullFileName = fileName+"__"+getYearShamsi()+"-"+getMonthShamsi()+"-"+getDayShamsi()

        const isFormula = getIsFormula();
        if (isFormula){
            convertToExcelFormula(keys, data, fullFileName+".xlsx" , sums);
        }
        else{
            convertToExcel(keys, data, fullFileName+".xlsx" , sums);
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
        .then((response) => {
            if (response.hasOwnProperty("data")){
                return response.data;
            }
            $.Teamyar.confirm({
                message: getElementTitlePopup(true) + " فرمت پاسخ صحیح نمی باشد "
            });
        })
        .then((data) => {
            console.log(data)
            let msg = "مشکلی در پردازش داده های برگشتی رخ داده است";
            if (data.hasOwnProperty("status")){
                if(data.status){
                    msg = getElementTitlePopup() + "عملیات با موفقیت انجام شد";
                }
                else{
                    if(data.msg){
                        msg =getElementTitlePopup(true) +  data.msg;
                    }
                }
            }

            console.log(data);
            $.Teamyar.confirm({
                message: msg
            });
    });
}

function getElementTitlePopup(isError=false) {
    let title = "موفق"
    let classElement = "bg-success";
    if(isError){
        title = "خطا"
        classElement = "bg-danger"
    }
    return '<span class="'+classElement+' rounded text-white mx-2 px-2">'
        +title+
        '</span>'
}




