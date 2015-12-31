#--*-coding:utf-8-*--
#CGIの環境設定用ファイル

#デバッグログ出力設定 trueで出力。falseで非出力(ただしエラー処理は常に出力されます。)
$debug = true

#プレイルームデータ(saveData)の相対パス。
$SAVE_DATA_DIR = "../DodonTemp/"

#ロックファイル作成先のチューニング用。nilなら $SAVE_DATA_DIR と同一になります。
$SAVE_DATA_LOCK_FILE_DIR = nil

#各画像(キャラクター・マップ)の保存パス
$imageUploadDir = "../DodonTemp/imageUploadSpace"

#リプレイデータの保存パス
$replayDataUploadDir = "../DodonTemp/replayDataUploadSpace"

#セーブデータの一時保存パス
$saveDataTempDir = "../DodonTemp/saveDataTempSpace"

#ログアウト時に飛ばされるURL
#空の場合はログインしていた DodontoF.swf をリロードしてログイン画面に戻ります。
$logoutUrl = ""

#多言語化対応 trueなら多言語有効化
#有効にするとログイン画面表示の際に多言語設定を languages ディレクトリから読み取るため、
#この処理の重さを嫌うのであれば false に設定し無効化してください。
$isMultilingualization = false

# Pusher API URL
$isPusher = true

$Pusher_API_URL = "https://5c8061b261dcdb2c9a03:8aba34cd8f518f1a4373@api.pusherapp.com/apps/130760"
