/*
  kewbie-keycap.scad
  Narrow-pitch / Original profile keycap

  Copyright (C) 2025 by KAWABATA, Kazumichi
  SPDX-License-Identifier: 0BSD

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

  references:
    https://www.cherrymx.de/en/dev.html
    https://github.com/tamago324/small-keycaps
    https://github.com/bbrfkr/lhs-profile-keycap
    https://bebebe.hatenablog.jp/entry/2019/06/04/232501
    https://qiita.com/zk_phi/items/ab99315ebaef66e84aa0
*/

$fn = 128;

// =========================================
// Customizer
// =========================================

/* [Output] */
target = "home"; // [jlc3dp, home]

/* [1u Keys] */
num_R1          = 0; // [0:20]
num_R2          = 0; // [0:20]
num_R3          = 0; // [0:20]
num_R4          = 0; // [0:20]
num_Home        = 0; // [0:20]
num_Convex      = 0; // [0:20]
num_Convex_Home = 0; // [0:20]

/* [Wide Keys] */
num_Convex_125u = 0; // [0:20]
num_Convex_150u = 0; // [0:20]

/* [Layout] */
cols = 2; // [1:5]

/* [Hidden] */

// ステム関連（Cherry MX 互換）
stem_diameter    = 5.5;   // ステムの直径
stem_cross_wide  = 4.1;   // ステムの十字の幅（広い方）
stem_cross_narrow= 1.17;  // ステムの十字の幅（狭い方）
stem_height      = 14;    // ステムの高さ
stem_shift       = 0;     // 底面から内に引っ込める長さ

// キャップ関連
// ※ 一部の数値は実測と試作による微調整の結果
pitch      = 17;          // 狭ピッチ
wall_thick = 1.8;         // キャップ側面の厚さ

cap_top_inner    = 10;
cap_top_outer    = 7 + wall_thick * 2;  // 天面は inner より小さめに調整
cap_bottom_inner = 13;
cap_bottom_outer = cap_bottom_inner + wall_thick * 2;

cap_height_outer = 12;
cap_height_inner = cap_height_outer - wall_thick - 4.8; // 内部空間の深さ調整

rad          = 140;       // キートップ曲面を削り取る球の半径
cap_interval = 18;        // キーキャップを並べる時のピッチ
fontsize     = 2;         // 浮き彫り文字のサイズ

// ランナー関連（jlc3dp 発注時にキャップ間をつなぐサポート構造）
runner_h = 2;             // ランナーの足の高さ
runner_d = 1.5;           // ランナーの直径
cap_gap  = cap_interval - cap_bottom_outer; // 並べた時の隙間

// FDM 印刷補正（自宅3Dプリンター用）
// ステム十字溝を広げてキースイッチにはまるようにする。要実測調整。
fdm_clearance  = 0.2;
fdm_stem_shift = -0.3;   // ステムを底面から引っ込める

// =========================================
// ステム
// =========================================

// Cherry MX 互換の十字ステム
// $fdm_clearance が設定されている場合、十字溝を広げる
module _my_stem() {
    cl = is_undef($fdm_clearance) ? 0 : $fdm_clearance;
    difference() {
        translate([0, 0, stem_height / 2])
            cylinder(r = stem_diameter / 2, h = stem_height, center = true);
        // 十字の縦棒
        translate([0, 0, stem_height / 2])
            cube([stem_cross_narrow + cl, stem_cross_wide, stem_height], center = true);
        // 十字の横棒。貫通させて上下に少し開くようにする
        translate([0, 0, stem_height / 2])
            cube([stem_diameter, stem_cross_narrow - 0.1 + cl, stem_height], center = true);
    }
}

// =========================================
// キャップ形状
// =========================================

// 角丸直方体
module _my_rounded_cube(size, r) {
    h = 0.0001;
    minkowski() {
        cube([size[0] - r * 2, size[1] - r * 2, size[2] - h], center = true);
        cylinder(r = r, h = h);
    }
}

