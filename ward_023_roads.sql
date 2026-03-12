-- Performance & Memory Safety
SET memory_limit = '4GB';
SET temp_directory = '/tmp'; -- Standard path in distroless
SET preserve_insertion_order = false;

LOAD spatial;
LOAD httpfs;
SET s3_region='us-west-2';

-- Fetching only what's needed for Maluti-a-Phofung
COPY (
    SELECT 
        id,
        geometry,
        names,
        class,
        subclass,
        road_surface
    FROM read_parquet('s3://overturemaps-us-west-2/release/2026-02-18.0/theme=transportation/type=segment/*', hive_partitioning = 1)
    WHERE 
        subtype = 'road' 
        AND class IN ('residential', 'service', 'unclassified')
        -- Bounding Box Pushdown
        AND bbox.xmin <= 28.8617 
        AND bbox.xmax >= 28.8332
        AND bbox.ymin <= -28.5363 
        AND bbox.ymax >= -28.5710
) TO '/output/ward_023_roads.parquet' (FORMAT 'PARQUET');