#!/bin/bash

databricks notebooks run --notebook-path "/Repos/sangamdeuja/dbstreamingETL/mountcontainer.ipynb"

# Step 3: Use Databricks CLI to run the etlpipeline.ipynb notebook
databricks notebooks run --notebook-path "/Repos/sangamdeuja/dbstreamingETL/deltapipeline.ipynb"