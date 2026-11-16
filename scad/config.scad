// Super Avalon 64 - shared parameters (all sizes in mm)
// Change values here and re-run scripts/export.sh to regenerate every STL.

$fn = 96;

// ---------- Fonts ----------
font_main = "Liberation Sans:style=Bold";   // numbers / labels on the tube
font_arc  = "Liberation Mono:style=Bold";   // curved coin text (even spacing looks right on an arc)

// ---------- Main coins (roles + Lady of the Lake) ----------
coin_d      = 38;    // diameter
coin_t      = 3.0;   // total thickness (base + raised relief)
relief_h    = 0.6;   // height of the raised front artwork and rim (colour-swap layer)
rim_w       = 1.2;   // width of the raised rim on the front
back_depth  = 0.4;   // depth of the debossed back pattern
coin_fillet  = 0.6;  // radius of the rounded outer edges on coins and markers

// ---------- Round markers (two-sided: star + GOOD / flame + EVIL) ----------
// Sit in the quest-track recesses on the outside of the tube, flip to the winning side.
marker_d      = 26;
marker_t      = 3.0;
marker_deboss = 0.6;   // depth of the artwork engraved into each face

// ---------- How many of each piece the full 5-10 player set needs ----------
// 6 special roles (Merlin, Percival, Assassin, Morgana, Mordred, Oberon)
// + 6 Loyal Servants + 4 Minions, so a 10-player game works with no specials at all.
n_special = 6;
n_loyal   = 6;
n_minion  = 4;
n_roles   = n_special + n_loyal + n_minion;   // 16
n_lady    = 1;
n_loyalty = 2;   // 1 Good + 1 Evil loyalty coin, shown to the Lady of the Lake
n_quest   = 10;  // 5 Success + 5 Fail secret quest coins (a team is at most 5)
n_markers = 5;   // one two-sided marker per round

// ---------- Hexagonal storage tube ----------
fit_clearance = 0.5;              // radial gap between coin and bore: no jamming, coins tip out freely
bore_d        = coin_d + 2*fit_clearance;
tube_af       = 54.6;             // outer size across flats (wide enough for the quest-track recesses)
tube_wall     = (tube_af - bore_d) / 2;  // wall thickness at the middle of each face
tube_side     = tube_af / sqrt(3);        // width of one face

// Quest-track recesses (one column of 5 per face)
recess_d      = marker_d + 0.3;   // snug: marker presses in and stays put
recess_depth  = marker_t;         // marker sits flush with the face
engrave_depth = 0.8;              // depth of the team-size number below the recess floor
recess_gap    = 5;                // gap between recesses along the face
label_zone    = 26;               // top band of each face: player count with the evil count under it
track_len     = 5 * recess_d + 6 * recess_gap;
tube_floor    = 3;                // solid material under the marker pocket
bottom_text_depth = 0.8;          // depth of the AVALON engraving on the base

// Inside: a snug marker pocket at the bottom, the coin stack above it, then the thread.
marker_pocket_d = marker_d + 0.4;
marker_pocket_h = n_markers * marker_t + 0.4;
coin_stack_h    = (n_roles + n_lady + n_loyalty + n_quest) * coin_t + 0.6;

// Screw lid. The thread is a twisted off-centre circle: a rounded single-start
// thread that prints without supports and needs no library.
thread_len    = 12;               // engaged length
thread_pitch  = 5;
thread_e      = 0.8;              // eccentricity = half the thread depth
thread_r      = bore_d / 2 + thread_e + 0.2;   // keeps the thread's narrowest point wider than the bore
thread_fit    = 0.3;              // radial clearance between male and female thread
lid_plate     = 4;

// Rounded exterior edges
tube_corner_r = 2.0;              // the six long corners of the hex
tube_end_r    = 1.5;              // top and bottom outer edges of the tube, top of the lid
lid_seam_r    = 0.8;              // where lid and tube meet (small, so the seam stays tidy)
recess_lip_r  = 0.6;              // rounded mouth of each quest-track recess

// Depth of the cavity measured from the top of the tube
cavity_h = thread_len + coin_stack_h + marker_pocket_h;

// Long enough for the quest track and for everything stored inside.
tube_h = max(label_zone + track_len, cavity_h + tube_floor);

// Team sizes per round, per player count (standard 5-10 player table).
// Round 4 needs two Fail coins to fail when playing with 7 or more.
quest_table = [
  [5,  [2, 3, 2, 3, 3]],
  [6,  [2, 3, 4, 3, 4]],
  [7,  [2, 3, 3, 4, 4]],
  [8,  [3, 4, 4, 5, 5]],
  [9,  [3, 4, 4, 5, 5]],
  [10, [3, 4, 4, 5, 5]],
];
// Evil players (Minions of Mordred, specials included) for each player count.
function evil_count(players) = [2, 2, 3, 3, 3, 4][players - 5];

two_fail_round = 3;     // index of round 4
two_fail_min_players = 7;
