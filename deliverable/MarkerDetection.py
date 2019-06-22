import skimage, numpy as np, numpy.ma as ma, scipy.ndimage
import skimage.morphology
from skimage.measure import regionprops
import skimage.feature
from MinimumBoundingBox import MinimumBoundingBox

def detect_markers(markerpic, hues, hue_threshold = 0.035,
                                    sat_threshold = 0.4,
                                    val_threshold = 0.5,
                                    closure_radius = 5):
    smoothpic = skimage.filters.gaussian(markerpic, sigma=3, multichannel=True)
    hsvmarker = skimage.color.rgb2hsv(smoothpic)
    satmask = hsvmarker[:,:,1] > sat_threshold
    valmask = hsvmarker[:,:,2] > val_threshold
    # This is to account for the circularity of hues
    huedists = [np.minimum(1 - np.abs(hsvmarker[:,:,0] - hue), np.abs(hsvmarker[:,:,0] - hue)) for hue in hues]
    huemasks = [huedist < hue_threshold for huedist in huedists]

    # A closing is used to remove highlights in the tags
    disk = skimage.morphology.disk(closure_radius)
    hsvmasks = [skimage.morphology.binary_closing(huemask & satmask & valmask, selem=disk) for huemask in huemasks]
    # # regionprops is not very efficient but this is just a PoC.
    # centroids = np.array([regionprops(hsvmask.astype(int))[0].centroid for hsvmask in hsvmasks])
    # # The centroids are returned in i,j coordinates, we need to swap them
    # centroids = centroids[:,[1,0]]
    maskpointclouds = [[(u, v) for ((v, u), val) in np.ndenumerate(hsvmask) if val] for hsvmask in hsvmasks]
    try:
        bbcenters = [MinimumBoundingBox(points).rectangle_center for points in maskpointclouds]
    except:
        return [[0, 0], [0, 0], [0, 0]]
    return bbcenters
