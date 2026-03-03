<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>Web打刻システム（IE11対応）</title>
    <style>
        body { padding: 30px; font-family: sans-serif; text-align: center; background-color: #f0f8ff; }
        .container { background-color: white; padding: 40px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); display: inline-block; }
        h2 { color: #333; }
        #user-name-display { font-size: 1.5em; font-weight: bold; color: #0078D4; margin: 20px 0; }
        .btn { padding: 15px 40px; font-size: 1.2em; margin: 10px; cursor: pointer; border: none; border-radius: 5px; color: white; font-weight: bold; }
        .btn-in { background-color: #107C41; } /* 緑色 */
        .btn-out { background-color: #D83B01; } /* 赤色 */
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

        // 取得したユーザー名を保存しておく変数です
        var loginUserName = "取得失敗"; 

        function logMessage(msg) {
            var logArea = document.getElementById('log-area');
            logArea.innerText = msg + "\n" + logArea.innerText; // 新しいログを上に足していきます
        }

        // ① SharePointに「今ログインしている人」を聞きに行く処理です
        function getCurrentUser() {
            var xhr = new XMLHttpRequest();
            // _api/web/currentuser で現在のユーザー情報を教えてもらえます！
            xhr.open("GET", SITE_URL + "/_api/web/currentuser", true);
            xhr.setRequestHeader("Accept", "application/json; odata=nometadata");

            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        loginUserName = response.Title; // ここで「自衛隊 太郎」などの名前が取れます！
                        document.getElementById('user-name-display').innerText = loginUserName + " さん、お疲れ様です！";
                        logMessage("ユーザー情報を取得しました: " + loginUserName);
                    } else {
                        document.getElementById('user-name-display').innerText = "ユーザー情報の取得に失敗しましたっ";
                        logMessage("ユーザー取得エラー: Status " + xhr.status);
                    }
                }
            };
            xhr.send();
        }

        // ② ボタンが押されたら動く処理（出勤・退勤共通です）
        function recordAttendance(type) {
            if (loginUserName === "取得失敗" || loginUserName === "") {
                alert("ユーザー情報が確認できていませんっ。画面を更新してください。");
                return;
            }

            logMessage(type + "の記録を開始します...");

            // まず通行証を取りに行きます
            var xhr = new XMLHttpRequest();
            xhr.open("POST", SITE_URL + "/_api/contextinfo", true);
            xhr.setRequestHeader("Accept", "application/json; odata=nometadata");

            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    var formDigest = response.FormDigestValue;
                    
                    // 通行証が取れたらリストへ書き込みます
                    writeToList(formDigest, type);
                }
            };
            xhr.send();
        }

        // ③ リストへ実際に書き込む処理です
        function writeToList(formDigest, type) {
            // 現在の時間を「YYYY/MM/DD HH:MM」の形で作ります
            var now = new Date();
            var timeStr = now.getFullYear() + "/" + (now.getMonth() + 1) + "/" + now.getDate() + " " + now.getHours() + ":" + ("0" + now.getMinutes()).slice(-2);

            // 今回はTestListのTitle列に「篤志 - 出勤 - 2026/03/03 12:00」のように全部まとめて書き込みます
            var recordText = loginUserName + " - " + type + " - " + timeStr;

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
