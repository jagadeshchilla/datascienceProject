from src.datascience_project.config.configuration import ConfigurationManager
from src.datascience_project.components.model_evaluation import ModelEvaluation
from src.datascience_project import logger

STAGE_NAME="Model Evaluation stage"

class ModelEvaluationTrainingPipeline:
    def __init__(self):
        pass

    def main(self):
        config=ConfigurationManager()
        model_evaluation_config=config.get_model_evaluation_config()
        model_evaluation=ModelEvaluation(config=model_evaluation_config)
        model_evaluation.log_into_mlflow()

if __name__=="__main__":
    try:
        logger.info(f">>>>>> stage {STAGE_NAME} started <<<<<<")
        obj=ModelEvaluationTrainingPipeline()
        obj.main()
        logger.info(f">>>>>> stage {STAGE_NAME} completed <<<<<<\n\nx==========x")
    except Exception as e:
        logger.exception(e)
        raise e