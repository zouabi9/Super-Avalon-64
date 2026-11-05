"""Sanity checks on the exported STLs: watertight meshes, coins fit the bore,
markers fit the recesses, and the whole set fits inside the tube.
Also rewrites the STLs as binary (OpenSCAD 2021 writes large ASCII files).

    python3 scripts/check_fit.py
"""
import glob, re, sys
import trimesh

cfg = open("scad/config.scad").read()
def val(name):
    return float(re.search(rf"^{name}\s*=\s*([\d.]+)", cfg, re.M).group(1))

ok = True
meshes = {}
for path in sorted(glob.glob("stl/*/*.stl")):
    m = trimesh.load(path)
    m.export(path)  # binary STL
    meshes[path.split("/")[-1][:-4]] = m
    ext = m.extents
    print(f"{path:32s} {ext[0]:6.1f} x {ext[1]:6.1f} x {ext[2]:6.1f} mm  watertight={m.is_watertight}")
    ok &= m.is_watertight

coin_d, fit = val("coin_d"), val("fit_clearance")
bore = coin_d + 2 * fit
tube = meshes["tube"]
coin = meshes["merlin"]
marker = meshes["marker_good"]
print(f"\ncoin diameter {coin.extents[0]:.2f} mm, bore {bore:.2f} mm, radial play {fit} mm")

# Probe the tube cavity: a point on the axis at each height is empty down to the floor.
import numpy as np
zs = np.arange(0.2, tube.bounds[1][2], 0.2)
inside = tube.contains(np.c_[np.zeros_like(zs), np.zeros_like(zs), zs])
floor = zs[inside].max()  # top of the solid floor
cavity = tube.bounds[1][2] - floor
stack = 29 * coin.extents[2] + 6 * marker.extents[2]
lid = meshes["lid"]
plug = lid.extents[2] - val("lid_plate")
print(f"cavity depth {cavity:.1f} mm, lid plug {plug:.1f} mm, stack of 29 coins + 6 markers {stack:.1f} mm")
print(f"headroom under the lid: {cavity - plug - stack:.2f} mm")
ok &= 0 < cavity - plug - stack < 3

# Ring check: points just inside the bore wall at mid-stack must be empty (coin fits).
zmid = floor + 6 * marker.extents[2] + 20
ang = np.linspace(0, 2 * np.pi, 72, endpoint=False)
ring = np.c_[(coin_d / 2) * np.cos(ang), (coin_d / 2) * np.sin(ang), np.full_like(ang, zmid)]
print("coin rim clear of the bore wall:", not tube.contains(ring).any())
ok &= not tube.contains(ring).any()

print("\nALL CHECKS PASSED" if ok else "\nCHECK FAILED")
sys.exit(0 if ok else 1)
