async function fetchData(url, data={} , method= "post" , contentType = "application/json" , token = null){
    try {
        const options = {
            method ,
            headers : {
                "Content-Type" : "application/json" ,
                "Authorization" : `Bearer ${token}`
            }
        }

        if (method !== "DELETE" && method !=="GET"){
            options.body = JSON.stringify(data);
        }

        const response = await fetch(url , options);

        const responseData = response.headers.get("Content-Type")?.includes("application/json") ? await response.json() : {};

        if (!response.ok){
            throw  new Error("Failed to response data");
        }

        console.log("response success");
        return {data: responseData , error:  false , status: response.status};
    }
    catch (e){
        console.log(e.message);
        return {data: null , error:  true};
    }
}