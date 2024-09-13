data "databricks_current_user" "me" {
}

resource "databricks_repo" "repo" {
  url  = "https://github.com/sangamdeuja/dbstreamingETL.git"
  path = "/Repos/sangamdeuja/dbstreamingETL"

}

# Create a Databricks secret scope
resource "databricks_secret_scope" "azure_creds_scope" {
  name = "azure-creds-scope"
}

resource "databricks_secret" "app_id_secret" {
  key          = "app_id"
  string_value = azuread_application.etl_app.client_id # Value for the secret from a variable
  scope        = databricks_secret_scope.azure_creds_scope.name
}

# Store the tenant_id in the secret scope
resource "databricks_secret" "tenant_id_secret" {
  key          = "tenant_id"
  string_value = data.azurerm_client_config.current.tenant_id # Value for the secret from a variable
  scope        = databricks_secret_scope.azure_creds_scope.name
}

# Store the client_secret in the secret scope
resource "databricks_secret" "client_secret" {
  key          = "client_secret"
  string_value = azuread_service_principal_password.etl_sp_password.value # Value for the secret from a variable
  scope        = databricks_secret_scope.azure_creds_scope.name
}

resource "databricks_secret" "storage-secret" {
  key          = "storage_account_name"
  string_value = var.storage_account_name # Value for the secret from a variable
  scope        = databricks_secret_scope.azure_creds_scope.name
}

data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

/*resource "databricks_notebook" "notebook_1" {
  path = "${data.databricks_current_user.me.home}/Repos/sangamdeuja/dbstreamingETL/mountcontainer"
}

resource "databricks_notebook" "notebook_2" {
  path = "${data.databricks_current_user.me.home}/Repos/sangamdeuja/dbstreamingETL/deltapipeline"
}*/


# To run the mounting code and to check the files generated by etl Pipelines
resource "databricks_cluster" "mycluster" {
  cluster_name            = "Allpurpose"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 20
  init_scripts {
    workspace {
      destination = "/Repos/sangamdeuja/dbstreamingETL/pipeline_scripts/test.sh"
    }
  }
  spark_conf = {
    # Single-node
    "spark.databricks.cluster.profile" = "singleNode"
    "spark.master"                     = "local[*]"

  }
  spark_env_vars = {
    STORAGE_ACCOUNT_NAME = databricks_secret.storage-secret.string_value
    APP_ID               = databricks_secret.app_id_secret.string_value
    TENANT_ID            = databricks_secret.tenant_id_secret.string_value
    CLIENT_SECRET        = databricks_secret.client_secret.string_value

  }
  cluster_log_conf {
    dbfs {
      destination = "dbfs:/cluster-logs"
    }
  }

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }
  depends_on = [
    databricks_repo.repo
  ]
}




/*resource "databricks_pipeline" "pipeline" {
  name        = "pipeline"
  development = true
  continuous  = true
  target      = "hive_metastore"

  cluster {
    label       = "default"
    num_workers = 1
    custom_tags = {
      cluster_type = "default"
    }
  }

  library {
    notebook {
      path = "/Repos/sangamdeuja/dbstreamingETL/deltapipeline"
    }
  }
  depends_on = [databricks_repo.repo, azurerm_role_assignment.etl_blob_contributor, databricks_job.etl-job]
}

/*resource "databricks_job" "etl-job" {
  name = "ETL_Job"
  job_cluster {
    job_cluster_key = "a"
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest_lts.id
      node_type_id  = data.databricks_node_type.smallest.id
    }
  }
  task {
    task_key        = "mount_storage"
    job_cluster_key = "a"
    notebook_task {
      notebook_path = "/Repos/sangamdeuja/dbstreamingETL/mountcontainer" # Path to the mounting notebook
    }
  }
  task {
    task_key        = "streaming_etl"
    job_cluster_key = "a"
    depends_on {
      task_key = "mount_storage"
    }

    notebook_task {
      notebook_path = "/Repos/sangamdeuja/dbstreamingETL/deltapipeline"
    }
  }
  schedule {
    quartz_cron_expression = "0 1 * * * ?"
    timezone_id            = "US/Eastern"

  }
}*/

