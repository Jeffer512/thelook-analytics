"""Ingest the TheLook CSV snapshot into the raw schema of warehouse.duckdb.

Every raw table is a 1:1 load of its .csv.gz snapshot, all varchar.
"""

from __future__ import annotations

import sys
from pathlib import Path

import duckdb

TABLES = (
    "distribution_centers",
    "events",
    "inventory_items",
    "order_items",
    "orders",
    "products",
    "users",
)


def load(warehouse: Path = Path("warehouse.duckdb"), data_dir: Path = Path("data")) -> dict[str, int]:
    con = duckdb.connect(str(warehouse))
    try:
        con.execute("CREATE SCHEMA IF NOT EXISTS raw")
        counts: dict[str, int] = {}
        for table in TABLES:
            path = data_dir / f"{table}.csv.gz"
            if not path.exists():
                sys.exit(f"missing snapshot: {path} (run scripts/prepare_data.sh first)")
            con.execute(
                f"CREATE OR REPLACE TABLE raw.{table} as "
                f"SELECT * FROM read_csv_auto('{path}', header = true, all_varchar = true)"
            )
            counts[table] = con.execute(f"SELECT COUNT(*) FROM raw.{table}").fetchone()[0]
        return counts
    finally:
        con.close()


def main() -> None:
    counts = load()
    total = sum(counts.values())
    print("raw schema loaded:")
    for table, count in counts.items():
        print(f"  raw.{table:<22} {count:>10,}")
    print(f"  {'TOTAL':<26} {total:>10,}")


if __name__ == "__main__":
    main()
