from datetime import datetime
from pathlib import Path
from src.paths import LOGS_DIR, ensure_dirs


def log(msg: str, logfile: str = "run.log") -> None:
    """Append a timestamped log line to logs/<logfile> and print to console."""
    ensure_dirs()
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{ts}] {msg}"
    print(line)
    path = Path(LOGS_DIR) / logfile
    path.write_text(path.read_text() + line + "\n" if path.exists() else line + "\n")
