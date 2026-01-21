from pathlib import Path

project_root = Path(__file__).resolve().parents[1]

data_dir = project_root / "data"
raw_dir = data_dir / "raw"
interim_dir = data_dir / "interim"
processed_dir = data_dir / "processed"

reports_dir = project_root / "reports"
figures_dir = reports_dir / "figures"
tables_dir = reports_dir / "tables"

logs_dir = project_root / "logs"


def ensure_dirs() -> None:
    """Create expected project directories if they do not exist."""
    for d in [
        raw_dir, interim_dir, processed_dir,
        figures_dir, tables_dir,
        logs_dir
    ]:
        d.mkdir(parents=True, exist_ok=True)
