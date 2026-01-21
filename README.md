# NOAA Storm Events — Injury & Fatality Risk Characterization

## Project framing
This project examines associations between severe weather events and injury/fatality outcomes using the NOAA Storm Events Database.
It is an applied surveillance / disaster epidemiology style analysis focused on risk characterization (not causal inference, not forecasting).

## Research focus (current working question)
How do storm location and climatic context relate to storm-associated injuries and fatalities?

## Repo structure
- data/raw: downloaded source files (not committed)
- data/interim: cleaned standardized data (not committed)
- data/processed: analysis-ready dataset(s) (not committed)
- src: scripts for ingest → clean → feature engineering → EDA → (optional) modeling
- reports/figures and reports/tables: saved outputs (not committed)
- logs: run logs (not committed)

## Pipeline contract
- src/ingest.py -> outputs data/raw/...
- src/clean.py -> outputs data/interim/storm_events_clean.parquet
- src/features.py -> outputs data/processed/storm_events_analysis.parquet
- src/eda.py -> outputs reports/figures/* and reports/tables/*
- src/model.py -> optional interpretability-first modeling outputs
