"""
Set up a DAG to run an ETL using a bash script
"""
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta


default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2019, 7, 1),
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    # 'queue': 'bash_queue',
    # 'pool': 'backfill',
    # 'priority_weight': 10,
    # 'end_date': datetime(2016, 1, 1),
}

dag = DAG('basic_etl_v3', default_args=default_args, schedule_interval=timedelta(hours=1))

# DO try to load data before the DAG is loaded into Airflow
dag.catchup = True

t1 = BashOperator(
    task_id='download_observations',
    bash_command='/opt/etl/etl-download {{ ts }}',
    dag=dag)

t2 = BashOperator(
    task_id='convert_observations',
    bash_command='/opt/etl/etl-convert {{ ts }}',
    dag=dag)

t3 = BashOperator(
    task_id='upload_observations',
    bash_command='/opt/etl/etl-upload {{ ts }}',
    dag=dag)

t2.set_upstream(t1)
t3.set_upstream(t2)
