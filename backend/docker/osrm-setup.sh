#!/usr/bin/env bash
# =============================================================================
# Sameway — OSRM self-hosted routing setup
# =============================================================================
# Downloads Bangladesh OpenStreetMap data from Geofabrik and preprocesses it
# for OSRM routing using the MLD (Multi-Level Dijkstra) algorithm.
#
# Run this ONCE before starting the osrm service in docker-compose.yml.
#
# Usage:
#   chmod +x docker/osrm-setup.sh
#   ./docker/osrm-setup.sh
#
# Prerequisites: Docker must be running.
#
# What this does:
#   1. Creates a Docker named volume  osrm_data
#   2. Downloads bangladesh-latest.osm.pbf  (~200 MB)
#   3. Runs osrm-extract   (extract road network from OSM, ~5-10 min)
#   4. Runs osrm-partition (partition graph for MLD, ~2-5 min)
#   5. Runs osrm-customize (compute MLD weights, ~1-2 min)
#
# After completion, uncomment the osrm block in docker-compose.yml and run:
#   docker compose up osrm
# =============================================================================

set -euo pipefail

OSRM_IMAGE="osrm/osrm-backend:v5.27.1"
VOLUME_NAME="sameway-backend_osrm_data"
OSM_URL="https://download.geofabrik.de/asia/bangladesh-latest.osm.pbf"
OSM_FILE="bangladesh-latest.osm.pbf"
OSRM_FILE="bangladesh-latest.osrm"

# Profile: 'car' covers cars and motorbikes (Dhaka traffic mix)
# Use 'bicycle' for a bike-only profile. 'car' works for both vehicle types.
PROFILE="/opt/car.lua"

echo "========================================"
echo "  Sameway OSRM Setup — Bangladesh"
echo "========================================"
echo ""

# Create volume if it doesn't exist
if ! docker volume inspect "$VOLUME_NAME" > /dev/null 2>&1; then
  echo "[1/5] Creating Docker volume: $VOLUME_NAME"
  docker volume create "$VOLUME_NAME"
else
  echo "[1/5] Volume $VOLUME_NAME already exists"
fi

# Check if already preprocessed
ALREADY_DONE=$(docker run --rm \
  -v "$VOLUME_NAME:/data" \
  busybox \
  sh -c "test -f /data/$OSRM_FILE && echo yes || echo no")

if [ "$ALREADY_DONE" = "yes" ]; then
  echo ""
  echo "✓ OSRM data already preprocessed. Nothing to do."
  echo ""
  echo "To start OSRM, uncomment the osrm block in docker-compose.yml and run:"
  echo "  docker compose up -d osrm"
  exit 0
fi

# Download OSM data
echo ""
echo "[2/5] Downloading Bangladesh OSM data (~200 MB)..."
echo "  Source: $OSM_URL"
docker run --rm \
  -v "$VOLUME_NAME:/data" \
  busybox \
  wget -q --show-progress -O "/data/$OSM_FILE" "$OSM_URL"
echo "  Download complete."

# Extract
echo ""
echo "[3/5] Running osrm-extract (road network extraction, ~5-10 min)..."
docker run --rm \
  -v "$VOLUME_NAME:/data" \
  "$OSRM_IMAGE" \
  osrm-extract -p "$PROFILE" "/data/$OSM_FILE"

# Remove the raw PBF to save space (~200 MB)
docker run --rm \
  -v "$VOLUME_NAME:/data" \
  busybox \
  rm -f "/data/$OSM_FILE"
echo "  Extraction complete. Raw PBF removed to save space."

# Partition
echo ""
echo "[4/5] Running osrm-partition (MLD graph partitioning, ~2-5 min)..."
docker run --rm \
  -v "$VOLUME_NAME:/data" \
  "$OSRM_IMAGE" \
  osrm-partition "/data/$OSRM_FILE"
echo "  Partitioning complete."

# Customize
echo ""
echo "[5/5] Running osrm-customize (MLD weight customization, ~1-2 min)..."
docker run --rm \
  -v "$VOLUME_NAME:/data" \
  "$OSRM_IMAGE" \
  osrm-customize "/data/$OSRM_FILE"
echo "  Customization complete."

echo ""
echo "========================================"
echo "  ✓  OSRM data ready."
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Start OSRM with its dedicated compose file:"
echo "       docker compose -f docker-compose.osrm.yml up -d"
echo ""
echo "  2. Add to your .env file:"
echo "       OSRM_URL=http://osrm:5000"
echo ""
echo "  3. Restart the API so it picks up the new variable:"
echo "       docker compose up -d api"
echo ""
