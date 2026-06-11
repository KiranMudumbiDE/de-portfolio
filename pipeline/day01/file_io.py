"""
Day 01 - File I/O + Data Formats
Pipeline: Download NYC Taxi CSV → clean → write Parquet
"""

import json
import requests
import pandas as pd
from pathlib import Path

# ── 1. Paths (always use pathlib, never hardcode strings) ──────────────────
RAW_DIR    = Path("data/raw")
OUTPUT_DIR = Path("data/output")
RAW_DIR.mkdir(parents=True, exist_ok=True)
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# ── 2. Download CSV from public URL ───────────────────────────────────────
URL = "https://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv"

def download_csv(url: str, dest: Path) -> Path:
    """Download a CSV file from a URL and save locally."""
    print(f"Downloading from {url}...")
    response = requests.get(url, timeout=10)
    response.raise_for_status()          # raises on 4xx/5xx
    dest.write_bytes(response.content)
    print(f"Saved to {dest} ({dest.stat().st_size:,} bytes)")
    return dest

# ── 3. Read CSV with pandas ────────────────────────────────────────────────
def read_csv(path: Path) -> pd.DataFrame:
    """Read CSV and print basic shape info."""
    df = pd.read_csv(path)
    print(f"\nShape: {df.shape[0]:,} rows × {df.shape[1]} columns")
    print(f"Columns: {list(df.columns)}")
    print(f"Nulls:\n{df.isnull().sum()}\n")
    return df

# ── 4. Basic clean ─────────────────────────────────────────────────────────
def clean(df: pd.DataFrame) -> pd.DataFrame:
    """Drop nulls in key columns, reset index."""
    df = df.dropna(subset=["Age", "Fare"]).reset_index(drop=True)
    print(f"After clean: {df.shape[0]:,} rows remaining")
    return df

# ── 5. Write to Parquet ────────────────────────────────────────────────────
def write_parquet(df: pd.DataFrame, dest: Path) -> None:
    """Write DataFrame to Parquet — compressed, columnar, fast."""
    df.to_parquet(dest, index=False)
    print(f"Parquet written → {dest} ({dest.stat().st_size:,} bytes)")

# ── 6. Write to NDJSON (newline-delimited JSON — common in event pipelines)
def write_ndjson(df: pd.DataFrame, dest: Path) -> None:
    """Write each row as a JSON object on its own line."""
    with open(dest, "w") as f:
        for record in df.to_dict(orient="records"):
            f.write(json.dumps(record) + "\n")
    print(f"NDJSON written → {dest}")

# ── 7. Read back Parquet and compare file sizes ───────────────────────────
def compare_sizes(csv_path: Path, parquet_path: Path) -> None:
    csv_size     = csv_path.stat().st_size
    parquet_size = parquet_path.stat().st_size
    ratio        = csv_size / parquet_size
    print(f"\n── File size comparison ──")
    print(f"CSV     : {csv_size:>10,} bytes")
    print(f"Parquet : {parquet_size:>10,} bytes")
    print(f"Parquet is {ratio:.1f}× smaller than CSV")

# ── 8. Main pipeline ───────────────────────────────────────────────────────
if __name__ == "__main__":
    csv_path     = RAW_DIR    / "titanic.csv"
    parquet_path = OUTPUT_DIR / "titanic.parquet"
    ndjson_path  = OUTPUT_DIR / "titanic.ndjson"

    raw_df    = read_csv(download_csv(URL, csv_path))
    clean_df  = clean(raw_df)

    write_parquet(clean_df, parquet_path)
    write_ndjson(clean_df,  ndjson_path)
    compare_sizes(csv_path, parquet_path)

    # Read back Parquet to prove it round-trips correctly
    verified = pd.read_parquet(parquet_path)
    assert verified.shape == clean_df.shape, "Row count mismatch after round-trip!"
    print(f"\n✓ Round-trip verified: {verified.shape[0]:,} rows read back from Parquet")