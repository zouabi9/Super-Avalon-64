// Super Avalon 64 - hexagonal storage tube with quest tracks and screw lid
//
// Each of the six faces is the quest track for one player count (5-10).
// Five round recesses run down the face from the lid end; the floor of each
// recess is engraved with that round's team size. Drop a Good (star) or Evil
// (flame) round marker into the recess when the quest is resolved.
// Round 4 for 7+ players has two dots under the number: it needs two Fails.
//
// Inside, from the bottom: a snug pocket for the 6 round markers, then the
// coin stack, then the female thread for the lid.
//
//   openscad -D 'part="tube"' -o tube.stl scad/tube.scad
//   openscad -D 'part="lid"'  -o lid.stl  scad/tube.scad   (exported plate-down, ready to print)
//   part = "assembly" shows the closed tube.

include <config.scad>

part = "assembly";

hex_d = tube_af / cos(30);     // across-corners diameter for cylinder($fn = 6)

module hex_prism(h) { cylinder(d = hex_d, h = h, $fn = 6); }

// Rounded single-start thread: a circle offset from the axis, twisted along z.
module thread_body(r, len) {
    linear_extrude(height = len, twist = -360 * len / thread_pitch,
                   slices = ceil(len / thread_pitch * 48), convexity = 4)
        translate([thread_e, 0]) circle(r, $fn = 96);
}

thread_base = tube_h - thread_len;

// Put 2D children flat on face i, `depth` mm into the wall, centred at height z.
// Text reads along the tube from the lid end towards the bottom.
module on_face(i, z, depth) {
    rotate([0, 0, 30 + 60 * i])
        translate([tube_af / 2 - depth, 0, z])
            multmatrix([[0, 0, 1, 0], [0, 1, 0, 0], [-1, 0, 0, 0]])
                linear_extrude(depth + 1) children();
}

function recess_z(j) = tube_h - label_zone - recess_gap - recess_d / 2 - j * (recess_d + recess_gap);

module face_cuts(i) {
    players = quest_table[i][0];
    teams   = quest_table[i][1];

    // player-count label in the top band
    on_face(i, tube_h - label_zone / 2, engrave_depth) {
        translate([0, 3]) text(str(players), size = 11, font = font_main, halign = "center", valign = "center");
        translate([0, -9]) text("PLAYERS", size = 3.2, font = font_main, halign = "center", valign = "center");
    }

    for (j = [0 : 4]) {
        // the recess
        rotate([0, 0, 30 + 60 * i])
            translate([tube_af / 2 - recess_depth, 0, recess_z(j)])
                rotate([0, 90, 0]) cylinder(d = recess_d, h = recess_depth + 1);
        // team size engraved in the recess floor
        on_face(i, recess_z(j), recess_depth + engrave_depth) {
            translate([0, 1]) text(str(teams[j]), size = recess_d * 0.5, font = font_main,
                                   halign = "center", valign = "center");
            if (j == two_fail_round && players >= two_fail_min_players)
                for (u = [-2.6, 2.6]) translate([u, -8.4]) circle(1.3);
        }
    }
}

module tube() {
    difference() {
        hex_prism(tube_h);
        // female thread
        translate([0, 0, thread_base]) thread_body(thread_r, thread_len + 0.01);
        // coin bore
        translate([0, 0, thread_base - coin_stack_h]) cylinder(d = bore_d, h = coin_stack_h + 1);
        // marker pocket
        translate([0, 0, thread_base - coin_stack_h - marker_pocket_h])
            cylinder(d = marker_pocket_d, h = marker_pocket_h + 0.5);
        for (i = [0 : 5]) face_cuts(i);
    }
}

// Lid modelled in its closed position, so it lines up with the hex when screwed home.
module lid_in_place() {
    difference() {
        union() {
            translate([0, 0, tube_h]) hex_prism(lid_plate);
            intersection() {
                translate([0, 0, thread_base]) thread_body(thread_r - thread_fit, thread_len);
                translate([0, 0, thread_base + 0.6]) cylinder(r = thread_r + 2, h = thread_len);
            }
        }
        // compass star on top
        translate([0, 0, tube_h + lid_plate - 0.6])
            linear_extrude(1) polygon([for (k = [0 : 15])
                let(a = 90 + k * 22.5, r = (k % 2 == 0) ? 12 : 4) [r * cos(a), r * sin(a)]]);
    }
}

if (part == "tube") tube();
else if (part == "lid") translate([0, 0, tube_h + lid_plate]) rotate([180, 0, 0]) lid_in_place();
else { tube(); color("SteelBlue") lid_in_place(); }
