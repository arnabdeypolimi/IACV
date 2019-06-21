import numpy as np

def calculate_intrinsics(vv1, vv2):
    def middle(x1, y1, x2, y2):
        dx = x2 + x1
        dy = y2 + y1
        x = dx / 2
        y = dy / 2
        return (x, y)

    def distance(x1, y1, x2, y2):
        dx = x2 - x1
        dy = y2 - y1
        dis = np.sqrt(dx * dx + dy * dy)
        return dis

    A = []
    b = []
    for i in range(0, len(vv1) - 1):
        x_i, y_i = middle(vv1[i][0], vv1[i][1], vv2[i][0], vv2[i][1])
        x_j, y_j = middle(vv1[i + 1][0], vv1[i + 1][1], vv2[i + 1][0], vv2[i + 1][1])
        r_i = distance(vv1[i][0], vv1[i][1], x_i, y_i)
        r_j = distance(vv1[i + 1][0], vv1[i + 1][1], x_j, y_j)
        A += [[2 * (x_j - x_i),
               2 * (y_j - y_i)]]
        b += [np.square(x_j) - np.square(x_i) + np.square(y_j) - np.square(y_i) + np.square(r_i) - np.square(r_j)]
    w = np.linalg.lstsq(A, b, rcond=None)
    pri = w[0]
    f = np.sqrt(r_j * r_j - (pri[0] - x_j) * (pri[0] - x_j) - (pri[1] - y_j) * (pri[1] - y_j))

    return pri, f
