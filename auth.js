// auth.js
// 通行証をもらうための関数です
async function getFormDigest() {
    const ctxUrl = SITE_URL + "/_api/contextinfo";
    
    try {
        const response = await fetch(ctxUrl, {
            method: "POST",
            headers: { "Accept": "application/json; odata=nometadata" }
        });

        if (!response.ok) {
            throw new Error("通行証の取得に失敗しましたっ。 Status: " + response.status);
        }

        const data = await response.json();
        return data.FormDigestValue;

    } catch (error) {
        throw error;
    }
}
