#coding=utf-8
from xml.dom import minidom
import cv2
import numpy as np
import os
import collections
import glob
doc = minidom.Document()
import skimage.morphology as sm
from scipy import misc
import matplotlib.pyplot as plt
import collections
from skimage import measure,data,color

#  =============================================*
thresh = 0.4 # 阈值
'''5
batch create xml
'''
heatmap_path_folders = '/mnt/data/home/cxl884/oro_tumor_detection_40x_patchwise_v2/KA_result/'
xml_save_folders = '/mnt/data/home/cxl884/oro_tumor_detection_40x_patchwise_v2/KA_result_xml/'
#  ==============================================
'''
Single image create xml
'''
heat_path = "/home/hjxu_disk/orcal/pred/evaluatation/Pred3/pred/JHU16_pred_2.jpg"
xml_save_path = "/home/hjxu_disk/orcal/pred/evaluatation/Pred2/JHU16_2_boundary.xml"

#  ================================================



def get_filename_from_path(file_path):
    path_tokens = file_path.split('/')
    filename = path_tokens[path_tokens.__len__() - 1].split('.')[0]
    return filename


def create_coordinate(Annotations,example):
    Annotation = doc.createElement("Annotation")
    Annotation.setAttribute("Name",example["Name"])
    Annotation.setAttribute("Type",example["Type"])
    Annotation.setAttribute("Prob", example["Prob"])
    Annotation.setAttribute("PartOfGroup","None")
    Annotation.setAttribute("Color", example["Color"])
    Annotations.appendChild(Annotation)
    Coordinates = doc.createElement("Coordinates")
    # Coordinates.setAttribute("Text",example["Text"])
    Annotation.appendChild(Coordinates)
    Coordinate1 = doc.createElement("Coordinate")
    Coordinate1.setAttribute("Order",example["Order1"])
    Coordinate1.setAttribute("X", example["X1"])
    Coordinate1.setAttribute("Y", example["Y1"])
    Coordinates.appendChild(Coordinate1)
    Coordinate2 = doc.createElement("Coordinate")
    Coordinate2.setAttribute("Order", example["Order2"])
    Coordinate2.setAttribute("X", example["X2"])
    Coordinate2.setAttribute("Y", example["Y2"])
    Coordinates.appendChild(Coordinate2)
    Coordinate3 = doc.createElement("Coordinate")
    Coordinate3.setAttribute("Order", example["Order3"])
    Coordinate3.setAttribute("X", example["X3"])
    Coordinate3.setAttribute("Y", example["Y3"])
    Coordinates.appendChild(Coordinate3)
    Coordinate4 = doc.createElement("Coordinate")
    Coordinate4.setAttribute("Order", example["Order4"])
    Coordinate4.setAttribute("X", example["X4"])
    Coordinate4.setAttribute("Y", example["Y4"])
    Coordinates.appendChild(Coordinate4)
    return Coordinates


def get_image_open(img_path):

    rgb_image = cv2.imread(img_path)
    # hsv -> 3 channel
    hsv = cv2.cvtColor(rgb_image, cv2.COLOR_BGR2HSV)
    lower_red = np.array([20, 20, 20])
    upper_red = np.array([200, 200, 200])
    # mask -> 1 channel
    mask = cv2.inRange(hsv, lower_red, upper_red)

    close_kernel = np.ones((20, 20), dtype=np.uint8)
    image_close = cv2.morphologyEx(np.array(mask), cv2.MORPH_CLOSE, close_kernel)
    open_kernel = np.ones((5, 5), dtype=np.uint8)
    image_open = cv2.morphologyEx(np.array(image_close), cv2.MORPH_OPEN, open_kernel)

    return image_open

