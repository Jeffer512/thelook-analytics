# TheLook E-commerce Analytics

A small dbt + DuckDB project that profiles the pinned TheLook e-commerce snapshot, builds typed staging models, and exposes a compact set of denormalized marts for sales and customer analysis.

The notebook records the grain, timestamp, revenue, and event findings that drive the mart design. The dbt project turns those decisions into tested models.

## Snapshot

The source is the pinned Kaggle TheLook mirror dated **2024-01-21**, extracted by `scripts/prepare_data.sh`. The raw schema is a 1:1, all-varchar load of the seven CSV snapshots:

| Table | Rows |
|---|---:|
| `orders` | 125,226 |
| `order_items` | 181,759 |
| `users` | 100,000 |
| `products` | 29,120 |
| `inventory_items` | 490,705 |
| `events` | 2,431,963 |
| `distribution_centers` | 10 |

`data/` and `warehouse.duckdb` are generated and gitignored.

## Setup

Requires Python 3.11+ and the Kaggle ZIP snapshot (download from [Kaggle](https://www.kaggle.com/datasets/mustafakeser4/looker-ecommerce-bigquery-dataset)).

Install with [`uv`](https://docs.astral.sh/uv/):

```bash
uv sync --extra analysis
```

Or with pip:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -e '.[analysis]'
```

Extract the snapshot and load it:

```bash
./scripts/prepare_data.sh /path/to/looker-ecommerce-bigquery-dataset.zip
# Or set THELOOK_ZIP env var
THELOOK_ZIP=/path/to/looker-ecommerce-bigquery-dataset.zip ./scripts/prepare_data.sh

.venv/bin/python load.py
```

`scripts/prepare_data.sh` skips files that already exist in `data/`.

## Build

```bash
uv run dbt build --project-dir dbt --profiles-dir dbt --static-analysis strict
uv run dbt docs generate --project-dir dbt --profiles-dir dbt
```

If the venv is active you can omit `uv run`.

A successful build creates models and tests in `warehouse.duckdb`. The current project has 11 models and 90 tests; `dbt build` reports 101 successful nodes.

## Profiling notebook

Open `notebooks/01_profile.ipynb` in VS Code and select `.venv/bin/python` as the kernel.

If you use JupyterLab/Notebook instead, register the project kernel once:

```bash
.venv/bin/python -m ipykernel install --user \
  --name thelook-analytics-venv \
  --display-name "TheLook Analytics"
```

Then select TheLook Analytics in Jupyter and run all cells.
The notebook reads warehouse.duckdb from the repo root.

`notebooks/01_profile.ipynb` documents:

- grains and keys, with an order/item reconciliation
- time coverage and the authoritative order date
- revenue and price semantics
- order lifecycle and status/timestamp behavior
- event identity and why conversion is not identifiable
- the findings-to-decisions table

## Project structure

```text
.
├── notebooks/
│   └── 01_profile.ipynb        # profiling evidence and decisions
├── scripts/
│   └── prepare_data.sh         # extract pinned snapshot to data/*.csv.gz
├── load.py                     # load raw schema into warehouse.duckdb
└── dbt/
    ├── dbt_project.yml
    ├── profiles.yml
    ├── models/
    │   ├── staging/            # typed 1:1 views + generic tests
    │   ├── intermediate/       # reusable transformations (views)
    │   └── marts/              # business-facing entity models (tables)
    └── tests/
        ├── staging/            # singular staging invariants
        └── marts/              # cross-mart reconciliation
```

Materializations and schemas are configured in `dbt/dbt_project.yml`:

| Layer | Schema | Materialization |
|---|---|---|
| staging | `dbt_staging` | view |
| intermediate | `dbt_intermediate` | view |
| marts | `dbt_marts` | table |

## Models

### Staging

One typed view per raw table. Names and types are normalized; no business logic is applied. `dbt/models/staging/schema.yml` defines keys, relationships, and accepted values.

### Intermediate

- `int_users` — cleans country labels (`Deutschland` → `Germany`, `España` → `Spain`) and derives a UTC `registration_date`.

### Marts

The marts follow dbt’s denormalized-entity style for projects without the Semantic Layer: wide business-facing tables instead of a strict Kimball star.

| Model | Grain | Description |
|---|---|---|
| `order_items` | one line item | Order, product, and user attributes; gross, realized, returned revenue; margin. |
| `orders` | one order | Lifecycle timestamps, item count, aggregated revenue/margin, and user attributes. |
| `customers` | one registered user | User attributes plus lifetime order metrics, including `has_ordered`. |

`customers` intentionally includes all 100,000 registered users. Only 80,044 have orders; the remaining 19,956 get zeroed lifetime metrics. In this snapshot every purchaser is a registered user.

## Modeling decisions

- **Two grains, two marts.** `orders` and `order_items` are kept separate so order-level counts and AOV are not summed after joining to items.
- **Order date is authoritative.** Both sales marts use `ordered_at` for time; `item_created_at` is a line-item sale timestamp with synthetic offsets and is not used for order dates or cohorts.
- **Revenue is status-based.** Gross is all line items. Realized is `complete` + `shipped`. Returned revenue is tracked separately because a returned order was delivered and then reversed.
- **No discounts.** `sale_price = retail_price` for every line item. Gross revenue is retail merchandise value; margin is derived from `unit_cost`.
- **Inventory is not a mart input.** `order_items.inventory_item_id` points at unsold units in this snapshot, and `stg_products` is canonical for cost and attributes.
- **No conversion mart.** Identity and purchase are perfectly confounded in the event log: anonymous sessions never purchase, and every identified session purchases. `user_id` behaves as a purchase-attribution flag, not a login flag.
- **2024 is partial.** Use 2019–2023 for full-year comparisons.

## Tests

Run models and all dbt tests:

```bash
uv run dbt build --project-dir dbt --profiles-dir dbt --static-analysis strict
```

For a faster check without rebuilding models:

```bash
uv run dbt test --project-dir dbt --profiles-dir .
```

Generic tests live beside models in `schema.yml`: uniqueness, not-null, relationships, and accepted values.

Singular tests enforce profiling findings that generic tests cannot express:
