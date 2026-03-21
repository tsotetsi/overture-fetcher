-- Informational message.
SELECT '--- Processing data fetch for [ward_023_divisions] ---';

-- Fetching only what's needed for Maluti-a-Phofung - Ward 023 Divisions.
COPY (
    WITH bbox_coords AS (
        SELECT
            28.8332 AS min_lon,
            -28.5710 AS min_lat,
            28.8617 AS max_lon,
            -28.5363 AS max_lat
    )
    SELECT
        id,
        geometry,
        bbox,
        names,
        subtype,
        admin_level
    FROM read_parquet('s3://overturemaps-us-west-2/release/2026-03-18.0/theme=divisions/type=division/*', hive_partitioning = 1, filename = true), bbox_coords
    WHERE
        -- Conditionally execute this script based on the FETCH_DIVISIONS environment variable.
        getenv('FETCH_DIVISIONS') = 'true'
        -- Bounding Box Pushdown (no quadkey filter)
        AND bbox.xmin <= bbox_coords.max_lon
        AND bbox.xmax >= bbox_coords.min_lon
        AND bbox.ymin <= bbox_coords.max_lat
        AND bbox.ymax >= bbox_coords.min_lat
) TO '/output/ward_023_divisions.parquet' (FORMAT 'PARQUET');

-- Informational message.
SELECT '--- Processing complete for [ward_023_divisions] ---';