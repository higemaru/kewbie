# Kewbie Card

![kewbie_card](guide/images/IMG_1122.png)

# Required Parts

|Name|Count|Remarks|
|---|--|--|
|PCB|1|1.6mm thick|
|RP2040-Zero|1|https://www.waveshare.com/wiki/RP2040-Zero|
|Key swtiches|4|Cherry MX Compatible or Kailh Choc V1|
|Rotaly encoders|2|EC12　Compatible|
|Knob|2|For EC12 Compatible, 6mm D Shaft|

## Build Guide

* [Kewbie Card build guide](guide)

## Bootloader / Customize

* **Physical reset button**: Briefly press the button on the PCB - some may have pads you must short instead
  * To enter USB mass storage mode, press the RESET button with holding down the BOOT button, and write firmware by drag & drop.

* [Firmware](firmware)
  * [Vial](https://vial.today/)
* [Source code](https://github.com/higemaru/qmk_firmware/)
