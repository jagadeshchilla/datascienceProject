from flask import Flask,request,render_template
import os
import numpy as np
import pandas as pd
from src.datascience_project.pipeline.prediction_pipeline import PredictionPipeline

app=Flask(__name__)

@app.route('/',methods=['GET'])
def homepage():
    return render_template('index.html')

@app.route('/health',methods=['GET'])
def health_check():
    return {"status": "healthy", "service": "wine-quality-prediction"}, 200

@app.route('/train',methods=['GET'])
def training():
    os.system("python main.py")
    return "Training completed successfully!"

@app.route('/predict',methods=['POST','GET'])
def index():
    if request.method=='POST':
        try:
            fixed_acidity=float(request.form['fixed_acidity'])
            volatile_acidity=float(request.form['volatile_acidity'])
            citric_acid=float(request.form['citric_acid'])
            residual_sugar=float(request.form['residual_sugar'])
            chlorides=float(request.form['chlorides'])
            free_sulfur_dioxide=float(request.form['free_sulfur_dioxide'])
            total_sulfur_dioxide=float(request.form['total_sulfur_dioxide'])
            density=float(request.form['density'])
            pH=float(request.form['pH'])
            sulphates=float(request.form['sulphates'])
            alcohol=float(request.form['alcohol'])

            data=[fixed_acidity,volatile_acidity,citric_acid,residual_sugar,chlorides,free_sulfur_dioxide,total_sulfur_dioxide,density,pH,sulphates,alcohol]
            data=np.array(data).reshape(1,11)
            prediction_pipeline=PredictionPipeline()
            prediction=prediction_pipeline.predict(data)
            
            # Extract the actual number from the prediction array
            prediction_value = float(prediction[0]) if len(prediction) > 0 else 0.0
            
            return render_template('results.html',prediction=round(prediction_value, 2))
        except Exception as e:
            print(f"Prediction error: {e}")  # Log the actual error
            return render_template('results.html',prediction="Error: Unable to make prediction. Please check your input values.")
    else:
        return render_template('index.html')
    
if __name__=="__main__":
    app.run(host='0.0.0.0',port=8080,debug=True)