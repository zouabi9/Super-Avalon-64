// Super Avalon 64 - coins
//
// Every coin has a raised front (artwork + rim, all at the same height so coins
// stack flat) and a shared debossed back, so coins of the same kind are
// indistinguishable face-down. Pause at the layer where the relief starts
// (coin_t - relief_h) to swap filament for two-colour coins.
//
// Pieces: merlin, percival, assassin, morgana, mordred, oberon (1 each),
// loyal_servant (print 6), minion (print 4), lady_of_the_lake (1),
// loyalty_good (1), loyalty_evil (1), success (5), fail (5),
// marker (5): two-sided round marker, star + GOOD on top, flame + EVIL underneath.
//
// Render one coin from the command line, e.g.
//   openscad -D 'part="merlin"' -o merlin.stl scad/coins.scad
// part = "all" lays out one of every design for previewing.

include <config.scad>

part = "all";

// ============================================================ helpers

// Text bent along a circle. Bottom arcs read left-to-right with letters
// upright; top arcs likewise.
module arc_text(str, r, size, top = false, spacing = 0.68) {
    n = len(str);
    step = (size * spacing) / r * 180 / PI;   // degrees per character
    span = step * (n - 1);
    for (i = [0 : n - 1]) {
        a = top ? 90 + span / 2 - i * step : -90 - span / 2 + i * step;
        rotate(a) translate([r, 0])
            rotate(top ? -90 : 90)
                text(str[i], size = size, font = font_arc,
                     halign = "center", valign = "center");
    }
}

module star2d(r_out, r_in, points = 5) {
    polygon([for (i = [0 : 2 * points - 1])
        let(a = 90 + i * 180 / points, r = (i % 2 == 0) ? r_out : r_in)
        [r * cos(a), r * sin(a)]]);
}

module ring2d(r_out, w) { difference() { circle(r_out); circle(r_out - w); } }

module teardrop2d(r, h) { hull() { circle(r); translate([0, h]) circle(0.01); } }

// ============================================================ icons (2D, roughly 16 mm box)

module icon_wizard_hat() {          // Merlin
    polygon([[-6.5, -2], [6.5, -2], [2.2, 3.5], [-1.5, 8.5], [-0.6, 3.5]]);
    translate([0, -2.6]) scale([1, 0.28]) circle(8.2);
    translate([4.2, 6.2]) star2d(1.8, 0.75);
    translate([-5.2, 3.6]) star2d(1.3, 0.55);
}

module shield_shape(w = 12, h = 14) {
    hull() {
        translate([-w / 2, h / 2 - 1]) square([w, 1]);
        translate([0, -h / 2]) circle(0.6);
        translate([-w / 2 + 2, -h / 6]) circle(2);
        translate([w / 2 - 2, -h / 6]) circle(2);
    }
}

module icon_shield_star() {         // Percival
    difference() {
        shield_shape();
        offset(-1.3) shield_shape();
    }
    translate([0, 0.6]) star2d(3.8, 1.6);
}

module icon_sword_up() {            // Loyal Servant
    polygon([[-1.2, -2], [1.2, -2], [1.2, 6.5], [0, 8.6], [-1.2, 6.5]]);   // blade
    translate([-5, -3.4]) square([10, 1.6]);                              // guard
    translate([-0.9, -7.2]) square([1.8, 4]);                             // grip
    translate([0, -7.8]) circle(1.4);                                     // pommel
}

module icon_dagger() {              // Assassin
    rotate(-35) {
        polygon([[-1.3, -1], [1.3, -1], [0.7, 6], [0, 8.2], [-0.7, 6]]);
        translate([-3.6, -2.4]) square([7.2, 1.4]);
        translate([-0.8, -6]) square([1.6, 3.8]);
        translate([0, -6.4]) circle(1.2);
    }
    translate([4.5, -5.5]) teardrop2d(1.4, 3.2);   // drop
}

module icon_crescent() {            // Morgana
    difference() {
        circle(7.5);
        translate([3.2, 1.6]) circle(6.6);
    }
    translate([4.3, -3.2]) star2d(2.4, 1.0);
}

module icon_crown() {               // Mordred
    polygon([[-7, -4], [7, -4], [7, 4], [4.6, 0.6], [2.3, 5.5],
             [0, 1], [-2.3, 5.5], [-4.6, 0.6], [-7, 4]]);
    translate([-7, -6.2]) square([14, 1.4]);
    translate([-2.3, 6.4]) circle(1);
    translate([2.3, 6.4]) circle(1);
}

module icon_blind_eye() {           // Oberon
    difference() {
        intersection() {
            translate([0, -5]) circle(9);
            translate([0, 5]) circle(9);
        }
        intersection() {
            translate([0, -5]) circle(7.8);
            translate([0, 5]) circle(7.8);
        }
    }
    circle(2.4);
    rotate(35) square([18, 1.4], center = true);
}

