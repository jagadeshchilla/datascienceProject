from src.datascience_project.config.configuration import ConfigurationManager
from src.datascience_project.components.data_tranformation import DataTransformation
from src.datascience_project import logger
from pathlib import Path


STAGE_NAME="Data Transformation stage"
class DataTransformationTrainingPipeline:
    def __init__(self):
        pass
    def intiate_data_transformation(self):
        try:
            with open(Path("artifacts/data_validation/status.txt"),"r") as f:
                status=f.read().split(" ")[-1]
            if status=="True":
                config=ConfigurationManager()
                data_transformation_config=config.get_data_transformation_config()
                data_transformation=DataTransformation(config=data_transformation_config)
                data_transformation.train_test_spliting()
            else:
                raise Exception("Data Validation stage not completed")
        except Exception as e:
            raise e

if __name__=="__main__":
    try:
        logger.info(f">>>>>> stage {STAGE_NAME} started <<<<<<")
        obj=DataTransformationTrainingPipeline()
        obj.intiate_data_transformation()
        logger.info(f">>>>>> stage {STAGE_NAME} completed <<<<<<\n\nx==========x")
    except Exception as e:
        logger.exception(e)
        raise e