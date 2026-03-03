// main.js
// 画面に文字を出すためのお手伝い関数です
function logMessage(msg) {
    const logArea = document.getElementById('log-area');
    logArea.innerText += msg + "\n";
    console.log(msg);
}

// ボタンを押した時に動くメインの処理です
async function runTest() {
    document.getElementById('log-area').innerText = "テストを開始しますっ...\n";
    logMessage("SITE_URL: " + SITE_URL);
    logMessage("LIST_NAME: " + LIST_NAME);
    logMessage("-------------------------");

    try {
        // ① まず、auth.js の機能を使って通行証をもらいます
        logMessage("[1] 通行証を取りに行きます...");
        const digest = await getFormDigest();
        logMessage("  → 通行証ゲットです！");

        // ② 次に、api.js の機能を使ってリストに書き込みます
        logMessage("[2] リストへデータを送信します...");
        await addListItem(digest, "分割テスト成功ですっ！");
        
        // ③ 全部上手くいったら、大成功のメッセージです！
        logMessage("  → 【大成功！】リストへの書き込みが完了しました！");

    } catch (error) {
        // 途中で失敗したら、ここでエラーを表示します
        logMessage("【エラー発生】");
        logMessage(error.message);
    }
}
