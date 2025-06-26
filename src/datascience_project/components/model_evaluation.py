import os
import pandas as pd
from sklearn.metrics import mean_squared_error,mean_absolute_error,r2_score
from urllib.parse import urlparse
import mlflow
import mlflow.sklearn
import mlflow.pyfunc
import numpy as np
import joblib
from pathlib import Path
from src.datascience_project.entity.config_entity import ModelEvaluationConfig
from src.datascience_project.utils.common import save_json
import logging
import os
# os.environ["MLFLOW_TRACKING_URI"]="https://dagshub.com/jagadeshchilla/datascienceProject.mlflow"
# os.environ["MLFLOW_TRACKING_USERNAME"]="jagadeshchilla"
# os.environ["MLFLOW_TRACKING_PASSWORD"]="your_dagshub_token_here"

class SklearnModelWrapper(mlflow.pyfunc.PythonModel):
    """
    Wrapper class for sklearn models to work with MLflow pyfunc
    This avoids the DagsHub compatibility issues with sklearn.log_model
    """
    def __init__(self, model):
        self.model = model
    
    def predict(self, context, model_input):
        return self.model.predict(model_input)

class ModelEvaluation:
    def __init__(self,config:ModelEvaluationConfig):
        self.config=config

    def eval_metrics(self,actual,pred):
        rmse=np.sqrt(mean_squared_error(actual,pred))
        mae=mean_absolute_error(actual,pred)
        r2=r2_score(actual,pred)
        return rmse,mae,r2
    
    def register_model_manually(self, run_id, model_name="ElasticNetModel"):
        """
        Manually register a logged model - alternative to registered_model_name parameter
        """
        try:
            model_uri = f"runs:/{run_id}/model"
            mlflow.register_model(model_uri, model_name)
            logging.info(f"Model registered successfully as {model_name}")
            return True
        except Exception as e:
            logging.warning(f"Failed to register model: {str(e)}")
            logging.info("You can register the model manually through DagsHub UI")
            return False
    
    def log_into_mlflow(self):

        test_data=pd.read_csv(self.config.test_data_path)
        model=joblib.load(self.config.model_path)

        test_x=test_data.drop(columns=[self.config.target_column],axis=1)
        test_y=test_data[self.config.target_column]


        mlflow.set_registry_uri(self.config.mlflow_uri)
        tracking_url_type_store=urlparse(mlflow.get_tracking_uri()).scheme

        with mlflow.start_run() as run:
            predicted_qualities=model.predict(test_x)
            (rmse,mae,r2)=self.eval_metrics(test_y,predicted_qualities)

            #saving metrics as local directory
            save_json(path=Path(self.config.root_dir)/self.config.metric_file_name,
                      data={"rmse":rmse,"mae":mae,"r2":r2})
            
            #mlflow tracking
            mlflow.log_params(self.config.all_params)
            mlflow.log_metric("rmse",rmse)
            mlflow.log_metric("mae",mae)
            mlflow.log_metric("r2",r2)
            
            # Use pyfunc approach - most compatible with DagsHub
            try:
                # Create wrapper for the sklearn model
                wrapped_model = SklearnModelWrapper(model)
                
                # Log using pyfunc - this is the most compatible approach with DagsHub
                mlflow.pyfunc.log_model(
                    artifact_path="model",
                    python_model=wrapped_model,
                    # Add conda environment to ensure reproducibility
                    conda_env={
                        'channels': ['defaults'],
                        'dependencies': [
                            'python=3.8',
                            'scikit-learn',
                            'numpy',
                            'pandas'
                        ]
                    }
                )
                
                logging.info("Model logged successfully using pyfunc approach")
                
                # Try to register model manually after logging
                run_id = run.info.run_id
                self.register_model_manually(run_id)
                
            except Exception as e:
                logging.error(f"Failed to log model using pyfunc: {str(e)}")
                
                # Fallback: Just log model artifacts manually using joblib
                try:
                    import tempfile
                    
                    # Save model as joblib file and log as artifact
                    with tempfile.NamedTemporaryFile(suffix='.joblib', delete=False) as f:
                        joblib.dump(model, f.name)
                        model_path = f.name
                    
                    mlflow.log_artifact(model_path, "model")
                    logging.info("Model saved as joblib artifact (fallback method)")
                    
                    # Clean up temporary file
                    os.unlink(model_path)
                    
                except Exception as e2:
                    logging.error(f"All model logging methods failed: {str(e2)}")
                    logging.info("Metrics and parameters are still tracked successfully")
                