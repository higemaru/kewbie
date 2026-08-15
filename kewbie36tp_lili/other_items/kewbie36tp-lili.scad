//include <BOSL2/std.scad>

//$fn = 128;
$fs=0.1;

// top logo 40mm 下げる

cs = 17;  // キャップのサイズ
cs_w=18;
cs_orig=19;
//cs = 17.5;  // キャップのサイズ
//cs = 19;  // キャップのサイズ
//hs = 14;  // スイッチ穴のサイズ
hs = 14.1;  // スイッチ穴のサイズ。3Dプリンタの時は少し大きめに
ps = 1.6; // PCB の厚さ
cb = 1.4; // Choc はかま深さ
ms = 2.667; // 縦ずれ
case_depth=8.5;

// 3Dプリントしたケース組み立て用のクリアランス
// Bambu PLA Matte だと、 top / ottom 0.5 でちょっと強度不足。マステで隙間調整がよさそう
// bottom 0.3 だときつめで少し反る。0.4 だと反らないけどやや浮く
slop=0.5;

/*
 * KLE 由来。微調整でなんとなく決まった数字
 * ソースコード中にも、手調整したマジックナンバーが 3 年分積もってて見通し悪い
 */
y_base_offset=4.141;   // Y方向基準オフセット値
y_compensation=18.624; // Y方向オフセットの補正値

xshift = -cs*6-cs/2;
yshift = -y_base_offset+y_compensation;
xrshift = -cos(30)*cs*cos(45);
yrshift = sin(30)*cs*sin(45);

xwshift = 10.5;  // 真ん中のスペース / 2
   echo("xshift:",xshift);

// ===== 追加パラメータ =====
// 天板の外形クリアランス（片側 mm）。この値をそのまま「片側の隙間」として読める。
//   壁の内面 : offset(1 + slop*2)
//   天板の外形: offset(2 - slop_fit)
//   slop=0.5 のとき 壁 2.0 / 天板 2-slop_fit なので、隙間 = slop_fit そのもの。
// slop に寄せると 隙間 = 3*slop-1 となり slop の変化が 3 倍で効く。
// 意図が読めなくなるので独立の値として持つ。
//
// 0.15 では 259mm の印刷物に対して詰めすぎで、分割印刷の誤差を吸収できず
// 天板がギチギチだったため 0.4 に広げた。
// 使用箇所は top_cover() の 1 行のみ。外形だけが縮み、
// キー穴・ネジ穴・TPS43 穴は動かない。
slop_fit    = 0.4;   /// 天板外形クリアランス 片側mm（旧: ラビット継手クリアランス 0.15）

// 最内列（左半分の T / 右半分の Y）を中央から離す量 mm。左右それぞれに効く。
// OpenSCAD で SVG 出力 -> KiCad にインポート -> アタリにして手配置、という
// 経路のため、PCB 側の左右グループ間隔が SCAD より僅かに広い。
// 天板の中央ピースを嵌めるとき左右に引っ張る形になっていたので、
// 天板側の最内列を外へ逃がして吸収する。
//   0.1 で左右合計 0.2mm 広がる。T-R 列間ピッチは 18 -> 17.9（0.5%、体感不可）
//   15 度回転後の水平成分は 0.1*cos15 = 0.097mm。補正不要
//   ウイングは main2 列（Y=0 で X=61.79）以降なので影響を受けない
// キー配置は lefthalf() の 1 箇所だけ。右半分は mirror なので自動的に対称。
inner_col_adj = 0.1;


// セルフタッピング用ボスパラメータ
boss_od    = 7;
screw_pass = 2.3;    // bottom 側の通し穴径
csink_d    = 4.2;    // 皿ザグリ径
csink_h    = 1.3;    // 皿ザグリ深さ


lug        = 8;    // 左右張り出し量（boss_od 5.5 + 余裕）
lug_margin = 4;    // ボス中心から lug 端までの余裕

// 支柱の位置（穴と穴の中央）
support_pos = [
//    [cs_w*6.25, y_base_offset-ms+cs*2.5],   // Q-W間、中段
    [cs_w*4, y_base_offset-1],   // E-R間、中段
];
   
module keyswitch(switch=true,hole=true) {
    w=cs_orig;
    h=cs_orig;
    hh=hs;
    circle_shift=0.71;
    circle_dia=2;

