# Kewbie46

40% keyboard designed for the SONSHI style (placed on top of a MacBook).

![kewbie46_00](https://i.imgur.com/eWcHN0J.png)

<img src="https://i.imgur.com/OsmuWYN.png" alt="kewbie46_01" width="50%" />

# Required Parts

|Name|Count|Remarks|
|---|--|--|
|PCB|1|1.6mm thick [[gerber](gerber/kewbie46/jlcpcb)]|
|Top plate|1|1.6mm thick [[gerber](gerber/kewbie46/jlcpcb)]|
|Bottom plate|1|1.6mm thick [[gerber](gerber/kewbie46/jlcpcb)]|
|Cover Plate|1|[[gerber](gerber/kewbie46/jlcpcb)]|
|RP2040-Zero|1|https://www.waveshare.com/wiki/RP2040-Zero|
|Diodes|46|SMD style (SOD123/1N4148W)|
|Key sockets|46| Cherry MX Compatible|
|Key swtiches|46|Cherry MX Compatible|
|Keycaps|46|Cherry MX Compatible|
|Spacers M2 5mm|2|
|bolt M2 3mm|4|
|bolt M2 8mm|10|
|Nut M2|20|

## Build Guide

* [Kewbie46 build guide](guide)

## Bootloader / Customize

* **Physical reset button**: Briefly press the button on the PCB - some may have pads you must short instead
  * To enter USB mass storage mode, press the RESET button with holding down the BOOT button, and write firmware by drag & drop.

* [Firmware](firmware)
  * [Vial](https://vial.today/)
  * [Kewbie46 - Remap](https://remap-keys.app/catalog/hTfNsK0O3Sb1Jaafdm3x)
* [Source code](https://github.com/higemaru/qmk_firmware/)
