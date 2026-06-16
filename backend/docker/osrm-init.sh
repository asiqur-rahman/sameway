#!/usr/bin/env bash
# Runs inside the osrm-setup container on first `docker compose up`.
# Downloads Bangladesh OSM data and runs extract -> partition -> customize (MLD).
set -eu

OSM_URL="https://download.geofabrik.de/asia/bangladesh-latest.osm.pbf"
OSM_FILE="bangladesh-latest.osm.pbf"
OSRM_BASE="bangladesh-latest.osrm"
PROFILE="/opt/car.lua"
MLD_READY="${OSRM_BASE}.ramIndex"
# Geofabrik Bangladesh PBF is ~180-220 MB; reject truncated downloads.
MIN_PBF_BYTES=150000000
# Limit threads for Docker/WSL memory (default would use all CPU cores).
EXTRACT_THREADS="${OSRM_EXTRACT_THREADS:-2}"

cd /data

file_size() {
  if [ -f "$1" ]; then
    wc -c < "$1" | tr -d ' '
  else
    echo 0
  fi
}

pbf_valid() {
  [ "$(file_size "${OSM_FILE}")" -ge "${MIN_PBF_BYTES}" ]
}

clean_partial() {
  echo "[osrm-setup] Removing incomplete map data..."
  rm -f "${OSM_FILE}"
  rm -f "${OSRM_BASE}" "${OSRM_BASE}".* 2>/dev/null || true
}

if [ -f "${MLD_READY}" ]; then
  echo "[osrm-setup] Data already ready (${MLD_READY} exists)."
  exit 0
fi

if [ -f "${OSRM_BASE}.ebg" ]; then
  echo "[osrm-setup] Resuming - extract done, running partition + customize..."
elif pbf_valid; then
  echo "[osrm-setup] Valid PBF found ($(file_size "${OSM_FILE}") bytes), running extract..."
  echo "[osrm-setup] Running osrm-extract with ${EXTRACT_THREADS} threads (10-15 min)..."
  if ! osrm-extract -t "${EXTRACT_THREADS}" -p "${PROFILE}" "/data/${OSM_FILE}"; then
    echo "[osrm-setup] ERROR: osrm-extract failed (try increasing Docker/WSL memory)."
    exit 1
  fi
  rm -f "${OSM_FILE}"
else
  if [ -f "${OSM_FILE}" ]; then
    echo "[osrm-setup] PBF incomplete ($(file_size "${OSM_FILE}") bytes, need >= ${MIN_PBF_BYTES}), re-downloading..."
    clean_partial
  else
    echo "[osrm-setup] Downloading Bangladesh OSM (~200 MB)..."
  fi
  wget -q --show-progress -O "${OSM_FILE}.tmp" "${OSM_URL}"
  mv "${OSM_FILE}.tmp" "${OSM_FILE}"
  if ! pbf_valid; then
    echo "[osrm-setup] ERROR: download failed or file too small ($(file_size "${OSM_FILE}") bytes)."
    exit 1
  fi
  echo "[osrm-setup] Download complete ($(file_size "${OSM_FILE}") bytes)."
  echo "[osrm-setup] Running osrm-extract with ${EXTRACT_THREADS} threads (10-15 min)..."
  if ! osrm-extract -t "${EXTRACT_THREADS}" -p "${PROFILE}" "/data/${OSM_FILE}"; then
    echo "[osrm-setup] ERROR: osrm-extract failed (try increasing Docker/WSL memory)."
    exit 1
  fi
  rm -f "${OSM_FILE}"
fi

echo "[osrm-setup] Running osrm-partition..."
if ! osrm-partition "/data/${OSRM_BASE}"; then
  echo "[osrm-setup] ERROR: osrm-partition failed."
  exit 1
fi

echo "[osrm-setup] Running osrm-customize..."
if ! osrm-customize "/data/${OSRM_BASE}"; then
  echo "[osrm-setup] ERROR: osrm-customize failed."
  exit 1
fi

if [ ! -f "${MLD_READY}" ]; then
  echo "[osrm-setup] ERROR: ${MLD_READY} missing after setup."
  exit 1
fi

echo "[osrm-setup] Done."
