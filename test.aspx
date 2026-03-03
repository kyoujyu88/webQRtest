<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>最小構成テスト</title>
</head>
<body style="padding: 30px; font-family: sans-serif;">

    <h2>Title列だけの最小テスト</h2>
    <p>F12キーでコンソールを開いてから、ボタンを押してくださいっ。</p>
    <button onclick="runMinimalTest()" style="padding: 15px 30px; font-size: 1.2em; background-color: #0078D4; color: white; cursor: pointer;">Titleのみ送信</button>

    <script>
        async function runMinimalTest() {
            // ★設定エリア★
            const SITE_URL = "https://na-n.gbase.gsdf.mod.go.jp/na/NA/NAFin/HQ/sinsa";
            
            // 注意！ここは画面に表示されているリスト名（日本語なら日本語で）を入れてください
            const LIST_NAME = "webQRtest"; 
            
            alert("テストを開始します！F12のコンソールを見ていてくださいね。");
            console.log("1. 通行証（RequestDigest）を取りに行きます...");

            try {
                // ① 通行証をもらう
                const ctxRes = await fetch(SITE_URL + "/_api/contextinfo", {
                    method: "POST",
                    headers: { "Accept": "application/json; odata=nometadata" }
                });

                if (!ctxRes.ok) {
                    alert("【失敗1】通行証がもらえませんでした！URLが違うかも？");
                    console.error("エラー詳細:", await ctxRes.text());
                    return;
                }

                const ctxData = await ctxRes.json();
                const formDigest = ctxData.FormDigestValue;
                console.log("2. 通行証ゲット！:", formDigest.substring(0, 15) + "...");

                // ② リストに書き込む（Title列だけ！！）
                console.log("3. データを送信します...");
                const itemData = {
                    "Title": "テスト成功です！！"
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
                    alert("【大成功！！！】リストにデータが入りました！");
                    console.log("4. 完璧に成功しました！リストの画面を確認してみてくださいっ。");
                } else {
                    const errorDetails = await addRes.text();
                    alert("【失敗2】書き込みでエラーが出ました。F12コンソールを見てください。");
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
