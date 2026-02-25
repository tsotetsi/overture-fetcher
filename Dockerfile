FROM duckdb/duckdb:v0.10.0

WORKDIR /app

COPY fetch_free_state.sql .

# Install extensions during the build process so they are part of the image.
RUN duckdb -c "INSTALL spatial; INSTALL httpfs;"

ENTRYPOINT ["duckdb", "-c", "LOAD spatial; LOAD httpfs; .read fetch_free_state.sql"]