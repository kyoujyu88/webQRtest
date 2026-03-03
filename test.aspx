<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>Web打刻システム（お名前＆ID版）</title>
    <style>
        body { padding: 30px; font-family: sans-serif; text-align: center; background-color: #f0f8ff; }
        .container { background-color: white; padding: 40px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); display: inline-block; }
        h2 { color: #333; }
        #user-name-display { font-size: 1.5em; font-weight: bold; color: #0078D4; margin: 20px 0; }
        .btn { padding: 15px 40px; font-size: 1.2em; margin: 10px; cursor: pointer; border: none; border-radius: 5px; color: white; font-weight: bold; }
        .btn-in { background-color: #107C41; }
        .btn-out { background-color: #D83B01; }
        #log-area { margin-top: 30px; padding: 15px; border: 1px solid #ccc; background-color: #f9f9f9; text-align: left; height: 150px; overflow-y: auto; }
    </style>
</head>
<body onload="getCurrentUser()">

    <div class="container">
        <h2>Web打刻システム</h2>
        
        <div id="user-name-display">ユーザー情報を確認中...</div>

        <button class="btn btn-in" onclick="recordAttendance('出勤')">出勤</button>
        <button class="btn btn-out" onclick="recordAttendance('退勤')">退勤</button>
        
        <div id="log-area">ここにログが出ますっ...</div>
    </div>

    <script>
        // ★設定エリア★
        var SITE_URL = "https://na-n.gbase.gsdf.mod.go.jp/na/NA/NAFin/HQ/sinsa";
        var LIST_NAME = "TestList"; 

        // お名前とIDを別々に覚えておきますっ
        var loginUserName = "取得失敗"; 
        var loginUserId = "取得失敗";

        function logMessage(msg) {
            var logArea = document.getElementById('log-area');
            logArea.innerText = msg + "\n" + logArea.innerText;
        }

        // ① SharePointからユーザー情報を取ってきます
        function getCurrentUser() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", SITE_URL + "/_api/web/currentuser", true);
            xhr.setRequestHeader("Accept", "application/json; odata=nometadata");

            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        
                        // お名前を取得します
                        loginUserName = response.Title; 
                        
                        // 生のIDを取得します（記号がついています）
                        var rawId = response.LoginName;
                        var cleanId = rawId;

                        // ★ここがIDを綺麗に整形する魔法ですっ★
                        // 「|（パイプ）」があれば、その後ろだけを取り出します
                        if (cleanId.indexOf('|') !== -1) {
                            var parts = cleanId.split('|');
                            cleanId = parts[parts.length - 1];
                        }
                        // 「\（バックスラッシュ）」があれば、その後ろだけを取り出します
                        if (cleanId.indexOf('\\') !== -1) {
                            var parts = cleanId.split('\\');
                            cleanId = parts[parts.length - 1];
                        }

                        loginUserId = cleanId; // 綺麗になったIDを保存しますっ

                        // 画面にお名前とIDの両方を表示します！
                        document.getElementById('user-name-display').innerText = loginUserName + " さん (ID: " + loginUserId + ")、お疲れ様です！";
                        logMessage("ユーザー情報を取得しました: " + loginUserName + " / " + loginUserId);
                    } else {
                        document.getElementById('user-name-display').innerText = "ユーザー情報の取得に失敗しましたっ";
                        logMessage("ユーザー取得エラー: Status " + xhr.status);
                    }
                }
            };
            xhr.send();
        }

        // ② ボタンが押されたら動く処理です
        function recordAttendance(type) {
            if (loginUserName === "取得失敗" || loginUserName === "") {
                alert("ユーザー情報が確認できていませんっ。画面を更新してください。");
                return;
            }

            logMessage(type + "の記録を開始します...");

            var xhr = new XMLHttpRequest();
            xhr.open("POST", SITE_URL + "/_api/contextinfo", true);
            xhr.setRequestHeader("Accept", "application/json; odata=nometadata");

            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    var formDigest = response.FormDigestValue;
                    writeToList(formDigest, type);
                }
            };
            xhr.send();
        }

        // ③ リストへ書き込む処理です
        function writeToList(formDigest, type) {
            var now = new Date();
            var timeStr = now.getFullYear() + "/" + (now.getMonth() + 1) + "/" + now.getDate() + " " + now.getHours() + ":" + ("0" + now.getMinutes()).slice(-2);

            // リストに書き込む内容にも、お名前とIDの両方を入れますっ！
            var recordText = loginUserName + " (ID: " + loginUserId + ") - " + type + " - " + timeStr;

            var itemData = {
                "Title": recordText
            };

            var xhr2 = new XMLHttpRequest();
            xhr2.open("POST", SITE_URL + "/_api/web/lists/getbytitle('" + LIST_NAME + "')/items", true);
            xhr2.setRequestHeader("Accept", "application/json; odata=nometadata");
            xhr2.setRequestHeader("Content-Type", "application/json; odata=nometadata");
            xhr2.setRequestHeader("X-RequestDigest", formDigest);

            xhr2.onreadystatechange = function() {
                if (xhr2.readyState === 4) {
                    if (xhr2.status === 200 || xhr2.status === 201) {
                        alert(loginUserName + "さんの" + type + "時間を記録しました！\n" + timeStr);
                        logMessage("【大成功】記録完了: " + recordText);
                    } else {
                        logMessage("【失敗】書き込みエラーですっ。 Status: " + xhr2.status);
                    }
                }
            };
            xhr2.send(JSON.stringify(itemData));
        }
    </script>
</body>
</html>