// 角丸直方体を積み重ねてキーキャップの形にする
module _my_cap_shape(top, bottom, height, unit=1, rounded=true) {
    hull() {
        if (rounded) {
            translate([0, 0, height])
                _my_rounded_cube([top * unit, top, 0.01], 3);
            _my_rounded_cube([bottom * unit, bottom, 0.01], 1);
        }
        else {
            translate([0, 0, height])
                cube([top * unit, top, 0.01], center = true);
            cube([bottom * unit, bottom, 0.01], center = true);
        }
    }
}

// キーキャップ外形
module _my_cap_outer(unit=1, rounded=true) {
    _my_cap_shape(cap_top_outer, cap_bottom_outer, cap_height_outer, unit, rounded);
}

// キーキャップ内形
module _my_cap_inner(unit=1, rounded=false) {
    _my_cap_shape(cap_top_inner, cap_bottom_inner, cap_height_inner, unit, rounded);
}

// 凸キャップ用の形状（親指キー等に使用）
// 各数値は実測による微調整
module _convex(unit=1) {
    rotate([0, 90, 0]) {
        rotate([0, 0, 15]) scale([1, 1.8, 1])
            cylinder(pitch * unit, 8, 8, true);
    }
}

// 一つのキーキャップ（行プロファイル付き）
// row の値で球面カットの Y 位置が変わり、行ごとの傾斜を表現する
// row: R1=1.9, R2=2.3, R3=2.9, R4=3.3（実測による微調整値）
module _my_cap(row=3, char="", unit=1, depth=0) {
    ss = is_undef($stem_shift) ? stem_shift : $stem_shift;
    difference() {
        union() {
            translate([0, 0, ss])
                _my_stem();
            difference() {
                _my_cap_outer(unit = unit);
                _my_cap_inner(unit = unit);
            }
        }
        // キーキャップの内側に文字を浮き彫り
        if (char != "") {
            theta = atan(cap_height_outer / ((cap_bottom_outer - cap_top_outer) / 2));
            translate([0, (cap_bottom_outer - wall_thick) / 2 - depth, ss + fontsize * 2]) {
                rotate([theta, 0, 180]) {
                    linear_extrude(wall_thick) {
                        text(
                            text = char,
                            size = fontsize,
                            halign = "center",
                            valign = "center"
                        );
                    }
                }
            }
        }
        // 球面カットで行プロファイルの傾斜をつける
        translate([0, pitch * 1.75 * (row - 2.75), rad + 6.5])
            sphere(r = rad);
    }
}

// =========================================
// ランナー
// =========================================

// キャップ間をつなぐランナー1本分（縦棒2本＋横棒1本）
module _runner(gap=cap_gap) {
    // キーキャップとつながる縦棒
    translate([-(gap + runner_d / 2 + wall_thick / 2) / 2, 0, -(runner_h) / 2])
        cylinder(r = runner_d / 2, h = runner_h, center = true);
    translate([ (gap + runner_d / 2 + wall_thick / 2) / 2, 0, -(runner_h) / 2])
        cylinder(r = runner_d / 2, h = runner_h, center = true);
    // 縦棒同士をつなぐ横棒
    translate([0, 0, -runner_h])
        rotate([0, 90, 0])
            cylinder(r = runner_d / 2, h = gap + runner_d * 3, center = true);
}

// x列 × y行 のキャップ間をランナーでつなぐ
// x_interval: 列間の距離（ワイドキー用に変更可能）
module runners(x=1, y=1, x_interval=cap_interval, x_gap=cap_gap) {
    // 横方向（列間）
    for (x = [1:x-1]) {
        for (y = [0:y-1]) {
            translate([x_interval * x - x_interval / 2, cap_interval * y, 0])
                _runner(x_gap);
        }
    }
    // 縦方向（行間）
    for (x = [0:x-1]) {
        for (y = [0:y-2]) {
            translate([x_interval * x, cap_interval * y + cap_interval / 2, 0])
                rotate([0, 0, 90]) _runner();
        }
    }
}

// =========================================
// キャップ単体
// =========================================

