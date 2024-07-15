#!/usr/bin/env python
# coding: utf-8

# In[10]:


import torch
import torch.nn as nn
import torchvision.models as models
import torchvision.transforms as transforms
from PIL import Image


def predict_face_color(image_path):

    # Define the FaceColorModel class (same as before)
    class FaceColorModel(nn.Module):
        def __init__(self):
            super(FaceColorModel, self).__init__()
            self.resnet = models.resnet18(pretrained=True)  # Download and load weights automatically
            num_ftrs = self.resnet.fc.in_features
            self.resnet.fc = nn.Identity()  # remove the original fully connected layer
            self.fc = nn.Linear(num_ftrs, 3)  # add a new fully connected layer for face color prediction

        def forward(self, x):
            x = self.resnet(x)
            x = self.fc(x)
            return x

    # Define a transform to preprocess the input image
    transform = transforms.Compose([
        transforms.Resize(224),  # Resize to 224x224
        transforms.CenterCrop(224),  # Center crop to 224x224
        transforms.ToTensor(),  # Convert to tensor
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])  # Normalize
    ])

    # Load the image using PIL
    img = Image.open(image_path)

    # Preprocess the image
    img_tensor = transform(img)

    # Add a batch dimension (required for PyTorch models)
    img_tensor = img_tensor.unsqueeze(0)

    # Create an instance of the FaceColorModel
    model = FaceColorModel()

    # Pass the image through the FaceColorModel
    output = model(img_tensor)

    # Convert the output tensor to a hexadecimal string
    predicted_color = output.detach().numpy()[0]
    hex_color_undertone = '#{:02x}{:02x}{:02x}'.format(int(predicted_color[0] * 255), int(predicted_color[1] * 255), int(predicted_color[2] * 255))

    # Print the predicted color
    print('Predicted face color:', hex_color_undertone)

    return hex_color_undertone  # Optionally return the predicted color

print(predict_face_color("hi2.jpg"))
# In[11]:


import cv2
import numpy as np


def detect_and_analyze_face_color(image_path):


    # Load the image
    img = cv2.imread(image_path)
    if img is None:
        raise FileNotFoundError('Image file not found.')

    # Convert the image to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Load the Haar cascade for face detection
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    if face_cascade.empty():
        raise IOError('Failed to load Haar cascade.')

    # Detect faces in the image
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)

    if len(faces) == 0:
        print("No face detected in the image.")
        return None

    # Iterate through the detected faces (assuming only one face for now)
    for (x, y, w, h) in faces:
        # Extract the face region
        face_region = img[y:y+h, x:x+w]

        # Reshape the face region to a 2D array of pixels
        pixels = face_region.reshape(-1, 3)
        pixels = np.float32(pixels)

        # Define criteria and apply K-means clustering
        criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 100, 0.2)
        k = 2  # Number of clusters
        _, labels, centers = cv2.kmeans(pixels, k, None, criteria, 10, cv2.KMEANS_RANDOM_CENTERS)

        # Find the dominant color
        dominant_color = centers[np.argmax(np.bincount(labels.flatten()))]

        # Convert the dominant color to a hexadecimal string
        hex_color_face = '#{:02x}{:02x}{:02x}'.format(int(dominant_color[2]), int(dominant_color[1]), int(dominant_color[0]))

        print('Dominant face color:', hex_color_face)
        return hex_color_face  # Return the dominant face color


# In[12]:


import cv2
import numpy as np


