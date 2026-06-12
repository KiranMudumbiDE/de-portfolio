-- =============================================================
-- schema/create_tables.sql
-- Silver layer: clean and enrich raw Titanic Parquet data
-- Demonstrates: schema design, type casting, derived columns,
--               Medallion Architecture (Bronze → Silver)
-- =============================================================

-- DuckDB reads Parquet natively — no loading step needed
-- This creates a persistent Silver table from the Bronze Parquet

CREATE OR REPLACE TABLE passengers AS
SELECT
    PassengerId                         AS passenger_id,
    Survived                            AS survived,
    Pclass                              AS passenger_class,
    Name                                AS full_name,
    Sex                                 AS gender,
    Age                                 AS age,

    -- Derived column: age group (common in DE transforms)
    CASE
        WHEN Age < 18              THEN 'Child'
        WHEN Age BETWEEN 18 AND 35 THEN 'Young Adult'
        WHEN Age BETWEEN 36 AND 60 THEN 'Adult'
        ELSE                            'Senior'
    END                                 AS age_group,

    SibSp                               AS siblings_spouses,
    Parch                               AS parents_children,
    SibSp + Parch                       AS family_size,

    Ticket                              AS ticket_number,
    Fare                                AS fare,

    -- Derived column: fare band for bucketed analysis
    CASE
        WHEN Fare < 10  THEN 'Low (under 10)'
        WHEN Fare < 30  THEN 'Mid (10–30)'
        WHEN Fare < 100 THEN 'High (30–100)'
        ELSE                 'Premium (100+)'
    END                                 AS fare_band,

    -- Derived column: human-readable port name
    CASE Embarked
        WHEN 'C' THEN 'Cherbourg'
        WHEN 'Q' THEN 'Queenstown'
        WHEN 'S' THEN 'Southampton'
        ELSE          'Unknown'
    END                                 AS embarkation_port,

    Cabin                               AS cabin

FROM read_parquet('data/output/titanic.parquet');

-- Verify the Silver table
SELECT COUNT(*) AS total_rows FROM passengers;