-- 1. Find the Free State Boundary.
CREATE OR REPLACE TEMP TABLE free_state_boundary AS (
    SELECT geometry 
    FROM read_parquet('s3://overturemaps-us-west-2/release/default/theme=divisions/type=division/*.parquet')
    WHERE names.primary = 'Free State' AND subtype = 'province'
    LIMIT 1
);

-- 2. Fetch buildings within that boundary.
COPY (
    SELECT 
        b.id, 
        b.geometry, 
        b.names.primary AS name,
        b.height,
        b.sources[1].dataset AS source_origin
    FROM read_parquet('s3://overturemaps-us-west-2/release/default/theme=buildings/type=building/*.parquet') AS b
    JOIN free_state_boundary AS fs 
      ON ST_Intersects(b.geometry, fs.geometry)
) TO '/output/free_state_buildings.geojson' 
WITH (FORMAT GDAL, DRIVER 'GeoJSON', SRS 'EPSG:4326');
