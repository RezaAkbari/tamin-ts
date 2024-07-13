














const alphabetsSample =  ["a" , "b" , "c" , "d" , "e" , "f" , "g" , "h" , "i" , "j", "k" , "l" , "m" , "n" , "o" , "p" , "q" , "r" , "s" , "t" , "u" , "v" , "w" , "x" ,"y" , "z"];
const alphabesOther = [];
const alphabets = alphabetsSample;

for (let i = 0 ; i<alphabetsSample.length ; i++){
    const itemA = alphabetsSample[i];
    for (let j = 0 ; j<alphabetsSample.length ; j++){
        const itemB = alphabetsSample[j];
        alphabesOther.push(itemA+itemB)
    }
}

for (let i = 0 ; i<alphabesOther.length ; i++){
    const itemA = alphabesOther[i];
    alphabets.push(itemA);
}



console.log(alphabesOther , alphabets)
function getAlphabet(){
    return alphabets;
}




function convertExcelToJson(file, callback) {
    if (!file) {
        return;
    }

    const reader = new FileReader();

    reader.onload = function(e) {
        const data = new Uint8Array(e.target.result);

        const workbook = XLSX.read(data, { type: 'array' });

        const sheetName = workbook.SheetNames[0];
        const sheet = workbook.Sheets[sheetName];

        const jsonData = XLSX.utils.sheet_to_json(sheet);

        callback(jsonData);
    };

    reader.readAsArrayBuffer(file);
}

function convertToExcel(headers=[], datas=[] , fileName="output.xlsx"  , sum=null) {
    let dataExp = readyDataExcel(headers , datas , sum);

    const ws = XLSX.utils.json_to_sheet(dataExp);

    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Sheet1");

    XLSX.writeFile(wb, fileName);
}

function convertToExcelFormula(headers= {}, datas=[] , fileName="output.xlsx"   , sum=null) {

    let data = readyDataExcel(headers , datas , sum);
    console.log(data)


    const dataExp = [];
    let rowTitle = headers;
    /*for (let i = 0; i < headers.length ; i++) {

    }*/

   /*// let rowTitle = [];
    /!*Object.keys(headers).forEach(function(key){
        rowTitle.push(headers[key])
    });*!/*/
    dataExp.push(rowTitle);

    for (let i=0; i< data.length; i++){
        const row = [];
        const itemRow = data[i];
        Object.keys(itemRow).forEach(function(key){
            row.push(itemRow[key])
        });
        dataExp.push(row);
    }

    var ws = XLSX.utils.aoa_to_sheet(dataExp);


    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Sheet1");
    XLSX.writeFile(wb, fileName);
}



function readyDataExcel(headers=[], datas=[] , sum=null){

    /*let dataExp = datas.map(item => {
        let newItem = {};
        console.log(item)
        for (let i = 0; i < headers.length ; i++) {
            console.log(headers[i])

            if (typeof headers[i] != "undefined"){
                newItem[headers[i]] = item[i];
            }

        }
        return newItem;
    });*/
    const dataExp = datas;
    console.log(dataExp)

    if (sum!= null){
        let rowTotal = {};
        let indexAlphabet = 0;
        for (let i = 0; i <headers.length ; i++) {
            const itemHeader = headers[i];
            let exist = false;
            let alphabet = null;

            for (let j = 0; j < sum.length ; j++) {
                const keyRow = sum[j];
                if(itemHeader == keyRow && alphabets[indexAlphabet] !==  "undefined"){
                    exist = true;
                    alphabet = alphabets[indexAlphabet];
                }
            }
            indexAlphabet ++;
            console.log(alphabet)


            /*Object.keys(sum).forEach(function(keyRow){
                if(itemHeader == keyRow && alphabets[indexAlphabet] !==  "undefined"){
                    exist = true;
                    alphabet = alphabets[indexAlphabet];
                }
            })*/;
            if (exist){
                rowTotal[itemHeader] = { t: "n", f:  "=SUM("+alphabet+"3:"+alphabet+(dataExp.length).toString()+")"  };
            }
            else{
                rowTotal[itemHeader] = "";
            }
        }
        dataExp.push(rowTotal)
    }

    return dataExp;
}