module icon_hood() {                // Minion of the dark
    difference() {
        hull() {
            translate([0, 7]) circle(0.8);
            translate([-6.5, -5]) circle(1.5);
            translate([6.5, -5]) circle(1.5);
        }
        hull() {
            translate([0, 2.5]) circle(1);
            translate([-3.4, -4.5]) circle(1.2);
            translate([3.4, -4.5]) circle(1.2);
        }
    }
    translate([-1.6, -1.6]) circle(0.9);
    translate([1.6, -1.6]) circle(0.9);
}

module wave(y, w = 15, amp = 0.9, th = 1.1) {
    // a wavy band built from short hulled segments
    pts = [for (x = [-w / 2 : 0.5 : w / 2]) [x, y + amp * sin(x * 60)]];
    for (i = [0 : len(pts) - 2])
        hull() { translate(pts[i]) circle(th / 2); translate(pts[i + 1]) circle(th / 2); }
}

module icon_lady() {                // Lady of the Lake: sword rising from water
    translate([0, 1.5]) scale(0.82) icon_sword_up();
    wave(-3.6);
    wave(-6.4, 12);
}

module icon_flame() {
    translate([0, -3.4]) {          // centred on the origin, like the other icons
        teardrop2d(4.6, 12);
        translate([-3.6, -2.2]) rotate(28) teardrop2d(2.4, 6.5);
        translate([3.6, -2.2]) rotate(-28) teardrop2d(2.4, 6.5);
    }
}

module icon_star() { star2d(8, 3.4); }

module goblet() {
    intersection() {                                 // cup
        translate([0, 4]) circle(6);
        translate([-7, 1]) square([14, 7.2]);
    }
    translate([-6, 7.2]) square([12, 1.2]);          // lip
    translate([-0.9, -4]) square([1.8, 5.5]);        // stem
    translate([0, -5]) scale([1, 0.35]) circle(4.6); // foot
}

module icon_goblet() { translate([0, -1.5]) goblet(); }

module icon_broken_goblet() {
    translate([0, -1.5]) difference() {
        goblet();
        polygon([[-0.6, 9], [0.6, 9], [1.6, 5.5], [-0.4, 3], [1.2, 0], [0.6, -7],
                 [-0.6, -7], [0, 0], [-1.6, 3], [0.4, 5.5]]);
    }
}

// ============================================================ designs

// [part id, icon module name, bottom text, top text]
designs = [
    ["merlin",         "wizard_hat",    "MERLIN",        "GOOD"],
    ["percival",       "shield_star",   "PERCIVAL",      "GOOD"],
    ["loyal_servant",  "sword_up",      "LOYAL SERVANT", "GOOD"],
    ["assassin",       "dagger",        "ASSASSIN",      "EVIL"],
    ["morgana",        "crescent",      "MORGANA",       "EVIL"],
    ["mordred",        "crown",         "MORDRED",       "EVIL"],
    ["oberon",         "blind_eye",     "OBERON",        "EVIL"],
    ["minion",         "hood",          "MINION",        "EVIL"],
    ["lady_of_the_lake","lady",         "LADY OF THE LAKE", ""],
    ["success",        "goblet",        "SUCCESS",       "QUEST"],
    ["fail",           "broken_goblet", "FAIL",          "QUEST"],
];

module icon(name) {
    if      (name == "wizard_hat")    icon_wizard_hat();
    else if (name == "shield_star")   icon_shield_star();
    else if (name == "sword_up")      icon_sword_up();
    else if (name == "dagger")        icon_dagger();
    else if (name == "crescent")      icon_crescent();
    else if (name == "crown")         icon_crown();
    else if (name == "blind_eye")     icon_blind_eye();
    else if (name == "hood")          icon_hood();
    else if (name == "lady")          icon_lady();
    else if (name == "flame")         icon_flame();
    else if (name == "star")          icon_star();
    else if (name == "goblet")        icon_goblet();
    else if (name == "broken_goblet") icon_broken_goblet();
}

// Shared back: a ring and an eight-point compass star, debossed.
module back_pattern(r) {
    ring2d(r - 1.6, 0.9);
    star2d(r * 0.42, r * 0.14, 8);
}

// Disc with a small chamfer on the bed side.
// Disc of diameter d and height h with filleted outer edges (bottom radius rb, top rt).
module rounded_disc(d, h, rb, rt) {
    R = d / 2;
    rotate_extrude($fn = $fn)
        hull() {
            square([0.01, h]);
            square([R - rb, 0.01]);
            translate([0, h - 0.01]) square([R - rt, 0.01]);
            translate([R - rb, rb]) circle(rb, $fn = 24);
            translate([R - rt, h - rt]) circle(rt, $fn = 24);
        }
}

