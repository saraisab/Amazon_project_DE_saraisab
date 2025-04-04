# CGP Amazon Sales Products Project 
## Overview

I’ve built an end-to-end data engineering project using a dataset from *Kaggle* on Amazon product sales. The goal was to extract, transform, and load (ETL) the data into BigQuery, enabling visualization through Looker Studio.

The dashboard I created focuses on two key aspects:

* Product Ratings – Comparison between ratings in different products.

* Price & Discount Comparisons – Examining pricing strategies and discounts across different products.

[Link to the dashboard in Looker Studio](https://lookerstudio.google.com/reporting/5acd6f02-165f-44d7-9016-b6ba0766aeb9)

![dashboard](https://github.com/saraisab/Amazon_project_DE_saraisab/blob/main/images/dashboard.jpg)

This project showcases the full data pipeline, from raw dataset ingestion to insightful visualizations.

## Tools 🛠️

I've worked with this tools in order to complete the project:
* **Terraform**: Configures the bucket in GCP (IaC) 🏗️ 
* **Docker**: Container to host the kestra platform. 🐳
* **Kestra**: Orchestration Platform 🔄
* **Google Cloud Platform**: ☁️
    - **Google Cloud Storage**: To host the data lake
    - **BigQuery**: As a data warehouse 
    - **Looker Studio**: Dashboards to visualize the data 
* **Python pandas**: Pipeline to clean the data ⚙️
* **DLT**: to upload the data cleaned to BigQuery 📥

![flowchart_project](https://github.com/saraisab/Amazon_project_DE_saraisab/blob/main/images/Flowchart.jpeg)

## Dataset 🎛️
The dataset I choose was: *Amazon Products Sales Dataset 2023* from Kaggle

Link here: [Amazon Products Sales Dataset 2023](https://www.kaggle.com/datasets/lokeshparab/amazon-products-dataset/code)

- Its product data are separated by 142 categories in csv format.
- Each csv files are consist of 10 columns and each row has products details accordingly
#### Features
| name             | description                                                    |
| ---------------- | -------------------------------------------------------------- |
| _name_           | The name of the product                                        |
| _main_category_  | The main category of the product belong                        |
| _sub_category_   | The main category of the product belong                        |
| _image_          | The image of the product look like                             |
| _link_           | The amazon website reference link of the product               |
| _ratings_        | The ratings given by amazon customers of the product           |
| _no of ratings_  | The number of ratings given to this product in amazon shopping |
| _discount_price_ | The discount prices of the product                             |
| _actual_price_   | The actual MRP of the product                                  |


----

## Steps to start running the Project 🚀

**Prerequisites**

To run this project you need to have installed these tools: Kestra, Terraform, Docker and an account in Google Cloud Platform. Moreover, I've used WSL in windows for Linux.

* Firstly: 
    * Copy to your directory the Terraform files. Change the key path if it is necessary. Execute these three commands separately:
   ```
    terraform init
    terraform plan
    terraform apply
    ```
* Secondly:
    * With docker working, write this in the subsystem Linux to start the Kestra platform:
    ```
    docker run --pull=always --rm -it -p 8080:8080 --user=root -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp kestra/kestra:latest server local
    ```
    To start the Kestra environment in your webserver type:
    http://localhost:8080
    * Import all the flows in the [Kestra_flows directory](https://github.com/saraisab/Amazon_project_DE_saraisab/tree/main/Kestra_flows) to your kestra environment.
    (Ensure to include your google cloud keys into the *project_zoomcamp.01_gcp_kv.yml* file)

* Thirdly:
    * Run the flow_controller.yml. This is going to:
        * Set the configuration file that manages Google Cloud Platform (GCP) key-value pairs. It is for manage the enviroment variables in Kestra.
        * Data ingestion: Download the datasets from kaggle, insert the raw csv files into the bucket previously created.  
        * ETL: Download the data from the datalake to clean and transform the data employing the pandas library from python. Besides, upload the data to BigQuery making use of the DLT resources in python.
* Finally:
    * Run the flow *project_zoomcamp.05_bigquery_querys.yml*. It needs the name of your dataset created by DLT as an input. It is going to be creating the data models. With this, new tables and views in BigQuery are going to be created, inserted and updated, which are necessary for the final dashboard. I have divided the data from one table into three to reduce data redundancy and make easier the data management. I have clustered the main table (amazon_products) in order to improve query performance, to reduce the number of scanned bytes for queries and for cost optimization. 

    ![Data_models](https://github.com/saraisab/Amazon_project_DE_saraisab/blob/main/images/sql_models.jpeg)

## Tests
* In kestra you can check the logs, if there exist any error, it will help you. Besides, in the flow_controller there are several "prints" to give information about the process running, you can check it in the logs.

* To test the data validation in BigQuery you can run these querys:
    * It'll tell you if there exist any null in the clustered table:
        ```sql
        SELECT 
            SUM(CASE WHEN no_of_ratings IS NULL THEN 1 ELSE 0 END) AS no_of_ratings_null,
            SUM(CASE WHEN ratings IS NULL THEN 1 ELSE 0 END) AS ratings_null,
            SUM(CASE WHEN discount_price IS NULL THEN 1 ELSE 0 END) AS discount_price_null,
            SUM(CASE WHEN actual_price IS NULL THEN 1 ELSE 0 END) AS actual_price_null
        FROM 
            `project_name.dataset_name.amazon_products_clustered`;
        ```

    * Query to guess the total number of the rows, *in my case it's 1.103.170*:
        ```sql
        SELECT 
            COUNT(*) AS Total_rows
        FROM 
            `project_name.dataset_name.amazon_products_clustered`;
        ```