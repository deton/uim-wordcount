uim-wordcount
=============

uim-wordcountはwcコマンドのuim IM版です。
セレクションやクリップボード内のテキストの
行数・単語数(英文)・文字数・(UTF-8での)バイト数を数えて表示します。

![表示例](https://github.com/deton/uim-wordcount/uim-wordcount-capture.png 表示例)

必要なもの
==========

セレクションやクリップボード内のテキストを取得するため、
uimのtext acquisition API(surrounding text API)を使うので、
text acquisition APIに対応したブリッジ(以下)でのみ動作します。

  * uim-gtk
  * uim-qt4
  * uim-qt3

インストール
============

./install.sh

準備
====

uim-pref-gtkやuim-pref-qt4を起動し、
「全体設定」→「使用可能にする入力方式」を編集し、
"wordcount"を有効にしてください。

キーボードを使ってwordcount IMに切り替えるには、
「ホットキーによる入力方式の一時切り替えを有効にする」を
チェックしてください。

使用方法
========

uim-toolbarや「一時切り替えキー」を使って、wordcount IMに切り替えます。

文字列を選択して、sキーを押すと文字数等が表示されます。

キー 処理
s    セレクションの文字数等を表示
S    クリップボードの文字数等を表示
l    表示されている行数を挿入
w    表示されている単語数を挿入
c    表示されている文字数を挿入
b    表示されている(UTF-8での)バイト数を挿入

備考
====

結果表示ウィンドウは、セレクション末尾あたりに表示されるため、
画面外に表示される場合があります。
セレクション末尾までスクロールしてください。
