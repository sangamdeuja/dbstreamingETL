#!/bin/bash

pip install databricks-cli


databricks configure --token <<-EOF
$DATABRICKS_HOST
$DATABRICKS_TOKEN
EOF


databricks runs submit --json '{
  "tasks": [
    {
      "task_key": "notebook-task",
      "notebook_task": {
        "notebook_path": "/Repos/sangamdeuja/dbstreamingETL
/mountcontainer.ipynb"
      },
      "existing_cluster_id": "'"$DB_CLUSTER_ID"'"
    }
  ]
}'
