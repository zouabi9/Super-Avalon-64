// Super Avalon 64 - hexagonal storage tube with quest tracks and screw lid
//
// Each of the six faces is the quest track for one player count (5-10).
// Five round recesses run down the face from the lid end; the floor of each
// recess is engraved with that round's team size. Press a round marker into the
// recess, GOOD (star) or EVIL (flame) side up, when the quest is resolved.
// Round 4 for 7+ players has two dots under the number: it needs two Fails.
//
// Inside, from the bottom: a snug pocket for the 5 round markers, then the
// coin stack, then the female thread for the lid.
//
//   openscad -D 'part="tube"' -o tube.stl scad/tube.scad
//   openscad -D 'part="lid"'  -o lid.stl  scad/tube.scad   (exported plate-down, ready to print)
//   part = "assembly" shows the closed tube.

include <config.scad>

part = "assembly";

hex_d = tube_af / cos(30);     // across-corners diameter for cylinder($fn = 6)

// Hexagon with across-flats `af`.
module hex2d(af) { circle(d = af / cos(30), $fn = 6); }

// Hex prism (across flats tube_af) with rounded long corners (tube_corner_r)
// and filleted bottom / top outer edges (rb / rt).
module rounded_hex_prism(h, rb, rt, steps = 8) {
    module slice(z, inset)
        translate([0, 0, z]) linear_extrude(0.01)
            offset(r = tube_corner_r, $fn = 32) hex2d(tube_af - 2 * tube_corner_r - 2 * inset);
    hull() {
        for (k = [0 : steps]) let(a = 90 * k / steps) {
            slice(rb - rb * cos(a), rb - rb * sin(a));
            slice(h - 0.01 - (rt - rt * cos(a)), rt - rt * sin(a));
        }
    }
}

// Ring that rounds the mouth of a round hole of radius r, `f` deep, axis along +z,
// with the surface at z = 0.
module hole_lip(r, f) {
    rotate_extrude($fn = 96)
        polygon(concat([[0, -f - 0.01], [r, -f - 0.01]],
                       [for (a = [180 : -10 : 90]) [r + f + f * cos(a), -f + f * sin(a)]],
                       [[r + f, 0.01], [0, 0.01]]));
}

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
        // rounded mouth of the recess
        rotate([0, 0, 30 + 60 * i])
            translate([tube_af / 2, 0, recess_z(j)])
                rotate([0, 90, 0]) hole_lip(recess_d / 2, recess_lip_r);
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
        rounded_hex_prism(tube_h, tube_end_r, lid_seam_r);
        // female thread
        translate([0, 0, thread_base]) thread_body(thread_r, thread_len + 0.01);
        // coin bore
        translate([0, 0, thread_base - coin_stack_h]) cylinder(d = bore_d, h = coin_stack_h + 1);
        // marker pocket
        translate([0, 0, thread_base - coin_stack_h - marker_pocket_h])
            cylinder(d = marker_pocket_d, h = marker_pocket_h + 0.5);
        for (i = [0 : 5]) face_cuts(i);
        // name on the base, mirrored so it reads correctly when you look at the bottom
        translate([0, 0, -0.01]) linear_extrude(bottom_text_depth + 0.01) mirror([1, 0])
            text("AVALON", size = tube_af * 0.16, font = font_main, halign = "center", valign = "center");
    }
}

// Lid modelled in its closed position, so it lines up with the hex when screwed home.
module lid_in_place() {
    difference() {
        union() {
            translate([0, 0, tube_h]) rounded_hex_prism(lid_plate, lid_seam_r, tube_end_r);
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
