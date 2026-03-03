// api.js
// リストにデータを追加する関数です
async function addListItem(formDigest, titleText) {
    const addUrl = SITE_URL + "/_api/web/lists/getbytitle('" + LIST_NAME + "')/items";
    
    // 送るデータはTitle列だけです！
    const itemData = {
        "Title": titleText
    };

    try {
        const response = await fetch(addUrl, {
            method: "POST",
            headers: {
                "Accept": "application/json; odata=nometadata",
                "Content-Type": "application/json; odata=nometadata",
                "X-RequestDigest": formDigest
            },
            body: JSON.stringify(itemData)
        });

        if (!response.ok) {
            const errText = await response.text();
            throw new Error("書き込みに失敗しましたっ。 Status: " + response.status + " 詳細: " + errText);
        }

        return true; // 成功したら true を返します

    } catch (error) {
        throw error;
    }
}
