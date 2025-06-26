import os
from src.datascience_project import logger
from sklearn.model_selection import train_test_split
import pandas as pd
from src.datascience_project.entity.config_entity import DataTransformationConfig
class DataTransformation:
    def __init__(self,config:DataTransformationConfig):
        self.config=config

    ## Note:you can add different data transformation techniques here

    def train_test_spliting(self):
        data=pd.read_csv(self.config.data_path)
        train_data,test_data=train_test_split(data)

        train_data.to_csv(os.path.join(self.config.root_dir,"train.csv"),index=False)
        test_data.to_csv(os.path.join(self.config.root_dir,"test.csv"),index=False)

        logger.info("Splitting data into training and testing sets")
        logger.info(f"Train data shape: {train_data.shape}")
        logger.info(f"Test data shape: {test_data.shape}")

        print(train_data.shape)
        print(test_data.shape)