    difference() {
        if ( switch )
            square([w,h]);
        if ( hole ) {
            cx = (w-hh)/2;
            cy = (h-hh)/2;
            translate([cx,cy,0]) square(hh);
            translate([cx+circle_shift,cy+circle_shift,0]) circle(d=circle_dia);
            translate([cx+circle_shift,cy+hh-circle_shift,0]) circle(d=circle_dia);
            translate([cx+hh-circle_shift,cy+circle_shift,0]) circle(d=circle_dia);
            translate([cx+hh-circle_shift,cy+hh-circle_shift,0]) circle(d=circle_dia);
        }
    }
}
module keyswitch_column(switch=true,hole=true) {
    for( y = [0 : 2]) {
        translate([0,cs*y,0]) keyswitch(switch,hole);
//        translate([0,(cs+1)*y,0]) keyswitch(switch,hole,w,h);
    }
}
module shiftbasepos(w=cs,h=cs){
    translate([-xrshift-h*cos(60)-w*cos(30), -yrshift+w*sin(30)-h*sin(60), 0])
        children();
}
// z 起点
module position_from_z_key(w=cs,h=cs) {
    shiftbasepos(w,h)
        translate([xshift, yshift, 0])
            children();
}
// t 起点。6列の時に作ったので、5列だと t の横ではないが、穴埋め用なので気にしない
module position_from_t_key(w=cs,h=cs) {
    position_from_z_key(w,h)
        translate([cs*6, y_base_offset+cs*2, 0])
            children();
}
// opt 起点
module position_from_thumb_left(w=cs, h=cs) {
    translate([cs*2+9.144, y_base_offset+ms-w, 0])
        position_from_z_key(w,h)
            children();
}

// キー配置
module lefthalf(switch=true,hole=true,lug=0) {
    w=cs_orig;
    h=cs_orig;

    shiftbasepos(w,h) {
        translate([xshift-5, yshift, 0]) {
            translate([cs_w  , y_base_offset-ms,     0]) keyswitch_column(switch,hole); // Q
            translate([cs_w*2, y_base_offset+ms,       0]) keyswitch_column(switch,hole); // W
            translate([cs_w*3, y_base_offset+ms+1.714, 0]) keyswitch_column(switch,hole); // E
            translate([cs_w*4, y_base_offset+ms,       0]) keyswitch_column(switch,hole); // R
            translate([cs_w*5 - inner_col_adj, y_base_offset, 0]) keyswitch_column(switch,hole); // T
            translate([cs*2+9.144, y_base_offset+ms-w-5-0.25, 0]) {
                translate([cs_w, -ms, 0]) keyswitch(switch,hole); // opt
                translate([cs_w*2, -ms*2, 0]) keyswitch(switch,hole); // cmd
            }
            // Q列左端から外側に張り出し
            if (lug > 0)
                translate([cs_w - lug, y_base_offset-ms, 0])
                    square([lug, cs*3+h-cs]);
            }
echo(cs*2+9.144);
        // mod
//         translate([xrshift, yrshift-5*cos(15)-0.5, 0])
         translate([xrshift, yrshift-5*cos(15)-0.5-1, 0])
            rotate([0, 0, -30])
//                translate([0,-cs*0.4,0])
                translate([0,-cs*0.4-4-1,0])
                    keyswitch(switch,hole);

    }
}

module lefthalf_for_base(lug=0) {
    margin = 1; // 外周マージン
    w=cs_orig;
    h=cs_orig;

    offset(delta=margin){ // 外周広げる
        //mod 付近埋める
        translate([13*cos(60),7*sin(60),0]) rotate([0,0,150]) square([19.5,43.75]);
        //cmd 付近埋める
        translate([cs*2, -ms*2, 0]) position_from_thumb_left(w,h) square([w*2,h]);

        //英数付近埋める
        position_from_thumb_left(-3,h) square([w*3,h*1.5]);
        position_from_thumb_left(w,h) translate([-w,h*0.79]) square([w*2,h]);
        //
        // 英数の横埋めたければここかな
        //

        // T列より内側埋める
        translate([0, -28.5, 0])
            position_from_t_key(w,h)
                square([19,47.5]);

        //大枠
        lefthalf(switch=true,hole=false,lug=lug);
    }
}

module roundedcorner(r=2) {
    offset(r=-r/2)offset(delta= r/2)
    offset(r=-r/2)offset(delta= r/2)
    offset(r= r/2)offset(delta=-r/2)
    offset(r= r/2)offset(delta=-r/2)
        children();
}


module base_plate(lug=0){
    centermargin = 65; // 中央の空間を埋める
    spacewidth = 24+(xwshift-4)*2;

    roundedcorner(3) {
        // 上をたいらに
        translate([-10,66.8-7.2,0]) square([20,4]);

        // 中央の空きをうめる
        translate([-spacewidth/2,-8-4.8,0]) square([spacewidth,centermargin]);

        translate([-xwshift,0,0])
            rotate([0,0,-15])
                lefthalf_for_base(lug=lug);
        translate([xwshift,0,0])
            rotate([0,0,15])
                mirror([1,0,0]) lefthalf_for_base(lug=lug);

    }
}

