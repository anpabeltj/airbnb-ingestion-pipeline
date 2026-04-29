# 🏠 Airbnb Ingestion Pipeline

An end-to-end data pipeline that ingests raw Airbnb listing data, loads it into PostgreSQL, runs SQL transformations to produce analytical data marts, and exposes dashboards through Metabase — all orchestrated by Apache Airflow and containerized with Docker.

---

## 🗺️ Project Flow

```
📄 CSV File (data/)
       |
       ▼
🐍 Python Ingest Script (scripts/ingest.py)
       |  reads CSV with pandas
       |  loads into PostgreSQL (postgres-airbnb)
       ▼
🐘 Raw Table: Airbnb_Open_Data
       |
       ▼
🔄 SQL Transformation (scripts/transform.sql)
       |  cleans and aggregates data
       ▼
📊 Data Marts
       ├── mart_price_by_neighbourhood
       ├── mart_room_type_summary
       └── mart_host_performance
       |
       ▼
📈 Metabase Dashboard (localhost:3000)
```

All steps above are wired together as a single DAG in Apache Airflow, scheduled to run daily.

---

## 🧰 Tech Stack

| Tool                    | Role                              |
| ----------------------- | --------------------------------- |
| 🐍 Python + pandas      | CSV ingestion                     |
| 🐘 PostgreSQL           | Raw data storage and mart tables  |
| 🌀 Apache Airflow 2.8.1 | Pipeline orchestration            |
| 📊 Metabase             | Data visualization and dashboards |
| 🐳 Docker Compose       | Container management              |

---

## 📁 Project Structure

```
airbnb-pipeline/
├── dags/
│   └── airbnb-dag.py        # Airflow DAG definition
├── scripts/
│   ├── ingest.py            # CSV to PostgreSQL ingestion
│   └── transform.sql        # SQL mart creation queries
├── data/
│   └── Airbnb_Open_Data.csv # Source dataset
├── logs/                    # Airflow task logs
├── docker-compose.yml       # Service definitions
├── .env.example             # Environment variable template
└── README.md
```

---

## ⚙️ Services

The `docker-compose.yml` spins up four services:

- **postgres-airflow** — PostgreSQL database used internally by Airflow to store metadata
- **postgres-airbnb** — PostgreSQL database that stores the Airbnb raw data and mart tables (exposed on port `5436`)
- **airflow** — Runs both the scheduler and the web server (accessible at `localhost:8080`)
- **metabase** — Business intelligence and dashboard tool (accessible at `localhost:3000`)

---

## 🚀 Getting Started

### 1️⃣ Configure Environment Variables

Copy the example file and fill in your database credentials:

```bash
cp .env.example .env
```

Edit `.env` with your values based on the structure shown in `.env.example`:

```
DB_USER=your_db_user
DB_PASS=your_db_password
DB_NAME=your_db_name
DB_HOST=postgres-airbnb   # use this when running inside Docker
DB_PORT=5432
```

### 2️⃣ Start All Services

```bash
docker compose up -d
```

This will start PostgreSQL, Airflow, and Metabase in the background.

### 3️⃣ Access Airflow

Open your browser and go to `http://localhost:8080`

Login with:

- **Username:** `admin`
- **Password:** `admin`

### 4️⃣ Set Up the Airflow Connection

In the Airflow UI, navigate to **Admin → Connections** and create a new connection:

| Field           | Value             |
| --------------- | ----------------- |
| Connection ID   | `postgres_airbnb` |
| Connection Type | `Postgres`        |
| Host            | `postgres-airbnb` |
| Schema          | `airbnb_db`       |
| Login           | `airbnb_user`     |
| Password        | `airbnb_pass`     |
| Port            | `5432`            |

This connection is used by the transform task to run SQL against the Airbnb database.

### 5️⃣ Trigger the Pipeline

In the Airflow UI, find the `airbnb_ingestion_pipeline` DAG and click **▶ Trigger DAG**. The pipeline will:

1. 📥 **Ingest** — load all CSVs from the `data/` folder into PostgreSQL
2. 🔄 **Transform** — run SQL to build the three mart tables

---

## 📊 Data Marts Produced

### `mart_price_by_neighbourhood`

Average, maximum, and minimum listing price grouped by neighbourhood. Includes data cleaning to normalize typos (e.g. `BROOKLN` → `BROOKLYN`).

### `mart_room_type_summary`

Total number of listings and average price for each room type (entire home, private room, shared room, etc.).

### `mart_host_performance`

Each host's total number of listings and average review score, ordered by listing count.

---

## 📈 Visualizing with Metabase

Open `http://localhost:3000` and connect Metabase to the `postgres-airbnb` database to start building charts and dashboards from the mart tables.

---

## 📝 Notes

- The pipeline runs on a **daily schedule** (`@daily`) with `catchup=False`, so only the latest run is executed when triggered manually
- The ingest script uses `if_exists='replace'` meaning each run will overwrite the raw table with a fresh copy of the CSV data
- The transform step drops and recreates mart tables on every run to ensure they reflect the latest ingested data
