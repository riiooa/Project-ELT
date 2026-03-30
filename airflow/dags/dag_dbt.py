from airflow import DAG 
from datetime import datetime
from airflow.providers.docker.operators.docker import DockerOperator
from docker.types import Mount



default_args= {
    'owner': 'rio',
    'depends_on_past': False
}

dag = DAG(
    "dag_dbt",
    default_args = default_args,
    start_date = datetime(2025,11,29),
    catchup = False,
    schedule_interval = None
)

task_transforms_dbt = DockerOperator(
    task_id='transformation_using_dbt',
    image='ghcr.io/dbt-labs/dbt-postgres:1.4.7',
    command=[
        "run",
        "--profiles-dir",
        "/root",
        "--project-dir",
        "/dbt",
        "--full-refresh"
    ],
    auto_remove=True,
    # tty=True,
    docker_url="unix://var/run/docker.sock",
    network_mode="bridge",
    mounts=[
        Mount(source='D:/1ProjectPorto/project-elt/postgres_tranformasi',
              target='/dbt', type='bind'),
        Mount(source='C:/Users/Lenovo/.dbt', target='/root', type='bind'),
    ],
    dag=dag
)