module coin_body(d, t, show_back = true) {
    base_t = t - relief_h;
    difference() {
        // full-height disc with rounded outer edges, hollowed inside the rim
        rounded_disc(d, t, coin_fillet, min(coin_fillet, relief_h));
        translate([0, 0, base_t]) cylinder(r = d / 2 - rim_w, h = t);
        if (show_back)
            translate([0, 0, -0.01]) linear_extrude(back_depth + 0.01) back_pattern(d / 2);
    }
}

module front_relief(t) {
    translate([0, 0, t - relief_h - 0.01]) linear_extrude(relief_h + 0.01) children();
}

module coin(icon_name, bottom_txt, top_txt) {
    r = coin_d / 2;
    k = coin_d / 32;                 // artwork was drawn for a 32 mm coin; scale to fit
    long = len(bottom_txt) > 9;
    tr = r - rim_w - 2.6 * k;        // radius of the curved text
    coin_body(coin_d, coin_t);
    front_relief(coin_t) {
        translate([0, 0.6 * k])
            scale(0.95 * k) icon(icon_name);
        arc_text(bottom_txt, tr, (long ? 2.9 : 3.4) * k);
        if (top_txt != "") arc_text(top_txt, tr, 3.0 * k, top = true, spacing = 0.75);
    }
}

// Round markers for the quest track on the tube: star = Good won the round, flame = Evil won.
// Loyalty coins for the Lady of the Lake: the side is spelled out big in the middle.
module loyalty_coin(good) {
    r = coin_d / 2;
    k = coin_d / 32;
    coin_body(coin_d, coin_t);
    front_relief(coin_t) {
        translate([0, 6.8 * k]) scale(0.42 * k) if (good) icon_star(); else icon_flame();
        translate([0, -1.2 * k]) text(good ? "GOOD" : "EVIL", size = 5.4 * k, font = font_main,
                                      halign = "center", valign = "center");
        arc_text("LOYALTY", r - rim_w - 2.6 * k, 3.4 * k);
    }
}

// Round marker artwork for one face.
module marker_face2d(good) {
    ring2d(marker_d / 2 - 0.9, 0.8);
    translate([0, 4.2]) scale(0.55) if (good) icon_star(); else icon_flame();
    translate([0, -5.2]) text(good ? "GOOD" : "EVIL", size = 4, font = font_main,
                              halign = "center", valign = "center");
}

// Two-sided round marker: star + GOOD engraved on top, flame + EVIL on the bottom
// (mirrored so it reads correctly when flipped). Engraving both faces means it
// prints flat with no supports; fill the engraving with paint for contrast.
module marker() {
    difference() {
        rounded_disc(marker_d, marker_t, coin_fillet, coin_fillet);
        translate([0, 0, marker_t - marker_deboss])
            linear_extrude(marker_deboss + 0.01) marker_face2d(true);
        translate([0, 0, -0.01])
            linear_extrude(marker_deboss + 0.01) mirror([1, 0]) marker_face2d(false);
    }
}

module make_part(p) {
    if (p == "marker") marker();
    else if (p == "loyalty_good") loyalty_coin(true);
    else if (p == "loyalty_evil") loyalty_coin(false);
    else for (dsg = designs) if (dsg[0] == p) coin(dsg[1], dsg[2], dsg[3]);
}

// ============================================================ output

// "art" = flat 2D layout of the front artwork, for quick previews.
module art2d(p) {
    projection(cut = true)
        translate([0, 0, -(coin_t - relief_h / 2)])
            make_part(p);
}

if (part == "art") {
    ids = concat([for (dsg = designs) dsg[0]], ["loyalty_good", "loyalty_evil"]);
    for (i = [0 : len(ids) - 1])
        translate([(i % 4) * (coin_d + 4), -floor(i / 4) * (coin_d + 4)])
            art2d(ids[i]);
    // both faces of the round marker
    n = len(ids);
    for (k = [0, 1])
        translate([((n + k) % 4) * (coin_d + 4), -floor((n + k) / 4) * (coin_d + 4)])
            { ring2d(marker_d / 2, 0.4); marker_face2d(k == 0); }   // engraved areas shown solid
} else if (part == "all") {
    ids = concat([for (dsg = designs) dsg[0]], ["loyalty_good", "loyalty_evil", "marker"]);
    for (i = [0 : len(ids) - 1])
        translate([(i % 6) * (coin_d + 4), -floor(i / 6) * (coin_d + 4), 0])
            make_part(ids[i]);
} else {
    make_part(part);
}
