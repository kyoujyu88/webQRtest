<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>SharePoint丸裸テスト</title>
</head>
<body style="padding: 30px; font-family: sans-serif;">

    <h2>丸裸テスト画面</h2>
    <p>F12キーを押して「コンソール」を開いた状態でボタンを押してくださいっ。</p>
    <button onclick="runSimpleTest()" style="padding: 15px 30px; font-size: 1.2em; background-color: #0078D4; color: white;">テスト送信</button>

    <script>
        async function runSimpleTest() {
            // ★ここだけ書き換えてください★
            const SITE_URL = "https://na-n.gbase.gsdf.mod.go.jp/na/NA/NAFin/HQ/sinsa";
            
            // 注意！ここはURLではなく「画面に表示されているリストのタイトル」です
            const LIST_NAME = "webQRtest"; 
            
            alert("テストを開始します！コンソールを確認してください。");
            console.log("1. 通行証（RequestDigest）をもらいに行きます...");

            try {
                // ① 通行証をもらう
                const ctxRes = await fetch(SITE_URL + "/_api/contextinfo", {
                    method: "POST",
                    headers: { "Accept": "application/json; odata=nometadata" }
                });
                
                if (!ctxRes.ok) {
                    alert("【失敗1】通行証がもらえませんでした！URLが間違っているかもしれません。");
                    console.error("通行証エラー:", await ctxRes.text());
                    return;
                }
                
                const ctxData = await ctxRes.json();
                const formDigest = ctxData.FormDigestValue;
                console.log("2. 通行証ゲット！:", formDigest.substring(0, 15) + "...");

                // ② リストに書き込む
                console.log("3. リストへデータを送信します...");
                const itemData = {
                    "Title": "テストAtsushi",
                    "AttendanceType": "出勤",
                    "TimeRecord": "2026/03/03 12:00"
                };

                const addRes = await fetch(SITE_URL + "/_api/web/lists/getbytitle('" + LIST_NAME + "')/items", {
                    method: "POST",
                    headers: {
                        "Accept": "application/json; odata=nometadata",
                        "Content-Type": "application/json; odata=nometadata",
                        "X-RequestDigest": formDigest
                    },
                    body: JSON.stringify(itemData)
                });

                if (addRes.ok) {
                    alert("【大成功！】リストにデータが追加されました！");
                    console.log("4. 完了しましたっ！");
                } else {
                    // ★ここが一番重要です！SharePointの生のエラーメッセージを取得します
                    const errorDetails = await addRes.text();
                    alert("【失敗2】リストへの書き込みでエラーが出ました。F12コンソールを見てください！");
                    console.error("★書き込みエラー詳細★:", errorDetails);
                }

            } catch (error) {
                alert("【予期せぬエラー】通信そのものができませんでした。");
                console.error("通信エラー:", error);
            }
        }
    </script>
</body>
</html>