module cap_r1() {
    _my_cap(1.9, "1", depth = 0.5);
}
module cap_r2() {
    _my_cap(2.3, "Q", depth = 0.5);
}
module cap_r3() {
    _my_cap(2.9, "A", depth = 0.5);
}
module cap_r4() {
    _my_cap(3.3, "Z", depth = 0.5);
}

// ホームポジション用のバンプ（突起）
// 各数値は実測による微調整
module _home_bump() {
    hull() {
        translate([-3, -4.5, 6.5]) sphere(0.75);
        translate([ 3, -4.5, 6.5]) sphere(0.75);
    }
}

module cap_home() {
    _my_cap(2.9, "");
    _home_bump();
}

module cap_convex(unit=1) {
    ss = is_undef($stem_shift) ? stem_shift : $stem_shift;
    union() {
        intersection() {
            translate([0, 0, ss])
                _my_stem();
            _convex(unit = unit);
        }
        intersection() {
            difference() {
                _my_cap_outer(unit = unit);
                _my_cap_inner(unit = unit);
            }
            _convex(unit = unit);
        }
    }
}

module cap_convex_home(unit=1) {
    cap_convex(unit);
    _home_bump();
}

// =========================================
// 出力用ひとまとめ
// =========================================

// 同一行キャップ 2×5=10個セット
module rx10(row, char) {
    for (x = [0:1]) {
        for (y = [0:4]) {
            translate([x * cap_interval, y * cap_interval, 0])
                _my_cap(row, char, depth = 0.5);
        }
    }
    runners(2, 5);
}

// 同一行キャップ10個 + y==0 をホームキーに差し替え
module rx10_home(row, char) {
    for (x = [0:1]) {
        for (y = [0:4]) {
            translate([x * cap_interval, y * cap_interval, 0])
                if (y == 0) cap_home();
                else _my_cap(row, char, depth = 0.5);
        }
    }
    runners(2, 5);
}

// 修飾キーセット: convex 1u(2×3) + 1.25u(1×3) + 1.5u(1×3)
module mod() {
    for (x = [0:1]) {
        for (y = [0:2]) {
            translate([cap_interval * x, cap_interval * y, 0]) cap_convex();
        }
    }
    for (y = [0:2]) {
        translate([cap_interval * 2 + pitch * 0.25 / 2, cap_interval * y, 0])
            cap_convex(1.25);
    }
    for (y = [0:2]) {
        translate([-(cap_interval + pitch * 0.5 / 2), cap_interval * y, 0])
            cap_convex(1.5);
    }
    translate([-cap_interval, 0, 0])
        runners(4, 3);
}

// 修飾キー + R1 + ホームキーの混合セット
module mod_r1_home() {
    for (x = [0:1]) {
        for (y = [0:2]) {
            translate([cap_interval * x, cap_interval * y, 0]) cap_convex();
        }
    }
    for (x = [0:1]) {
        translate([cap_interval * x, cap_interval * 3, 0]) cap_convex_home();
    }
    for (y = [0:1]) {
        translate([cap_interval * 2 + pitch * 0.25 / 2, cap_interval * y, 0])
            cap_convex(1.25);
    }
    for (y = [2:3]) {
        translate([cap_interval * 2, cap_interval * y, 0])
            cap_r1();
    }
    for (y = [0:1]) {
        translate([-(cap_interval + pitch * 0.5 / 2), cap_interval * y, 0])
            cap_convex(1.5);
    }
    for (y = [2:3]) {
        translate([-cap_interval, cap_interval * y, 0])
            cap_home();
    }
    translate([-cap_interval, 0, 0])
        runners(4, 4);
}

// 凸キーセット: convex 1u + 1.25u + 1.5u + convex_home
module convex_keys() {
    for (x = [0:1]) {
        translate([cap_interval * x, cap_interval * 2, 0]) cap_convex();
        translate([cap_interval * x, cap_interval * 3, 0]) cap_convex();
        translate([cap_interval * x, cap_interval * 4, 0]) cap_convex_home();
    }
    translate([-(pitch * 0.25 / 2), cap_interval, 0])
        cap_convex(1.25);
    translate([cap_interval + pitch * 0.25 / 2, cap_interval, 0])
        cap_convex(1.25);
    translate([-(pitch * 0.5 / 2), 0, 0])
        cap_convex(1.5);
    translate([cap_interval + pitch * 0.5 / 2, 0, 0])
        cap_convex(1.5);
    runners(2, 5);
}