module bottom_case(lug=0) {
    usbport_w=12;
    rim_h = 1.0;
    difference() {
        union(){
            // 壁
echo("case_depth:",case_depth);
echo("cb:",cb);
//            linear_extrude(case_depth-cb)
            linear_extrude(case_depth)
                difference() {
                    offset(2.6+slop*2) base_plate(lug=lug);
                    offset(1+slop*2) base_plate(lug=lug);
//                    offset(0.5+slop*2) base_plate(lug=lug);
                    translate([-usbport_w/2,66.-case_depth,0])
                        square([usbport_w,27]);
                }
            // 床
            linear_extrude(cb)
                offset(2) base_plate(lug=lug);

            //角丸
            translate([0,0,case_depth]) {
                r=(2.6-1)/2;
                n=8;
                dz = r/n;
                for (i = [0 : n-1]) {
                    a = asin(i/n);          // z = r*sin(a) = i*dz と一致
                    translate([0, 0, i*dz])
                        linear_extrude(dz + 0.01)
                            difference() {
                                offset(2.6+slop*2 - r + r*cos(a)) base_plate(lug=lug);
                                offset(1+slop*2 + r - r*cos(a)) base_plate(lug=lug);
                                translate([-usbport_w/2, 66.-case_depth, 0])
                                    square([usbport_w, 27]);
                            }
                }
            }
                
            // ラビット継手レッジ
/*            translate([0,0,case_depth-cb])
                linear_extrude(cb)
                    difference() {
                        offset(2+slop*2) base_plate(lug=lug);
                        offset(1+slop*2) base_plate(lug=lug);
//                        offset(2+slop_fit) base_plate(lug=lug);
                        translate([-usbport_w/2,66.-case_depth,0])
                            square([usbport_w,27]);
                    }
*/
            // ネジボス（lug 位置、床から立ち上がる）
/*            if (lug > 0)
                place_all_lug_bosses(lug)
                    boss_with_nut(case_depth-cb);*/

            // 支柱（たわみ防止）
            place_all_support_pillars()
                cylinder(d=boss_od, h=case_depth-cb-ps-0.2, $fn=32);
                // case_depth-cb-ps = 8.5-1.4-1.6 = 5.5mm
                    
                    
        }
        // リセットボタン用の穴
        translate([-7,43.5,0])
            linear_extrude(1.5)
                roundedcorner() square([14, 6]);

        translate([-35,20,0])
            linear_extrude(0.4)
                logo_big_outline();
    }
    // 足
/*    translate([0,2,0]) {
        // 足の仕様 [右側X座標, Y座標, Z座標, 高さ]
        foot_specs = [
//            [28, 0, -2.4, 2.8+0.5],    // 手前側の足
            [18, -18.5, -2.4, 2.8+0.5],    // 手前側の足
            [70, 74, -4.4, 4.8+0.5]    // 奥側の足
        ];

        for (spec = foot_specs) {
            // 右側
//            translate([spec[0], spec[1], spec[2]])
            translate([spec[0]+1, spec[1], spec[2]])
//                cube([35, ps, spec[3]]);
                cube([30, ps, spec[3]]);
            // 左側（対称）
//            translate([-spec[0]-35, spec[1], spec[2]])
            translate([-spec[0]-30-1, spec[1], spec[2]])
//                cube([35, ps, spec[3]]);
                cube([30, ps, spec[3]]);
        }
    }*/
}


module logo_big() {
    rotate([0,180])
        scale([0.3,0.3])
            import("fox-nine.svg",center=true);
}

// 塗りつぶしの logo_big() を輪郭線に変換する。
// 床裏に 0.4mm で彫ると、塗りつぶしのままでは 20〜30mm 幅の空洞ができて
// 2 層のブリッジが架からず失敗した（実測）。
// 内側に縮めた形を引くと、全境界に沿った幅 logo_line_w のリングが残る。
// 元が logo_line_w*2 より細い部分は縮めた時点で消えるので、
// ヒゲなど細い箇所は塗りつぶしのまま残り、太い面だけが輪郭になる。
// offset は重いので、レンダリングに時間がかかる。
logo_line_w = 1.2;

module logo_big_outline(w = logo_line_w) {
    difference() {
        logo_big();
        offset(delta = -w) logo_big();
    }
}


module logo_mini() {
    scale([0.15,0.15])
        rotate([0,0,0])
            import("lili.svg",center=true);
//            import("fox-carp-mono.svg",center=true);
}


