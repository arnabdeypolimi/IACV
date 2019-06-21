import os, sys
import numpy as np
import skimage

from utils import (
    hom2eucl, hom2eucl_multi,
    angle_between_vector_plane,
    norm_coordinates, norm_coordinates_multi
)
from VPDetection import find_table, vps_corners_and_center_from_tablemask
from IntrinsicsFromVPs import calculate_intrinsics
from Reconstruct3D import (
    find_projection_matrix,
    find_marker_positions,
    pen_tip_penetration
)
from MarkerDetection import detect_markers

if (len(sys.argv) != 4):
    print("Usage: python3 main.py path/to/calibration/pics path/to/pic/without/marker path/to/pic/with/marker")
    exit(1)

debug = False

if debug:
    from matplotlib import pyplot as plt

dirname = sys.argv[1].rstrip("/")
nomarkerpicname = sys.argv[2]
markerpicname = sys.argv[3]

vpxs = []
vpys = []
normf = 1000
table_area = 0.06237
hues = np.array([0.2055555556, 0.08611111111, 0.8888888889])
# The first marker is the furthest from the tip
rel_pos = [(17.7+16.3)/2, (10+8.8)/2, (3+1.2)/2]

nomarker_res = None
if "outs.csv" in os.listdir(dirname):
    with open(f"{dirname}/outs.csv") as inf:
        inlines = inf.read().splitlines()
    uv_princ = np.array(inlines[0].split(",")).astype("float")
    f = float(inlines[1])
    nomarker_res = np.array([l.split(",") for l in inlines[2:]]).astype("float")
else:
    picnames = [name for name in os.listdir(dirname) if name[-3:] in ["jpg", "JPG", "png", "PNG"]]
    for picname in picnames:
        pic = skimage.io.imread(f"{dirname}/{picname}")
        tablemask = find_table(pic, closure=16, cannysigma=1)
        vpd_res = vps_corners_and_center_from_tablemask(tablemask, cannysigma=0.1)
        if f"{dirname}/{picname}" == nomarkerpicname:
            nomarker_res = np.array(vpd_res)
        vpx, vpy, A, B, C, D = vpd_res
        if debug:
            plt.figure(picname)
            plt.imshow(pic)
            plt.plot(*vpx[:2], 'rx', *vpy[:2], 'rx')
            plt.plot(*A[:2], 'bo', *B[:2], 'bo', *C[:2], 'bo')
        vpxs += [ norm_coordinates(hom2eucl(vpx), normf) ]
        vpys += [ norm_coordinates(hom2eucl(vpy), normf) ]
    if debug:
        plt.show()
    uv_princ, f = calculate_intrinsics(vpxs, vpys)
    with open(f"{dirname}/outs.csv", "w") as outf:
        outf.write(",".join([str(x) for x in uv_princ])+"\n")
        outf.write(f"{f}\n")
        outf.writelines(",".join([str(f) for f in res])+"\n" for res in nomarker_res)

vpx, vpy, uva, uvb, uvc, uvh = norm_coordinates_multi(hom2eucl_multi(nomarker_res), normf)
Rt = find_projection_matrix(uv_princ, f, vpx, vpy, uva, uvb, uvc, uvh, table_area)
table_plane = np.append(Rt[:,2], -np.dot(Rt[:,2], Rt[:,3]))

markerpic = skimage.io.imread(markerpicname)
uv_markers = norm_coordinates_multi(detect_markers(markerpic, hues), normf)

mpos = find_marker_positions(uv_markers, uv_princ, f, rel_pos)
tip_direction = (mpos[2] - mpos[0])/np.linalg.norm(mpos[2] - mpos[0])
tip_position = mpos[0] + tip_direction*rel_pos[0]
print("Pen tip penetration: ", pen_tip_penetration(tip_position, table_plane))
print("Angle between pen and table: ", angle_between_vector_plane(tip_direction, table_plane))
