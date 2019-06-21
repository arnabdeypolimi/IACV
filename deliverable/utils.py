import numpy as np

# Computes a homogeneous line vector from the rho, theta parameters
# returned by SKImage's Hough transform.
def homline(rho, theta):
    return [np.cos(theta), np.sin(theta), -rho]

def homintersect(l1, l2):
    p = np.cross(l1, l2)
    if p[2] != 0:
        p = p/p[2]
    return p

def hom2eucl(v):
    assert(v[-1] != 0), f"Point at infinity {v} does not have an Euclidean correspondent!"
    return v[:-1]/v[-1]

def eucl2hom(v):
    return np.append(v, 1)

def hom2eucl_multi(vv):
    return vv[:, :-1]/vv[:, -1][:, None]

def norm_coordinates(v, normf):
    res = np.copy(v)
    res[0:2] = res[0:2]/normf
    return res

def norm_coordinates_multi(vv, normf):
    res = np.copy(vv)
    res[:, 0:2] = res[:, 0:2]/normf
    return res

# v should be a 3D vector
# p should be of the form [a, b, c, d]
def angle_between_vector_plane(v, pl):
    return np.pi/2 - np.arccos(np.abs(np.dot(v, pl[:3]))/(np.linalg.norm(v)*np.linalg.norm(pl[:3])))

def direction_plane_intersection(q, pl):
    assert(np.dot(pl[:3], q) != 0), "Plane and direction are parallel!"
    lambda_ = -pl[3]/np.dot(pl[:3], q)
    return lambda_*q, lambda_
