FROM duckdb/duckdb:1.1.0

# Use the JSON array form (exec form) to bypass the missing shell
RUN ["duckdb", "-c", "INSTALL spatial; INSTALL httpfs;"]

WORKDIR /app

# Ensure filename consistency
COPY ward_023_roads.sql .

# No shell available, so we call the binary directly
ENTRYPOINT ["duckdb", "-c", ".read ward_023_roads.sql"]