def detect_and_analyze_lip_color_kmeans(image_path):

    # Load the image
    img = cv2.imread(image_path)
    if img is None:
        raise FileNotFoundError('Image file not found.')

    # Convert the image to YCbCr color space (better for skin segmentation)
    ycrcb = cv2.cvtColor(img, cv2.COLOR_BGR2YCR_CB)

    # Define the skin color range in YCbCr space (adjust based on your needs)
    lower_skin = np.array([0, 133, 77], dtype=np.uint8)
    upper_skin = np.array([255, 173, 127], dtype=np.uint8)

    # Create a mask for skin pixels
    mask = cv2.inRange(ycrcb, lower_skin, upper_skin)

    # Erode and dilate the mask to reduce noise (optional)
    kernel = np.ones((3, 3), np.uint8)
    mask = cv2.erode(mask, kernel, iterations=1)
    mask = cv2.dilate(mask, kernel, iterations=1)

    # Find contours of skin regions
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Find the largest contour (assuming face is the largest skin region)
    largest_contour = max(contours, key=cv2.contourArea)

    # Extract the face region using the mask and largest contour
    face_region = cv2.bitwise_and(img, img, mask=mask)
    x, y, w, h = cv2.boundingRect(largest_contour)
    face_region = face_region[y:y+h, x:x+w]

    # Reshape the face region to a 2D array of pixels
    pixels = face_region.reshape(-1, 3)
    pixels = np.float32(pixels)

    # Define criteria and apply K-means clustering for color segmentation (adjust K value)
    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 100, 0.2)
    k = 3  # Number of clusters (adjust this based on image complexity)
    _, labels, centers = cv2.kmeans(pixels, k, None, criteria, 10, cv2.KMEANS_RANDOM_CENTERS)

    # Find the index of the cluster with the most pixels (likely the dominant color)
    dominant_color_index = np.argmax(np.bincount(labels.flatten()))

    # Get the average color of the dominant cluster
    avg_color = centers[dominant_color_index]

    # Convert the average color to a hexadecimal string
    hex_color_lip = '#{:02x}{:02x}{:02x}'.format(int(avg_color[2]), int(avg_color[1]), int(avg_color[0]))

    print('Average lip color (using K-means):', hex_color_lip)
    return hex_color_lip

from datetime import date
def zodiac_sign(Month,Day):


    if ((int(Month)==12 and int(Day) >= 22)or(int(Month)==1 and int(Day)<= 19)):
        Signo_Zodiacal = ("\n Capricorn")
    elif ((int(Month)==1 and int(Day) >= 20)or(int(Month)==2 and int(Day)<= 17)):
            zodiac_sign = ("\n aquarius")
    elif ((int(Month)==2 and int(Day) >= 18)or(int(Month)==3 and int(Day)<= 19)):
            zodiac_sign = ("\n Pices")
    elif ((int(Month)==3 and int(Day) >= 20)or(int(Month)==4 and int(Day)<= 19)):
            zodiac_sign = ("\n Aries")
    elif ((int(Month)==4 and int(Day) >= 20)or(int(Month)==5 and int(Day)<= 20)):
            zodiac_sign = ("\n Taurus")
    elif ((int(Month)==5 and int(Day) >= 21)or(int(Month)==6 and int(Day)<= 20)):
            zodiac_sign = ("\n Gemini")
    elif ((int(Month)==6 and int(Day) >= 21)or(int(Month)==7 and int(Day)<= 22)):
            zodiac_sign = ("\n Cancer")
    elif ((int(Month)==7 and int(Day) >= 23)or(int(Month)==8 and int(Day)<= 22)):
            zodiac_sign = ("\n Leo")
    elif ((int(Month)==8 and int(Day) >= 23)or(int(Month)==9 and int(Day)<= 22)):
            Signo_Zodiacal = ("\n Virgo")
    elif ((int(Month)==9 and int(Day) >= 23)or(int(Month)==10 and int(Day)<= 22)):
            zodiac_sign = ("\n Libra")
    elif ((int(Month)==10 and int(Day) >= 23)or(int(Month)==11 and int(Day)<= 21)):
            zodiac_sign = ("\n Scorpio")
    elif ((int(Month)==11 and int(Day) >= 22)or(int(Month)==12 and int(Day)<= 21)):
            zodiac_sign = ("\n Sagittarius")

    return(zodiac_sign)
lucky_colors = {
    'capricorn': 'Black',
    'aquarius': 'Blue',
    'pisces': 'Sea Green',
    'aries': 'Red',
    'taurus': 'Green',
    'gemini': 'Yellow',
    'cancer': 'Silver',
    'leo': 'Gold',
    'virgo': 'Navy Blue',
    'libra': 'Pink',
    'corpio': 'Maroon',
    'agittarius': 'Purple'
}

def get_lucky_color(sign):
    sign = sign.lower().strip()
    color=lucky_colors[sign]
    print(f"The lucky color for {sign} is {color}")
    return color