#../tests/transforms_test.py

import os
import sys
from pyspark.sql import SparkSession

# ---- Ensure covid_analysis package is importable --------------------

# tests/ -> project root is its parent directory
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from covid_analysis.transforms import * 
# ---- Spark session injection from notebook -------------------------

# This will be set by the Databricks notebook
spark_session: SparkSession | None = None


def set_spark_session(s: SparkSession) -> None:
    """
    Called from Databricks notebook to inject the SparkSession.
    """
    global spark_session
    spark_session = s


def _get_spark() -> SparkSession:
    """
    Internal helper: use injected SparkSession if available,
    otherwise create/get a default one (useful if someone
    runs pytest outside the notebook).
    """
    global spark_session
    if spark_session is not None:
        return spark_session

    # Fallback for pure pytest runs (notebook didn't inject)
    return SparkSession.builder.getOrCreate()


def raw_input_df():
    """
    Same logic as your fixture: read test data table.
    """
    spark = _get_spark()
    return spark.sql("SELECT * FROM test_catalog.unit_tests.test_data")


# ---- Tests: logic unchanged, just call raw_input_df() ---------------

def test_row_count():
    df = raw_input_df()
    assert df.count() == 12, f"Expected 12 rows, got {df.count()}"


def test_schema():
    df = raw_input_df()
    expected = ["entity", "iso_code", "date", "indicator", "value"]
    assert df.columns == expected, f"Expected columns {expected}, got {df.columns}"


def test_null_value():
    df = raw_input_df()
    null_count = df.filter("value IS NULL").count()
    assert null_count == 1, f"Expected 1 NULL in 'value', got {null_count}"

# Make sure the filter works as expected.
def test_filter():
    df = raw_input_df()
    pdf=df.toPandas()
    filtered = filter_country(pdf, "USA")
    assert filtered.iso_code.drop_duplicates()[0] == "USA"



