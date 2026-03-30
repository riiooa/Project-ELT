# 🔄 Project ELT – Automated Data Pipeline with Airflow & dbt

This project implements a production-style **ELT (Extract, Load, Transform)** pipeline that moves data from a source PostgreSQL database to a destination PostgreSQL database, then applies transformations using **dbt**. The entire pipeline is orchestrated with **Apache Airflow** and containerized with **Docker Compose**.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Docker Network                        │
│                                                              │
│  ┌──────────────┐    ┌──────────────────┐                   │
│  │source_postgres│──▶│dump_and_load_    │                   │
│  │  (port 5433) │    │  data.py         │                   │
│  │              │    │  (pg_dump +      │                   │
│  │  - customers │    │   psql)          │                   │
│  │  - products  │    └────────┬─────────┘                   │
│  │  - transaction│            │                              │
│  │    _items    │             ▼                              │
│  └──────────────┘   ┌──────────────────┐                   │
│                     │dest_postgres     │                    │
│                     │  (port 5434)     │                    │
│                     └────────┬─────────┘                   │
│                              │                              │
│                              ▼                              │
│                     ┌─────────────────┐                    │
│                     │  dbt (Docker)   │                    │
│                     │ Transformations │                    │
│                     └─────────────────┘                    │
│                                                             │
│  ┌──────────────────────────────────────┐                  │
│  │           Apache Airflow              │                  │
│  │  ┌───────────────┐  ┌─────────────┐  │                  │
│  │  │dag_load_and_  │  │  dag_dbt    │  │                  │
│  │  │transfer.py    │  │  .py        │  │                  │
│  │  │(weekly cron)  │  │ (manual)    │  │                  │
│  │  └───────────────┘  └─────────────┘  │                  │
│  └──────────────────────────────────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔁 ELT Flow

### Step 1 — Extract & Load (`dag_load_and_transfer`)
- Runs **every Sunday at 01:00 UTC** (`0 1 * * 0`)
- Uses `pg_dump` to dump the full `source_db` into a SQL file
- Uses `psql` to load the dump into `destination_db`
- Executed via `dump_and_load_data.py` as a subprocess inside Airflow

### Step 2 — Transform (`dag_dbt`)
- Triggered **manually** after the load step
- Spins up a **dbt Docker container** (`dbt-postgres:1.4.7`)
- Runs dbt models defined in the `postgres_tranformasi/` directory
- Uses `--full-refresh` to rebuild all models from scratch

---

## 📁 Project Structure

```
project-elt/
├── airflow/
│   └── dags/
│       ├── dag_load_and_transfer.py   # DAG: weekly EL from source to destination
│       └── dag_dbt.py                 # DAG: run dbt transformations
│
├── data_source/
│   └── init_weekly.sql                # SQL to initialize source DB schema
│
├── elt_script/
│   └── dump_and_load_data.py          # Script: pg_dump → psql transfer
│
├── postgres_tranformasi/              # dbt project (models, profiles, etc.)
├── dbt-env/                           # Python virtual environment for dbt
├── logs/                              # Airflow logs
├── .gitignore
└── compose.yml                        # Docker Compose — all services
```

---

## ⚙️ Tech Stack

| Technology | Version | Role |
|---|---|---|
| Apache Airflow | 2.9.2 | Pipeline orchestration & scheduling |
| PostgreSQL | 13 | Source & destination databases + Airflow metadata DB |
| dbt (dbt-postgres) | 1.4.7 | SQL-based data transformation |
| Docker Compose | v3 | Multi-container environment |
| Python | 3.x | Scripting (dump, load, DAG logic) |
| pg_dump / psql | — | Database dump and restore utility |

---

## 🗄️ Source Database Schema

Defined in `data_source/init_weekly.sql` and auto-initialized on container startup:

```sql
-- Customers
customers (customer_id, name, email, city)

-- Products
products (product_id, product_name, price, stock)

-- Transactions
transaction_items (item_id, customer_id, product_id, quantity, transaction_date)
```

---

## 🐳 Services (Docker Compose)

| Service | Image | Port | Description |
|---|---|---|---|
| `source_postgres` | postgres:13 | 5433 | Source database, auto-seeded with `init_weekly.sql` |
| `destination_postgres` | postgres:13 | 5434 | Destination database, receives dumped data |
| `postgres` | postgres:13 | — | Airflow metadata database |
| `init-airflow` | airflow:2.9.2 | — | One-time Airflow DB init & admin user creation |
| `webserver` | airflow:2.9.2 | 8080 | Airflow Web UI |
| `scheduler` | airflow:2.9.2 | — | Airflow task scheduler |

All services communicate over the `elt_network` bridge network.

---

## 🚀 Getting Started

### Prerequisites
- [Docker](https://www.docker.com/) and Docker Compose installed
- [dbt profile](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles) configured at `~/.dbt/profiles.yml`
- Ports `5433`, `5434`, and `8080` available on your machine

### Steps

**1. Clone the repository**
```bash
git clone <repository-url>
cd project-elt
```

**2. Start all services**
```bash
docker compose up -d
```

**3. Access Airflow Web UI**

Open your browser and go to: `http://localhost:8080`

| Field | Value |
|---|---|
| Username | `airflow` |
| Password | `password` |

**4. Run the EL pipeline**

Enable and trigger the `dag_load_and_transfer` DAG. This will:
- Dump data from `source_postgres` (port 5433)
- Load it into `destination_postgres` (port 5434)

**5. Run dbt transformations**

After the load completes, trigger the `dag_dbt` DAG manually to run the transformation models defined in `postgres_tranformasi/`.

---

## 📅 DAG Schedule

| DAG | Schedule | Trigger |
|---|---|---|
| `dag_load_and_transfer` | Every Sunday at 01:00 UTC (`0 1 * * 0`) | Automatic / Manual |
| `dag_dbt` | None | Manual only |

---

## 🔐 Default Credentials

| Service | Username | Password | Database |
|---|---|---|---|
| Source PostgreSQL | `postgres` | `secret` | `source_db` |
| Destination PostgreSQL | `postgres` | `secret` | `destination_db` |
| Airflow PostgreSQL | `airflow` | `airflow` | `airflow` |
| Airflow UI | `airflow` | `password` | — |

> ⚠️ These are development credentials. Do not use in production.

---

## 📝 Notes

- The `dag_dbt` DAG uses **DockerOperator**, so the Docker socket (`/var/run/docker.sock`) must be accessible from the Airflow container.
- The dbt project directory and `~/.dbt` profile are bind-mounted into the dbt container at runtime. Make sure your local `~/.dbt/profiles.yml` points to `destination_postgres`.
- The `dump_and_load_data.py` script passes `PGPASSWORD` via environment variable for both `pg_dump` and `psql` to avoid password prompts.
- The source database schema is automatically initialized from `init_weekly.sql` when the `source_postgres` container first starts.

---

## 👤 Author

**Rio Al Fandi** – Data Engineer  
DAG Owner: `rio`