def get_bbox(cont_img, rgb_image=None):
    _, contours, _ = cv2.findContours(cont_img, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    rgb_contour = None
    if rgb_image is not None:
        rgb_contour = rgb_image.copy()
        line_color = (255, 0, 0)  # blue color code
        cv2.drawContours(rgb_contour, contours, -1, line_color, 2)
    bounding_boxes = [cv2.boundingRect(c) for c in contours]
    return bounding_boxes, rgb_contour

def find_roi_bbox_tumor_gt_mask( mask_image):
    # mask = cv2.cvtColor(mask_image, cv2.COLOR_BGR2GRAY)
    bounding_boxes, _ = get_bbox(np.array(mask_image))
    return bounding_boxes


def build_xml(pred_path, xml_save_path, thresh=0.5):
    '''
    :param pred_path:　heatmap的路径
    :param xml_save_path:　保存的路径
    thresh: 阈值
    :return:
    '''
    # maks_path = '/home/hjxu_disk/orcal/pred/evaluatation/CCFOP5_pred.jpg'
    mask_image = np.array(cv2.imread(pred_path))[:, :, 1]

    doc = minidom.Document()
    ASAP_Annotation = doc.createElement("ASAP_Annotations")
    doc.appendChild(ASAP_Annotation)
    Annotations = doc.createElement("Annotations")
    ASAP_Annotation.appendChild(Annotations)

    bounding_boxes = find_roi_bbox_tumor_gt_mask(mask_image)

    for bounding_box in bounding_boxes:
        b_x_start = int(bounding_box[0])
        b_y_start = int(bounding_box[1])
        b_x_end = int(bounding_box[0]) + int(bounding_box[2])
        b_y_end = int(bounding_box[1]) + int(bounding_box[3])

        col_cords = np.arange(b_x_start, b_x_end)
        row_cords = np.arange(b_y_start, b_y_end)
        mag_factor = 256  # 滑动窗的大小
        count = 0

        for x in col_cords:
            for y in row_cords:
                prob = mask_image[y, x] / 255 * 1.0
                if int(mask_image[y, x]) > thresh * 255 :
                    # print count
                    WSI_x1 = x * mag_factor
                    WSI_y1 = y * mag_factor

                    WSI_x2 = WSI_x1 + mag_factor
                    WSI_y2 = WSI_y1

                    WSI_x3 = WSI_x1 + mag_factor
                    WSI_y3 = WSI_y1 + mag_factor

                    WSI_x4 = WSI_x1
                    WSI_y4 = WSI_y1 + mag_factor

                    d = collections.OrderedDict()

                    d["Id"] = str(count)
                    d["Name"] = "Annotation" + " " + str(count)
                    count = count + 1
                    d["Color"] = "#F4FA58"
                    d["Type"] = "Polygon"
                    d["Prob"] = str(prob)
                    d["Order1"] = "0"
                    d["X1"] = str(WSI_x1)
                    d["Y1"] = str(WSI_y1)
                    d["Order2"] = "1"
                    d["X2"] = str(WSI_x2)
                    d["Y2"] = str(WSI_y2)
                    d["Order3"] = "2"
                    d["X3"] = str(WSI_x3)
                    d["Y3"] = str(WSI_y3)
                    d["Order4"] = "3"
                    d["X4"] = str(WSI_x4)
                    d["Y4"] = str(WSI_y4)
                    create_coordinate(Annotations, d)
                    # example={"Name":"Annotation 0","Type":"Polygon","Color":"#F4FA58","Order1":"0","X1":"123","Y1":"123","Order2":"1","X2":"123","Y2":"123","Order3":"2","X3":"123","Y3":"123","Order4":"3","X4":"123","Y4":"123"}

    f = file(xml_save_path, "w")
    doc.writexml(f)
    f.close()

def create_boundary_xml(pred_path, save_xml, treshold=0.5):
    # pred_path = "/home/hjxu/camelyon17/createXML/Tumor_016_heatmap.jpg"
    npyImg = misc.imread(pred_path)
    img = npyImg > treshold*255
    dst = sm.closing(img, sm.disk(7))
    dst = sm.opening(img, sm.disk(7))
    # plt.imshow(img)
    # plt.imshow(dst)
    # plt.show()
    contours = measure.find_contours(img, 0.5)
    mag_factor = 256
    doc = minidom.Document()
    ASAP_Annotation = doc.createElement("ASAP_Annotations")
    doc.appendChild(ASAP_Annotation)
    Annotations = doc.createElement("Annotations")
    ASAP_Annotation.appendChild(Annotations)

    count = 0
    for i in range(len(contours)):
        Annotation = doc.createElement("Annotation")
        Annotation.setAttribute("Name", "_" + str(i))
        Annotation.setAttribute("Type", "Polygon")
        # Annotation.setAttribute("Prob", example["Prob"])
        Annotation.setAttribute("PartOfGroup", "None")
        Annotation.setAttribute("Color", "#F4FA58")
        Annotations.appendChild(Annotation)

        Coordinates = doc.createElement("Coordinates")
        # Coordinates.setAttribute("Text",example["Text"])
        Annotation.appendChild(Coordinates)
        for j in range(len(contours[i])):
            Coordinate1 = doc.createElement("Coordinate")
            Coordinate1.setAttribute("Order", str(j))
            Coordinate1.setAttribute("Y", str(contours[i][j, 0] * mag_factor + mag_factor))
            Coordinate1.setAttribute("X", str(contours[i][j, 1] * mag_factor))
            # Annotation.appendChild(Coordinate1)
            Coordinates.appendChild(Coordinate1)

    f = file(save_xml, "w")
    doc.writexml(f)
    f.close()

def batch_create_xml():

  #  heatmap_path_folders = '/home/hjxu_disk/orcal/pred/evaluatation/Pred1/'
  #  xml_save_folders = '/home/hjxu_disk/orcal/pred/evaluatation/xml_pred1'

    heat_paths = glob.glob(os.path.join(heatmap_path_folders, '*.jpg'))
    heat_paths.sort()
    for heat_img_path in heat_paths:  # 注意 这边的wsifolder是针对heatmap的
        print heat_img_path, "in processing "

        img_name = get_filename_from_path(heat_img_path)
        xml_save_path_name = xml_save_folders + '/' + img_name + '.xml'
        print xml_save_path_name, "in saving ..."

        build_xml(heat_img_path, xml_save_path_name)

def one_create_xml():
    print (heat_path, "in processing ")
    build_xml(heat_path, xml_save_path,thresh)
    print (xml_save_path, "in saving ...")

def one_create_xml_boundary():
    create_boundary_xml(heat_path, xml_save_path,thresh)

if __name__ == '__main__':
     batch_create_xml()
    #one_create_xml() #网格状
    # one_create_xml_boundary() # 边界,但是效果不好
