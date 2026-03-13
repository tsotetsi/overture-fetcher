-- Performance & Memory Safety.
SET memory_limit = '4GB';
SET preserve_insertion_order = false;

LOAD spatial;
LOAD httpfs;
SET s3_region='us-west-2';

-- Fetching only what's needed for Maluti-a-Phofung - Ward 023 Buildings.
COPY (
    SELECT 
        id,
        geometry,
        height,
        num_floors,
        class,
        sources
    FROM read_parquet('s3://overturemaps-us-west-2/release/2026-02-18.0/theme=buildings/type=building/*', hive_partitioning = 1)
    WHERE 
        -- Bounding Box Pushdown
        bbox.xmin <= 28.8617 
        AND bbox.xmax >= 28.8332
        AND bbox.ymin <= -28.5363 
        AND bbox.ymax >= -28.5710
) TO '/output/ward_023_buildings.parquet' (FORMAT 'PARQUET');