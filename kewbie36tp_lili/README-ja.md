# Kewbie36tp LiLi

MacBook での尊師スタイル用にデザインした、36キーのキーボードです。

- ロープロファイル狭ピッチ（18 x 17mm） 
  - 。横17.5mm x 縦16.5mm 以下のキーキャップ想定です
- タッチパッドは「動くだけ」レベルです。他の手段がない時の緊急用

![kewbie36_00](images/kewbie36tp_lili-white.png)
![kewbie36_00](images/kewbie36tp_lili-back.png)
![kewbie36_01](images/kewbie36tp_lili-black.png)
![kewbie36_02](images/kewbie36tp_lili-iphone.png)

# 必要なパーツ

|Name|Count|Remarks|
|---|--|--|
|PCB|1|1.6mm 厚 [[gerber](gerber/jlcpcb)]|
|トップカバー|1|[[stl](stl/top_cover.stl)]|
|ボトムケース|1|[[stl](stl/bottom_case.stl)]|
|タッチパッド台|1|[[stl](stl/pedestal.stl)]|
|RP2040-Zero|1|https://www.waveshare.com/wiki/RP2040-Zero|
|ダイオード|36|SMD style (SOD123/1N4148W)|
|キーソケット|36| Kailh Choc v1/v2 Compatible|
|キースイッチ|36|Kailh Choc v1/v2 Compatible|
|キーキャップ|36|Kailh Choc v1/v2 Compatible|
|タッチパッド|1|[TPS43-201A-S](https://www.marutsu.co.jp/pc/i/25650684/)|
|FPC コネクター|1|[kinghelm KH-FG0.5-H2.0-6PIN](https://www.lcsc.com/product-detail/C709363.html)|
|リボンケーブル|1|0.5mm 6pin リボンケーブル|

## ビルドガイド

* [Kewbie36 ビルドガイド](guide)

## ブートローダ / カスタマイズ

* **リセットボタン**: PCB 上のボタンを短く押してください。パッドをショートさせる場合もあります。
  * BOOT ボタンを押しながら RESET ボタンを押すと USB マスストレージモードになり、ドラッグ & ドロップでファームウェアを書き込むことができます

* [Firmware](firmware)
  * [Vial](https://vial.today/)
* [Source code](https://github.com/higemaru/vial-qmk/tree/vial/keyboards/kewbie/kewbie36tp)
