from flask import Flask, request, jsonify
import torch
import torchvision.transforms as transforms
from PIL import Image
import pickle
import os
from flask_cors import CORS
import function
import base64
from datetime import datetime

app = Flask(__name__)
CORS(app)  
with open('face_color_model.pkl', 'rb') as f:
    fc, transform = pickle.load(f)
@app.route('/facecolor', methods=['POST'])
def facecolor():
    try:
        data = request.get_json()
        if 'image' not in data:
            return jsonify({'error': 'No image provided'}), 400
        image_data = base64.b64decode(data['image'])
        image_path = 'temp_image.jpg'
        with open(image_path, 'wb') as img_file:
            img_file.write(image_data)
        date=data['dob']
        date_obj = datetime.strptime(date, "%Y-%m-%d")
        month= date_obj.month    # Month as integer
        day = date_obj.strftime("%d")
        #day = date_obj.strftime("%d")   

        print(f"Month: {month}")
        print(f"Day: {day}")
        sign=function.zodiac_sign(month,day)
        print(sign)
        # Predict color
        predicted_color = function.predict_face_color(image_path)
        predicted_face_color = function.detect_and_analyze_face_color(image_path)
        predicted_lip_color = function.detect_and_analyze_lip_color_kmeans(image_path)
        predicted_color_zodiac=function.get_lucky_color(sign)
        
        

        if os.path.exists(image_path):
            os.remove(image_path)
        return jsonify({'predicted_color': predicted_color}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/')
def hello_world():
    return 'Hello World'

# main driver function
if __name__ == '__main__':
    app.run(debug=True)
