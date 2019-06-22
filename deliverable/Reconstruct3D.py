import numpy as np
from scipy import optimize
from utils import direction_plane_intersection, angle_between_vector_plane

# Normalized vector in camera coordinates corresponding to point in pixel coordinates
def qnorm(u_px, v_px, u_0, v_0, f):
    q = np.array([(u_px - u_0), v_px - v_0, f])
    return q/np.linalg.norm(q)

# All arguments are 3D vectors
def corner_lambda_h_coeff(qm_norm, qn_norm, qh_norm, qa_norm):
    return np.dot(np.cross(qn_norm, qm_norm), qh_norm)/np.dot(np.cross(qn_norm, qm_norm), qa_norm) * qa_norm

# Vertex A of the table must be consecutive to both vertices B and C;
# H is the center of the table.
# vpx, vpy, uv* must be given in Euclidean pixel coordinates.
def find_projection_matrix(uv_princ, f, vpx, vpy, uva, uvb, uvc, uvh, table_area):
    def normalize(v):
        return v/np.linalg.norm(v)
    qm_norm = qnorm(*vpx, *uv_princ, f)
    qn_norm = qnorm(*vpy, *uv_princ, f)
    qz_norm = np.cross(qm_norm, qn_norm)
    R = np.column_stack((qm_norm, qn_norm, qz_norm))

    qh_norm = qnorm(*uvh, *uv_princ, f)
    qa_norm = qnorm(*uva, *uv_princ, f)
    qb_norm = qnorm(*uvb, *uv_princ, f)
    qc_norm = qnorm(*uvc, *uv_princ, f)

    ca = corner_lambda_h_coeff(qm_norm, qn_norm, qh_norm, qa_norm)
    cb = corner_lambda_h_coeff(qm_norm, qn_norm, qh_norm, qb_norm)
    cc = corner_lambda_h_coeff(qm_norm, qn_norm, qh_norm, qc_norm)

    lambda_h = np.sqrt(table_area/(np.linalg.norm(cb - ca)*np.linalg.norm(cc - ca)))
    t = lambda_h * qh_norm

    Rt = np.column_stack((R, t))
    return Rt #, ca*lambda_h, cb*lambda_h, cc*lambda_h

# rel_pos contains the relative positions of the markers on the pen.
# For numerical reasons, these positions must be given in centimeters.
# At the moment, rel_pos must be a list of length 3.
# noinspection PyTypeChecker
def find_marker_positions(markers, uv_princ, f, rel_pos, lambda_h):
    q_i = [qnorm(*uvm, *uv_princ, f) for uvm in markers]
    q1, q2, q3 = q_i
    l1, l2, l3 = rel_pos

    k12 = np.dot(q1, q2)
    k23 = np.dot(q2, q3)
    k31 = np.dot(q3, q1)

    d12 = l1-l2
    d23 = l2-l3
    d31 = l1-l3

    d122, d232, d312 = [d**2 for d in [d12, d23, d31]]
    def func(x):
        x1, x2, x3 = x
        return [x1**2 - 2*k12*x1*x2 + x2**2 - d122,
                x2**2 - 2*k23*x2*x3 + x3**2 - d232,
                x3**2 - 2*k31*x3*x1 + x1**2 - d312]
    lambda_i = optimize.fsolve(func, np.array([lambda_h, lambda_h, lambda_h]), xtol=1.49012e-12)/100
    p_i = np.array([l*q for l, q in zip(lambda_i, q_i)])
    return p_i

# This function calculates a signed distance between point `p` and plane `pl`,
# returning a posive result if the point and the origin are on different sides
# of the plane, a negative result otherwise.
def pen_tip_penetration(p, pl):
    lambda_p = np.linalg.norm(p)
    q = p/lambda_p
    ints, lambda_ints = direction_plane_intersection(q, pl)
    ints_angle = angle_between_vector_plane(q, pl)
    return (lambda_p - lambda_ints) * np.sin(ints_angle)