module top_cover(lug=0) {
    // トップ
    difference() {
        linear_extrude(cb)
            top_cover_svg(2-slop_fit, lug=lug);

        // MCU のピンの分凹ませる
        translate([-12,39,0]) cube([24,27,0.4]);
        // ロゴの形のくぼみ
        translate([0,46,1])
            linear_extrude(0.4)
                logo_mini();

        // ネジ通し穴（lug 位置）
        if (lug > 0)
            place_all_lug_bosses(lug) {
                cylinder(d=screw_pass, h=cb+0.1, $fn=32);
                translate([0,0,cb-csink_h])
                    cylinder(d1=screw_pass, d2=csink_d, h=csink_h+0.1, $fn=32);
            }
    }

    // ログを別色で印刷するために離れたところ(Y 軸 40mmずらす)に用意。
    translate([0,86,1])
        linear_extrude(0.4)
            logo_mini();
}

module top_cover_svg(offset=1.5,lug=0) {
    diff = 0.5; // タッチパッドに被せる分
    difference() {
        edge_svg(cut_tp=false,cut_key=true, offset=offset,lug=lug);
        // TPS43 よりひとまわり小さめの穴
        roundedcorner()
            translate([0,12,0]) square([43.3-diff*2,40.0-diff*2],center=true); // TPS43

        // ネジ穴（top_cover と同じ位置）
        if (lug > 0)
            place_all_lug_bosses(lug)
                circle(d=screw_pass, $fn=32);
// ロゴで抜きたいときはコメント外す
/*        translate([0,46,0])
            logo_mini();*/
    }
}

module edge_svg(cut_mcu = false, cut_tp = false, cut_key = false, offset=0, lug=0) {
    difference(){
        roundedcorner() {
            difference() {
                offset(r=offset) base_plate(lug=lug);
                // MCU 用の切り欠き
                if (cut_mcu) {
                    translate([-6.5,66.8-21.5-(cs_orig-cs)*7*sin(15),0])square([12.5,21.5]);
                }
            }
        }
        // トラックパッド TPS43 用の穴
        if (cut_tp) {
            roundedcorner()
                translate([0,12,0])
                    square([43.3+ps*2,40.0+ps*2],center=true);
        }
        // キーの穴
        if (cut_key) {
            translate([-xwshift,0,0])
                rotate([0,0,-15])
                    lefthalf(switch=false,hole=true);
            translate([xwshift,0,0])
                rotate([0,0,15])
                    mirror([1,0,0])
                        lefthalf(switch=false,hole=true);
        }
    }
}

// ===== lug ボス位置モジュール =====
// M2 六角ナット寸法
/*nut_w  = 4.0;  // 対辺距離
nut_t  = 1.6;  // 厚さ
bolt_d = 2.4;  // M2 ボルト通し穴径
bolt_l = 5;   // ボルト全長（ネジ部）M2x5mm
module boss_with_nut(h) {
    nut_z  = h - (bolt_l - cb);  // ボス上端から (bolt_l - cb) 下がった位置
    difference() {
        cylinder(d=boss_od, h=h, $fn=32);
        // ボルト穴（上から貫通）
        cylinder(d=bolt_d, h=h+0.1, $fn=32);
        // ナット溝（-X方向 = lug 外側に向かって開口）
        translate([-nut_w/2-0.1, -nut_w/2-0.2, nut_z])
            cube([boss_od+0.2, nut_w+0.4, nut_t+0.1]);
    }
}*/

module place_lug_bosses(lug) {
    w = cs_orig;
    h = cs_orig;
    bx       = cs_w - lug/2-1;
    by_front = y_base_offset - ms + lug_margin;
    by_back  = y_base_offset - ms + cs*3+h-cs - lug_margin;
    shiftbasepos(w,h)
        translate([xshift-5, yshift, 0]) {
            translate([bx, by_front, 0]) children();
            translate([bx, by_back,  0]) children();
        }
}

module place_all_lug_bosses(lug) {
    translate([-xwshift,0,0])
        rotate([0,0,-15])
            place_lug_bosses(lug) children();
    translate([xwshift,0,0])
        rotate([0,0,15])
            mirror([1,0,0])
                place_lug_bosses(lug) children();
}

module place_support_pillars() {
    w = cs_orig;
    h = cs_orig;
    shiftbasepos(w,h)
        translate([xshift-5, yshift, 0])
            for (p = support_pos)
                translate([p[0], p[1], 0]) children();
}

module place_all_support_pillars() {
    translate([-xwshift,0,0])
        rotate([0,0,-15])
            place_support_pillars() children();
    translate([xwshift,0,0])
        rotate([0,0,15])
            mirror([1,0,0])
                place_support_pillars() children();
}


