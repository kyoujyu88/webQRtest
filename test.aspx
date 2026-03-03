<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>IE11対応テスト</title>
    <style>
        body { padding: 30px; font-family: sans-serif; }
        #log-area {
            margin-top: 20px; padding: 15px; border: 1px solid #ccc;
            background-color: #f9f9f9; min-height: 200px; white-space: pre-wrap;
        }
    </style>
</head>
<body>

    <h2>IE11対応テスト（Title列のみ）</h2>
    <p>古いJavaScriptの言葉だけで通信してみますっ！</p>
    <button onclick="runIETest()" style="padding: 10px 20px; font-size: 1.1em; background-color: #0078D4; color: white; cursor: pointer;">テスト実行</button>

    <div id="log-area">ここにログが出ますっ...</div>

    <script>
        // ★設定エリア★
        // varを使って古い書き方にしていますっ
        var SITE_URL = "https://na-n.gbase.gsdf.mod.go.jp/na/NA/NAFin/HQ/sinsa";
        var LIST_NAME = "TestList"; // 用意していただいたリストの名前にしてくださいね

        // 画面に文字を出すためのお手伝い関数です
        function logMessage(msg) {
            var logArea = document.getElementById('log-area');
            logArea.innerText += msg + "\n";
        }

        // ボタンを押した時に動く処理です
        function runIETest() {
            var logArea = document.getElementById('log-area');
            logArea.innerText = "テストを開始しますっ...\n";
            logMessage("SITE_URL: " + SITE_URL);
            logMessage("LIST_NAME: " + LIST_NAME);
            logMessage("-------------------------");

            logMessage("[1] 通行証を取りに行きます...");

            // fetchの代わりに、昔ながらの XMLHttpRequest を使います！
            var xhr = new XMLHttpRequest();
            xhr.open("POST", SITE_URL + "/_api/contextinfo", true);
            xhr.setRequestHeader("Accept", "application/json; odata=nometadata");

            // 通信が終わった時の処理です
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        var formDigest = response.FormDigestValue;
                        logMessage("  → 通行証ゲットです！");
                        
                        // 通行証が取れたら、次の「書き込み処理」を呼び出します
                        writeToList(formDigest);
                    } else {
                        logMessage("【失敗1】通行証がもらえませんでしたっ。 Status: " + xhr.status);
                    }
                }
            };
            xhr.send();
        }

        // リストに書き込む処理です
        function writeToList(formDigest) {
            logMessage("[2] リストへデータを送信します...");

            var itemData = {
                "Title": "IE11対応テスト成功ですっ！"
            };

            var xhr2 = new XMLHttpRequest();
            xhr2.open("POST", SITE_URL + "/_api/web/lists/getbytitle('" + LIST_NAME + "')/items", true);
            xhr2.setRequestHeader("Accept", "application/json; odata=nometadata");
            xhr2.setRequestHeader("Content-Type", "application/json; odata=nometadata");
            xhr2.setRequestHeader("X-RequestDigest", formDigest);

            xhr2.onreadystatechange = function() {
                if (xhr2.readyState === 4) {
                    // 200か201なら成功です
                    if (xhr2.status === 200 || xhr2.status === 201) {
                        logMessage("  → 【大成功！】リストへの書き込みが完了しました！");
                    } else {
                        logMessage("【失敗2】リストへの書き込みエラーですっ。 Status: " + xhr2.status);
                        logMessage("詳細: " + xhr2.responseText);
                    }
                }
            };
            xhr2.send(JSON.stringify(itemData));
        }
    </script>

</body>
</html>
