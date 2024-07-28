# Kewbie46

MacBook での尊師スタイル用にデザインした、40% キーボードです。

![kewbie46_00](https://i.imgur.com/eWcHN0J.png)

<img src="https://i.imgur.com/OsmuWYN.png" alt="kewbie46_01" width="50%" />

# 必要なパーツ

|パーツ|数|説明|
|---|--|--|
|PCB|1|1.6mm 厚 [[gerber](gerber/kewbie46/jlcpcb)]|
|トップレート|1|1.6mm 厚 [[gerber](gerber/kewbie46/jlcpcb)]|
|ボトムプレート|1|1.6mm 厚 [[gerber](gerber/kewbie46/jlcpcb)]|
|MCU カバー|1|[[gerber](gerber/kewbie46/jlcpcb)]|
|RP2040-Zero|1|https://www.waveshare.com/wiki/RP2040-Zero|
|ダイオード|46|SMD style (SOD123/1N4148W)|
|キーソケット|46| Cherry MX Compatible|
|キースイッチ|46|Cherry MX Compatible|
|キーキャップ|46|Cherry MX Compatible|
|スペーサー M2 5mm|2|
|ボルト M2 3mm|4|
|ボルト M2 8mm|10|
|ナット M2|20|

## ビルドガイド

* [Kewbie46 ビルドガイド](guide/README-ja.md)

## ブートローダ / カスタマイズ

* **リセットボタン**: PCB 上のボタンを短く押してください。パッドをショートさせる場合もあります。
  * BOOT ボタンを押しながら RESET ボタンを押すと USB マスストレージモードになり、ドラッグ & ドロップでファームウェアを書き込むことができます
* [Firmware](firmware)
  * [Vial](https://vial.today/)
  * [Kewbie46 - Remap](https://remap-keys.app/catalog/hTfNsK0O3Sb1Jaafdm3x)
* [Source code](https://github.com/higemaru/qmk_firmware/)
