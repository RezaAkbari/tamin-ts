


function getYearShamsi(){
    let yearFormat = new Intl.DateTimeFormat("fa", { year: "numeric" });
    let year = yearFormat.format(Date.now());
    return convertToFarsiNumToEnglish(year);
}


function getMonthShamsi(){
    let monthFormat = new Intl.DateTimeFormat("fa", { month: "numeric" });
    let month = monthFormat.format(Date.now());
    return convertToFarsiNumToEnglish(month);
}


function getDayShamsi(){
    let dayFormat = new Intl.DateTimeFormat("fa", { day: "numeric" });
    let day = dayFormat.format(Date.now());
    return convertToFarsiNumToEnglish(day);
}



function convertToFarsiNumToEnglish(farsiNumber) {
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    const englishDigits = '0123456789';

    let result = '';
    for (let i = 0; i < farsiNumber.length; i++) {
        const index = persianDigits.indexOf(farsiNumber[i]);
        if (index !== -1) {
            result += englishDigits[index];
        } else {
            result += farsiNumber[i];
        }
    }

    return result;
}