// convex + 1.5u + convex_home + R1 の混合セット
// target: "jlc3dp" = ランナー付き, "home" = FDM 補正付き
module other_keys(target="jlc3dp") {
    $fdm_clearance = (target == "home") ? fdm_clearance : 0;
    $stem_shift    = (target == "home") ? fdm_stem_shift : stem_shift;

    for (x = [0:1]) {
        translate([cap_interval * x, cap_interval * 1, 0]) cap_convex();
        translate([cap_interval * x, cap_interval * 2, 0]) cap_convex();
        translate([cap_interval * x, cap_interval * 3, 0]) cap_convex_home();
        translate([cap_interval * x, cap_interval * 4, 0]) cap_r1();
    }
    translate([-(pitch * 0.5 / 2), 0, 0])
        cap_convex(1.5);
    translate([cap_interval + pitch * 0.5 / 2, 0, 0])
        cap_convex(1.5);

    if (target == "jlc3dp") {
        runners(2, 5);
    }
}

// R4→R1 を1列に並べる
module r1_4() {
    translate([0, 0, 0])               cap_r4();
    translate([0, cap_interval, 0])     cap_r3();
    translate([0, cap_interval * 2, 0]) cap_r2();
    translate([0, cap_interval * 3, 0]) cap_r1();
    runners(1, 4);
}

// =========================================
// サンプル・テスト
// 使い方の例として残している。出力には使わない。
// =========================================

// 全キー種別を2列に並べて一覧する
// 左列: R4→R1（行プロファイル）、右列: home, convex(1u), convex(1.25u), convex(1.5u)
module sample1() {
    translate([0, 0, 0])               cap_r4();
    translate([0, cap_interval, 0])     cap_r3();
    translate([0, cap_interval * 2, 0]) cap_r2();
    translate([0, cap_interval * 3, 0]) cap_r1();

    translate([cap_interval + pitch * 0.5 / 2, cap_interval * 3, 0])  cap_convex(1.5);
    translate([cap_interval + pitch * 0.25 / 2, cap_interval * 2, 0]) cap_convex(1.25);
    translate([cap_interval, cap_interval, 0])                         cap_convex();
    translate([cap_interval, 0, 0])                                    cap_home();

    runners(2, 4);
}

// sample1 のバリエーション。右列に convex_home を含む
module sample2() {
    translate([0, 0, 0])               cap_r4();
    translate([0, cap_interval, 0])     cap_r3();
    translate([0, cap_interval * 2, 0]) cap_r2();
    translate([0, cap_interval * 3, 0]) cap_r1();

    translate([cap_interval + pitch * 0.5 / 2, cap_interval * 3, 0]) cap_convex(1.5);
    translate([cap_interval, cap_interval * 2, 0])                    cap_convex_home();
    translate([cap_interval, cap_interval, 0])                        cap_convex();
    translate([cap_interval, 0, 0])                                   cap_home();

    runners(2, 4);
}

// 2×5=10個。convex + R4〜R1 を2列に並べる
// target: "jlc3dp" = ランナー付き, "home" = FDM 補正付き
module samplex10(target="jlc3dp") {
    $fdm_clearance = (target == "home") ? fdm_clearance : 0;
    $stem_shift    = (target == "home") ? fdm_stem_shift : stem_shift;

    for (x = [0:1]) {
        translate([cap_interval * x, 0, 0])              cap_convex();
        translate([cap_interval * x, cap_interval, 0])      cap_r4();
        translate([cap_interval * x, cap_interval * 2, 0])  cap_r3();
        translate([cap_interval * x, cap_interval * 3, 0])  cap_r2();
        translate([cap_interval * x, cap_interval * 4, 0])  cap_r1();
    }

    if (target == "jlc3dp") {
        runners(2, 5);
    }
}

