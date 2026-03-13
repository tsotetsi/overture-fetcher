# Stage 1: Builder.
FROM alpine:3.19 AS builder

WORKDIR /build

COPY scripts/ ./scripts/

# Combine all SQL scripts into a single file.
RUN for f in scripts/*.sql; do cat "$f" >> master.sql; echo "" >> master.sql; done

# Stage 2: Final.
# Pick duckdb distroless image for a small and secure final image.
FROM duckdb/duckdb:1.5.0

# Use the JSON array form (exec form) to bypass the missing shell
RUN ["duckdb", "-c", "INSTALL spatial; INSTALL httpfs;"]

WORKDIR /app

# Copy combined SQL script from the builder stage.
COPY --from=builder /build/master.sql .

# Executes the single combined script against a database file in the output volume.
ENTRYPOINT ["duckdb", "/output/overture.db", "-c", ".read master.sql"]