module pedestal() {
    // 台座
    // TPS43-201A-S https://www.marutsu.co.jp/pc/i/25650684/
    // 43.3 x 40.0mm
    // 厚さ: 基板 1mm、シート 0.2mm、コネクタ類 2.2mm = 3.4mm
    // 周辺からチップまで 5.2mm → フチは 4mm
    // Choc の bottom の深さは 8-1.4=6.6mm
//    depth=8-1.4-1.2=5.4;
//
//    depth=7-cb-1.2;
    slop_tp=slop+0.2;
    frame_depth=2;
//    depth=case_depth-cb*2-frame_depth-slop_tp;
//    depth=case_depth-cb*2-frame_depth;   // 旧: 全高 5.7。case_depth 基準
    // 高さの基準はスペーサー長。case_depth（壁の高さ）はもう天板の Z を
    // 決めていない。床上面から天板下面までが spacer_h なので、
    // 台座の全高 = depth + frame_depth = spacer_h になるようにする。
    //   旧 5.7 のままだと天板下面 7.4 に対して頂面 7.1 で 0.3mm 足りず、
    //   トラックパッドががたついた（実測）。
    // pedestal_slop で逃がす。0 だと印刷で高く出たとき天板を押し上げて
    // スペーサーから浮かせるので、必要なら 0.1 程度入れる。
    pedestal_slop = -0.2;
    depth = spacer_h - frame_depth - pedestal_slop;
echo("pedestal: depth:",depth);
    tps_w=43.3;
    tps_h=40.0;
// 8.5-1.4=7.1
    linear_extrude(depth)
        difference() {
            roundedcorner()
                difference() {
                    square([tps_w+1.5*2,tps_h+1.5*2],center=true); //台座
                    square([tps_w+1.5*2,20],center=true); // 横穴
                    square([20,tps_h+1.5*2],center=true); // 竪穴
                    translate([0,20,0]) square([36,tps_h+1.5*2],center=true); // 竪穴
                }
            roundedcorner()
                square([tps_w-4*2, tps_h-4*2], center=true);
        }

    translate([0,0,depth])
//        linear_extrude(1.2)
        linear_extrude(frame_depth)
            difference() {
                roundedcorner()
                    square([tps_w+1.5*2,tps_h+1.5*2],center=true); // TPS43 サイズ
                roundedcorner()
                    square([tps_w+slop_tp, tps_h+slop_tp], center=true);
            }
/*    translate([0,0,depth+1.2])
        linear_extrude(0.8)
            difference() {
                roundedcorner()
                    square([tps_w+1.5*2-0.8*2,tps_h+1.5*2-0.8*2],center=true); // 凸
                roundedcorner()
                    square([tps_w+slop_tp, tps_h+slop_tp], center=true);
            }*/
}


// ============================================================
//  v2 追加分  ---  X=0 分割 / 当て板接合 / スペーサー / T字足
//  2026-08 マージ
//
//  旧実装は本体側でコメントアウト済み（履歴として残置）:
//    - boss_with_nut と nut_w/nut_t/bolt_d/bolt_l  … スペーサーに置換
//    - bottom_case() 内の「// 足」ブロック          … foot_slots + foot_part に置換
//    - 床裏のロゴ … logo_big() は面が広くブリッジ失敗。logo_big_outline() に置換
//  place_lug_bosses / place_all_lug_bosses はネジ位置モジュールとして現役
// ============================================================

// ===== 追加パラメータ =====
spacer_h     = 6.0;    // M2 F-F スペーサー長（6 or 7）
joint_h      = 4.0;    // 床上面からの接合ブロック高さ
joint_top    = cb + joint_h;         // 5.4 (外底面基準)
recess_d     = 2.0;    // 当て板の座の深さ
recess_z     = joint_top - recess_d; // 3.4
recess_w     = 19.0;   // 座の幅。台座の竪穴 20 に対し片側 0.5 逃がし
plate_gap_xy = 0.30;   // 当て板 XY クリアランス（クーポンで確定）
plate_gap_z  = 0.10;   // 当て板をわずかに沈める
seam_gap     = 0.10;   // 継ぎ目 片側クリアランス

nut_af       = 4.1;    // M2 ナット 二面幅 + 0.1
nut_th       = 1.8;    // M2 ナット 厚 + 0.2
nut_relief_d = 4.8;    // 底面側の逃がし径
nut_relief_h = 0.5;    // ナットを沈める量

// 接合範囲。トラックパッド穴と同じ Y 範囲に収める。
// MCU 切欠きの下端は 41.68 だが、RP2040-Zero は裏面 SMD で切欠きより
// 2mm ほど下にはみ出すため、そこまで伸ばすと当たる。
joint_y0 = 12 - (40.0 + ps*2)/2;   // -9.60  トラックパッド穴の下端
joint_y1 = 12 + (40.0 + ps*2)/2;   //  33.60  トラックパッド穴の上端
joint_screw_y = [joint_y0 + 5.5, joint_y1 - 5.5];   // -4.10 / 28.10
joint_screw_x = 6.0;                                // 継ぎ目からの距離

