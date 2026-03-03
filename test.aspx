<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>画面出力テスト</title>
    <style>
        body { padding: 30px; font-family: sans-serif; }
        #log-area { 
            margin-top: 20px; 
            padding: 15px; 
            border: 1px solid #ccc; 
            background-color: #f9f9f9; 
            min-height: 200px; 
            white-space: pre-wrap; /* エラーをそのまま表示します */
            font-size: 0.9em;
        }
        .success-text { color: green; font-weight: bold; }
        .error-text { color: red; font-weight: bold; }
    </style>
</head>
<body>

    <h2>Title列だけの画面出力テスト</h2>
    <button onclick="runVisualTest()" style="padding: 15px 30px; font-size: 1.2em; background-color: #0078D4; color: white; cursor: pointer;">テスト実行</button>

    <div id="log-area">ここに進行状況が表示されます...</div>

    <script>
        // ログを画面に出力するための関数です
        function outputLog(message, isError = false) {
            const logArea = document.getElementById('log-area');
            const p = document.createElement('div');
            p.textContent = message;
            if (isError) { p.className = 'error-text'; }
            logArea.appendChild(p);
        }

        async function runVisualTest() {
            // ★設定エリア★ (前回のテストと同じURLとリスト名にしてください)
            const SITE_URL = "https://na-n.gbase.gsdf.mod.go.jp/na/NA/NAFin/HQ/sinsa";
            const LIST_NAME = "webQRtest"; 

            // ログエリアをクリア
            document.getElementById('log-area').innerHTML = '';
            
            outputLog("テストを開始します...");
            outputLog("SITE_URL: " + SITE_URL);
            outputLog("LIST_NAME: " + LIST_NAME);
            outputLog("------------------------------------");

            try {
                // ----------------------------------------------------
                // 1. ContextInfo (通行証) の取得
                // ----------------------------------------------------
                outputLog("[1] 通行証（RequestDigest）を取りに行きます...");
                
                const ctxRes = await fetch(SITE_URL + "/_api/contextinfo", {
                    method: "POST",
                    headers: { "Accept": "application/json; odata=nometadata" }
                });

                if (!ctxRes.ok) {
                    outputLog("【失敗】通行証の取得でエラーになりました！ (Status: " + ctxRes.status + ")", true);
                    const errorText = await ctxRes.text();
                    outputLog("詳細: " + errorText, true);
                    return; // ここで終了
                }

                outputLog("  → 通信成功！(Status: " + ctxRes.status + ")");
                const ctxData = await ctxRes.json();
                const formDigest = ctxData.FormDigestValue;
                outputLog("  → 通行証をゲットしました！ (最初の10文字: " + formDigest.substring(0, 10) + "...)");

                // ----------------------------------------------------
                // 2. リストへのデータ書き込み (Titleのみ)
                // ----------------------------------------------------
                outputLog("[2] リストへデータを送信します...");
                const itemData = { "Title": "テスト成功です！！" };

                const addRes = await fetch(SITE_URL + "/_api/web/lists/getbytitle('" + LIST_NAME + "')/items", {
                    method: "POST",
                    headers: {
                        "Accept": "application/json; odata=nometadata",
                        "Content-Type": "application/json; odata=nometadata",
                        "X-RequestDigest": formDigest
                    },
                    body: JSON.stringify(itemData)
                });

                if (!addRes.ok) {
                    outputLog("【失敗】リストの書き込みでエラーになりました！ (Status: " + addRes.status + ")", true);
                    const errorDetails = await addRes.text();
                    outputLog("詳細: " + errorDetails, true);
                    return; // ここで終了
                }

                // ----------------------------------------------------
                // 3. 成功！
                // ----------------------------------------------------
                outputLog("  → 通信成功！(Status: " + addRes.status + ")");
                outputLog("【大成功！！！】リストにデータが入りました！", false);
                const p = document.createElement('div');
                p.className = 'success-text';
                p.textContent = "SharePointのリストを確認してみてください！";
                document.getElementById('log-area').appendChild(p);

            } catch (error) {
                outputLog("【予期せぬエラー】通信処理そのものが失敗しました。", true);
                outputLog("詳細: " + error.message, true);
            }
        }
    </script>
</body>
</html>