// R4, R3, R2 を 3×3 に並べた形状確認用
module test00() {
    translate([0, 0, 0])                              cap_r4();
    translate([0, cap_interval, 0])                    cap_r3();
    translate([0, cap_interval * 2, 0])                cap_r2();
    translate([cap_interval, 0, 0])                    cap_r4();
    translate([cap_interval, cap_interval, 0])         cap_r3();
    translate([cap_interval, cap_interval * 2, 0])     cap_r2();
    translate([cap_interval * 2, 0, 0])                cap_r4();
    translate([cap_interval * 2, cap_interval, 0])     cap_r3();
    translate([cap_interval * 2, cap_interval * 2, 0]) cap_r2();
}

// =========================================
// Customizer 出力
// =========================================

// グリッド配置ヘルパー（index を cols 列のグリッド座標に変換）
module _grid(index) {
    translate([(index % cols) * cap_interval, floor(index / cols) * cap_interval, 0])
        children();
}

module customizer() {
    $fdm_clearance = (target == "home") ? fdm_clearance : 0;
    $stem_shift    = (target == "home") ? fdm_stem_shift : stem_shift;
    with_runner    = (target == "jlc3dp");

    // --- 1u キー配置 ---
    off_r1        = 0;
    off_r2        = num_R1;
    off_r3        = off_r2 + num_R2;
    off_r4        = off_r3 + num_R3;
    off_home      = off_r4 + num_R4;
    off_cvx       = off_home + num_Home;
    off_cvx_home  = off_cvx + num_Convex;
    total_1u      = off_cvx_home + num_Convex_Home;

    for (i = [0:num_R1 - 1])          _grid(off_r1 + i)       cap_r1();
    for (i = [0:num_R2 - 1])          _grid(off_r2 + i)       cap_r2();
    for (i = [0:num_R3 - 1])          _grid(off_r3 + i)       cap_r3();
    for (i = [0:num_R4 - 1])          _grid(off_r4 + i)       cap_r4();
    for (i = [0:num_Home - 1])        _grid(off_home + i)     cap_home();
    for (i = [0:num_Convex - 1])      _grid(off_cvx + i)      cap_convex();
    for (i = [0:num_Convex_Home - 1]) _grid(off_cvx_home + i) cap_convex_home();

    rows_1u = ceil(total_1u / cols);
    if (with_runner && total_1u > 1)
        runners(min(cols, total_1u), rows_1u);

    // --- 1.25u キー配置（cols 列、1u セクションの下） ---
    y_off_125   = (total_1u > 0) ? rows_1u * cap_interval : 0;
    interval_125 = cap_interval + pitch * 0.25;
    gap_125      = interval_125 - cap_bottom_outer * 1.25;

    for (i = [0:num_Convex_125u - 1])
        translate([(i % cols) * interval_125, y_off_125 + floor(i / cols) * cap_interval, 0])
            cap_convex(1.25);

    rows_125 = ceil(num_Convex_125u / cols);
    if (with_runner && num_Convex_125u > 1)
        translate([0, y_off_125, 0])
            runners(min(cols, num_Convex_125u), rows_125, interval_125, gap_125);

    // --- 1.5u キー配置（cols 列、1.25u セクションの下） ---
    y_off_150    = y_off_125 + rows_125 * cap_interval;
    interval_150 = cap_interval + pitch * 0.5;
    gap_150      = interval_150 - cap_bottom_outer * 1.5;

    for (i = [0:num_Convex_150u - 1])
        translate([(i % cols) * interval_150, y_off_150 + floor(i / cols) * cap_interval, 0])
            cap_convex(1.5);

    rows_150 = ceil(num_Convex_150u / cols);
    if (with_runner && num_Convex_150u > 1)
        translate([0, y_off_150, 0])
            runners(min(cols, num_Convex_150u), rows_150, interval_150, gap_150);
}

// =========================================
// 出力選択
// =========================================

customizer();

// 個別モジュールを直接呼ぶ場合はここを書き替える:
// samplex10(target = "home");
// rx10(1.9, "1");
// other_keys(target = "jlc3dp");