// TPS43 裏のコネクタ逃がし。実測（TPS43 左下端 基準 → 組立座標）
//   X  ±4.8 〜 ±12.4      Y  +3.9 〜 +13.8      下端 z ≒ 3.8
// 座 z=3.4 のブロックは当たらないが、当て板（3.4〜5.3）が当たる。
// ネジ Y=-4.1 と 28.1 の間なので、当て板を 2 枚に割って開放する。
conn_y0 =  1.0;
conn_y1 = 17.0;

// 当て板 [Y開始, Y終了, ネジのY]
cover_plates = [
    [joint_y0, conn_y0, joint_screw_y[0]],
    [conn_y1,  joint_y1, joint_screw_y[1]]
];

echo("joint_y0:", joint_y0, "joint_y1:", joint_y1);

// ===== 接合まわり =====

// 継ぎ目をまたぐ台。天面に当て板の座を掘る
// 床の上に立てる。z=0 から立ち上げると、床裏に彫ったロゴの溝を
// 埋め戻してしまう（当て板の座の範囲だけロゴが消える）。
module joint_block() {
    len = joint_y1 - joint_y0;
    difference() {
        translate([-recess_w/2, joint_y0, cb])
            cube([recess_w, len, joint_top - cb]);
        translate([-recess_w/2-0.01, joint_y0-0.01, recess_z])
            cube([recess_w+0.02, len+0.02, recess_d+0.01]);
    }
}

// 底面から掘るナットポケット + 座面まで抜くバカ穴
module joint_fasteners() {
    for (y = joint_screw_y)
        for (sx = [-1, 1])
            translate([sx*joint_screw_x, y, 0]) {
                translate([0,0,-0.01])
                    cylinder(d=nut_relief_d, h=nut_relief_h+0.01, $fn=32);
                translate([0,0,nut_relief_h])
                    cylinder(d=nut_af/cos(30), h=nut_th, $fn=6);
                translate([0,0,-0.01])
                    cylinder(d=screw_pass, h=recess_z+0.02, $fn=32);
            }
}

// 当て板 1 枚
module cover_plate_one(y0, y1, sy) {
    w = recess_w - plate_gap_xy*2;
    l = (y1 - y0) - plate_gap_xy*2;
    difference() {
        translate([-w/2, y0 + plate_gap_xy, 0])
            cube([w, l, recess_d - plate_gap_z]);
        for (sx = [-1, 1])
            translate([sx*joint_screw_x, sy, 0]) {
                translate([0,0,-0.01])
                    cylinder(d=screw_pass, h=recess_d+0.02, $fn=32);
                translate([0,0,recess_d-plate_gap_z-csink_h])
                    cylinder(d1=screw_pass, d2=csink_d, h=csink_h+0.01, $fn=32);
            }
    }
}

// 当て板 2 枚を並べて出力
module cover_plates_parts() {
    for (i = [0 : len(cover_plates)-1]) {
        c = cover_plates[i];
        translate([i * (recess_w + 4), 0, 0])
            cover_plate_one(c[0], c[1], c[2]);
    }
}

// 組み付け位置で表示（確認用）
module cover_plates_in_place() {
    for (c = cover_plates) cover_plate_one(c[0], c[1], c[2]);
}

// ===== トッププレートの分割 =====
// キー列と平行（垂直から 15 度）に、左右対称の 2 本で 3 分割する。
// 分割線は列の穴の中心をきっちり通るので、継ぎ目を跨いだスイッチが
// 隣り合うピースを押さえる。中央ピースにはネジがないが、
// 自前のキースイッチ十数個が PCB のソケットに刺さって保持する。
//
// 右側のキー列の中心（Y=0 での X、実測）:
//   30.04 親指 / 43.16 メイン1列目 / 54.40 親指 / 61.79 メイン2列目
//   73.03 親指 / 80.43 メイン3列目 / 99.06 / 117.70
// 61.79 を選ぶ。43.16 と比べた実測:
//                       中央に完全に入るキー  継ぎ目で割れる  ウイング
//   cut=±43.16                2 個              6 個          28 個
//   cut=±61.79                8 個              8 個          20 個
// 中央ピースはネジがなく、完全に入るキーのスイッチだけで PCB に留まる。
// 43.16 だと親指キー 2 個しかなく、トラックパッド周りが頼りない。
// 寸法は 43.16 の最大 106mm に対し 61.79 は 129mm だが、
// 収縮 0.3% で 0.32mm 対 0.39mm。差は無視できる。
// 3 ピースとも回転なしで A1 mini に収まる。
//   ウイング 87.6 x 98.6 ／ 中央 129.2 x 105.3
// ウイングは左右対称なので実体は 1 種類。mirror で反転して使う。
plate_cut_x     = 61.79;  // 分割線が Y=0 を通る X（左右対称に ±）
plate_cut_angle = 15.0;   // 垂直からの傾き。上に行くほど中央側へ倒れる
plate_seam_gap  =  0.30;  // 継ぎ目の隙間（合計）。1 本あたり

