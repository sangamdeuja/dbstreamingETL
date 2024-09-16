# Project Description : Streaming ETL in Azure Databricks

<img src="images/Databricks_workflow.png" alt="Alt text" width="800"/>

The project implements the `ETL transformation` of raw data (CSV) into refined data. It uses the `medallion architecture`, which accesses streaming source data from the `raw_data` folder and loads it into the `bronze_layer` in `parquet` format. This data is then processed into the silver and gold layers. The transformation is done using `Databricks Delta Live Tables (DLT)`. In fact, DLT is used in the `Databricks pipeline`, which is `Task 2` of the `Databricks Job`, while `Task 1` is to mount the raw data source. This project also includes notebooks integration using `Github actions`. Databricks uses Azure app as service principle to mount your azure storage and write the files inside those folders
# Use this repo
* Make sure you have `azure cli` installed and configured and `terraform` installed. Terraform deploys the infrastructure via azure cli authentication.
* clone this repo
  ```
  git clone https://github.com/sangamdeuja/dbstreamingETL.git
  ```
* Create Azure `databricks workspace` using azure portal
* Install and configure `databricks cli`. Terraform will use databricks cli config for your default workspace.
* Export environment variables for your subscription, for mac or Linux based architecuture. Replace the value in below code.
  ```
  export TF_VAR_subscription_id=your_subscription_id
  ```
* If you have some experience setting up terraform variable and you don't want to use explicitly in code, feel free to do so. In my case, I have defaulted the storage account name in `var.tf` and containers, and folders name are hardcoded in `storage.tf`. If you don't have knowledge about terraform atleast change the storage account name to be unique.
* Modify the path of the repo in `databricks.tf` and also modify the `quartz_cron_expression` and push the code in your github.
* To enable Continuos Integration, go to your repo, settings, Secrets and variables, actions and create two repository secret `DATABRICKS_HOST` and `DATABRICKS_TOKEN`. Provide the databricks workspace url and databricks token as values to those secrets.
* Deploy the the infrastructure using terraform commands inside your local repo.
  ```
  terraform validate
  terraform plan
  terraform apply
  ```
* Upload the csv files from raw-data folder to your raw_data folder in azure using cli or using azure portal.
* Go to your databricks workspace and check the job runs,pipelines. You will see the running Jobs and pipeline.
