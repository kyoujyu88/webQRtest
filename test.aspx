<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>API通信 確認テスト</title>
    <style>
        body { padding: 30px; font-family: sans-serif; }
        .log-box { 
            margin-top: 20px; padding: 15px; border: 1px solid #ccc; 
            background-color: #f5f5f5; min-height: 200px; font-size: 0.9em; 
            white-space: pre-wrap; word-wrap: break-word;
        }
    </style>
</head>
<body>

    <h2>API通信 確認テスト</h2>
    <p>設定を確認後、「テスト実行」を押してください。</p>
    
    <button onclick="runApiTest()" style="padding: 10px 20px; font-size: 1.1em; background-color: #0078D4; color: white;">テスト実行</button>

    <div id="log-output" class="log-box">待機中...</div>

    <script>
        // --- ★設定エリア★ ---
        // 1. サイトのURL (Listsの前まで！)
        const SITE_URL = "https://na-n.gbase.gsdf.mod.go.jp/na/NA/NAFin/HQ/sinsa";
        
        // 2. リストの内部名 (URLの一部になっている名前)
        // ※ 日本語の表示名ではなく、必ず内部名を指定してください！
        const LIST_NAME = "webQRtest"; 
        // ----------------------

        function log(msg) {
            const out = document.getElementById('log-output');
            out.innerText += msg + "\n";
            console.log(msg);
        }

        async function runApiTest() {
            document.getElementById('log-output').innerText = "テスト開始...\n";
            log("SITE_URL: " + SITE_URL);
            log("LIST_NAME: " + LIST_NAME);
            log("-------------------------");

            try {
                // 1. ContextInfo (通行証) の取得
                log("[1] ContextInfoの取得を開始...");
                const ctxUrl = SITE_URL + "/_api/contextinfo";
                log("  リクエスト先: " + ctxUrl);
                
                const ctxRes = await fetch(ctxUrl, {
                    method: "POST",
                    headers: { "Accept": "application/json; odata=nometadata" }
                });

                if (!ctxRes.ok) {
                    log("【失敗】ContextInfoが取得できません。 Status: " + ctxRes.status);
                    const err = await ctxRes.text();
                    log("  詳細: " + err);
                    return;
                }

                const ctxData = await ctxRes.json();
                const formDigest = ctxData.FormDigestValue;
                log("  成功！通行証(FormDigest)を取得しました。");

                // 2. リストへデータ追加 (Titleのみ)
                log("[2] リストへの書き込みを開始...");
                const addUrl = SITE_URL + "/_api/web/lists/getbytitle('" + LIST_NAME + "')/items";
                log("  リクエスト先: " + addUrl);

                const itemData = { "Title": "APIテスト成功！" };

                const addRes = await fetch(addUrl, {
                    method: "POST",
                    headers: {
                        "Accept": "application/json; odata=nometadata",
                        "Content-Type": "application/json; odata=nometadata",
                        "X-RequestDigest": formDigest
                    },
                    body: JSON.stringify(itemData)
                });

                if (addRes.ok) {
                    log("【大成功！】リストへの書き込みが完了しました。");
                } else {
                    log("【失敗】書き込みエラー。 Status: " + addRes.status);
                    const err = await addRes.text();
                    log("  詳細: " + err);
                }

            } catch (error) {
                log("【予期せぬエラー】通信処理中に問題が発生しました。");
                log("  詳細: " + error.message);
            }
        }
    </script>
</body>
</html>