// 分割線の外側（ウイング側）の半平面。side=+1 で右、-1 で左
module plate_halfplane(side) {
    translate([side * plate_cut_x, 0])
        rotate(side * plate_cut_angle)
            translate([0, -400]) square([800, 800]);
}

// 右ウイング
module clip_plate_wing_r() {
    intersection() {
        children();
        translate([0,0,-1]) linear_extrude(20)
            offset(delta = -plate_seam_gap/2) plate_halfplane(1);
    }
}
// 左ウイング
module clip_plate_wing_l() {
    intersection() {
        children();
        translate([0,0,-1]) linear_extrude(20)
            mirror([1,0,0]) offset(delta = -plate_seam_gap/2) plate_halfplane(1);
    }
}
// 中央
module clip_plate_center() {
    difference() {
        children();
        translate([0,0,-1]) linear_extrude(20)
            offset(delta = +plate_seam_gap/2) plate_halfplane(1);
        translate([0,0,-1]) linear_extrude(20)
            mirror([1,0,0]) offset(delta = +plate_seam_gap/2) plate_halfplane(1);
    }
}

// ===== USB ポート下の床の逃がし =====
// 壁の開口は usbport_w=12 で切ってあるが、床（offset(2) base_plate）は
// 残るのでケーブルのモールドが当たる。床の外縁は X=0..±3 で Y=65.60。
// そこから内側へ usb_relief_d だけ削る。
usb_relief_w  = 14.0;                    // 逃がし幅 (X)。壁開口 12 より片側 1 広く
usb_relief_d  =  5.0;                    // 外縁から内側へ削る量 (Y)
usb_floor_y   = 65.60;                   // 床の外縁 Y（実測）

module usb_floor_relief() {
    translate([-usb_relief_w/2, usb_floor_y - usb_relief_d, -0.01])
        cube([usb_relief_w, 30, cb + 0.02]);
}

// ===== ボス廃止分。スペーサーの通し穴 =====
module spacer_holes(lug) {
    if (lug > 0)
        place_all_lug_bosses(lug) {
            translate([0,0,-0.01])
                cylinder(d=screw_pass, h=cb+0.02, $fn=32);
            translate([0,0,-0.01])
                cylinder(d1=csink_d, d2=screw_pass, h=csink_h+0.01, $fn=32);
        }
}

// ===== 分割 =====
module clip_left()  {
    intersection() { children();
        translate([-300,-300,-100]) cube([300-seam_gap/2, 600, 200]); }
}
module clip_right() {
    intersection() { children();
        translate([seam_gap/2,-300,-100]) cube([300, 600, 200]); }
}

// ===== 足（T字・内側から差し込む） =====
// 使用時: フランジが床の内側、ステムが床を貫通して下に出る
// 印刷時: フランジを下（ビルドプレート）、ステムを上。張り出しなし
//
// 位置・太さは元の foot_specs をそのまま踏襲する。
// ノート PC のキーボードに合わせてあるので動かさないこと。
//   元: translate([0,2,0]) で
//       右 = translate([spec[0]+1, spec[1], spec[2]]) cube([30, ps, spec[3]])
//       左 = translate([-spec[0]-30-1, ...])
//   spec[1] は Y の下端。厚みは ps=1.6。
//   spec[2] = -2.4 / -4.4 が床下に出る量。
// 長さは中心を保ったまま縮む。接地位置は元と変わらない。
// 左右で長さを変えると片側だけキーの隙間から外れるので、必ず左右同値。
//
// フランジは非対称。前足の -Y 側は壁がすぐそこにあるため、
// 全長では入らない。中央だけタブを出して両側支持にする。
//   前足 Y=-18.5 断面の空洞  X 20.28..47.55
//   前足 Y=-19.9 断面の空洞  X 21.68..46.15  ← 中央タブはここに収まる
foot_flange_in  = 5.0;   // ステムから +Y 側への張り出し（全長）
foot_flange_out = 1.4;   // ステムから -Y 側への張り出し（中央タブのみ）
foot_tab_len    = 12.0;  // -Y 側タブの長さ (X)
foot_flange_t   = 1.5;   // フランジ厚 (Z)
foot_slot_gap   = 0.20;  // スリットのクリアランス（きつめ。抜け落ち防止）

// [元 spec[0], 元 spec[1] (Y下端), 床下に出る高さ, 長さ(X)]
//   手前: Y=-18.5 の断面で壁の内面が X 20.28..47.55（幅 27.3）。26 が上限
//   奥  : Y= 74.0 の断面で X 38.13..119.09。元の 30 のままで余裕
foot_specs_v2 = [
    [18, -18.5, 2.4, 26],
    [70,  74.0, 4.4, 30]
];

// 元の 30mm 時の中心。長さを変えてもここは動かない
function foot_cx(s, side) = side > 0 ? s[0] + 16 : -s[0] - 16;
function foot_x(s, side)  = foot_cx(s, side) - s[3]/2;
function foot_y(s)        = s[1] + 2;

// 床を貫通するスリット
module foot_slots() {
    for (s = foot_specs_v2)
        for (side = [1, -1])
            translate([foot_x(s, side) - foot_slot_gap/2,
                       foot_y(s)       - foot_slot_gap/2,
                       -0.01])
                cube([s[3] + foot_slot_gap,
                      ps   + foot_slot_gap,
                      cb + 0.02]);
}

// 足 1本。印刷姿勢のまま（フランジ下・ステム上）
// ステムは y=0..ps。接地面の太さは元と同じ ps
module foot_part(h, flen) {
    // フランジ本体（+Y 側・全長）
    translate([0, 0, 0])
        cube([flen, ps + foot_flange_in, foot_flange_t]);
    // -Y 側タブ（中央のみ）
    translate([(flen - foot_tab_len)/2, -foot_flange_out, 0])
        cube([foot_tab_len, foot_flange_out + 0.01, foot_flange_t]);
    // ステム
    translate([0, 0, foot_flange_t])
        cube([flen, ps, cb + h]);
}

// 足 4本を並べて出力
module feet_parts() {
    pitch = ps + foot_flange_in + foot_flange_out + 4;
    for (n = [0 : len(foot_specs_v2)-1])
        for (m = [0 : 1])
            translate([0, (n*2 + m) * pitch, 0])
                foot_part(foot_specs_v2[n][2], foot_specs_v2[n][3]);
}

// ===== 新しいボトム =====
// 事前の本体修正はファイル冒頭のコメントを参照
module bottom_case_v2(lug=0) {
    difference() {
        union() {
            bottom_case(lug=lug);
            joint_block();
        }
        joint_fasteners();
        spacer_holes(lug);
        foot_slots();
        usb_floor_relief();
    }
}


/*
 * 以下、実行する行のコメントを外す
 */

 /*
 * 元になる svg
 *   lug を渡すとネジ穴用の張り出しが付く。
 *   基板用は張り出し不要なので lug を渡さないこと。
 */
//edge_svg(lug=lug); // 穴なし。ボトムの元
//edge_svg(cut_mcu=true, cut_tp=true, cut_key=true, lug=0); // 基板と同じ外形。全部の穴空き
//translate([0,0,8.5]) top_cover_svg(lug=lug); // MCU は隠して、外周余白を持たす。top_cover の元

/*
 * 3Dプリンターでのケース印刷用
 */
//linear_extrude(ps) edge_svg(cut_mcu=true, cut_tp=true); // 基板と同じ外形。同じ厚さ。ケース設計時のダミー基板

translate([130,-10,0]) color("red") pedestal();

/*
 * v2 ボトム。SCAD 座標＝組み立て姿勢＝印刷姿勢。
 * rotate は掛けない。スライサーでもそのまま平置きする。
 */
color("blue") {
    clip_left()  bottom_case_v2(lug=lug);
    clip_right() bottom_case_v2(lug=lug);
    translate([10,100,0]) cover_plates_parts();      // 当て板 2 枚（印刷用に並べる）
    translate([-40,100,0]) feet_parts();              // T字足 4 本（印刷用に並べる）
}

/*
 * v2 トッププレート。外形クリアランスを広げたい場合は
 * 外形クリアランスは slop_fit で調整する（現在 0.4 = 片側 0.4mm）。
 * 3 ピースとも回転なしで A1 mini に収まる。
 */
color("green") translate([0,-140,0]) {
    clip_plate_wing_r() top_cover(lug=lug);
    clip_plate_wing_l() top_cover(lug=lug);
    clip_plate_center() top_cover(lug=lug);
}

/*
 * 組み付け確認用
 */
//bottom_case_v2(lug=lug);
//cover_plates_in_place();
