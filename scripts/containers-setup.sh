#!/usr/bin/env bash
# Set up podman machine and dev containers — idempotent
# Run after: brew bundle install (podman must be installed)

set -euo pipefail

APPS_DIR="$HOME/_devroot/apps"

echo "Setting up podman and dev containers..."

# ── Podman machine ─────────────────────────────────────────────────
if ! podman machine ls --format "{{.Name}}" 2>/dev/null | grep -q "podman-machine-default"; then
  echo "Creating podman machine (6 CPUs, 6GB RAM, 100GB disk)..."
  podman machine init --cpus 6 --memory 6144 --disk-size 100
else
  echo "Podman machine already exists."
fi

MACHINE_STATE=$(podman machine ls --format "{{.Running}}" 2>/dev/null | head -1 || echo "false")
if [ "$MACHINE_STATE" != "true" ]; then
  echo "Starting podman machine..."
  podman machine start
else
  echo "Podman machine already running."
fi

# ── Create data directories ───────────────────────────────────────
mkdir -p "$APPS_DIR/mysql/data"
mkdir -p "$APPS_DIR/mysql/config"
mkdir -p "$APPS_DIR/mongo-atlas/data"
mkdir -p "$APPS_DIR/mongo-atlas/config"

# ── MySQL 8.4 ──────────────────────────────────────────────────────
if ! podman ps -a --filter "name=^mysql$" --format "{{.Names}}" 2>/dev/null | grep -q "mysql"; then
  echo "Creating MySQL 8.4 container..."
  podman run -d --name mysql \
    -p 8889:3306 \
    -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
    -v "$APPS_DIR/mysql/data:/var/lib/mysql" \
    -v "$APPS_DIR/mysql/config:/etc/mysql/conf.d" \
    mysql:8.4
else
  STATE=$(podman ps --filter "name=^mysql$" --format "{{.State}}" 2>/dev/null || echo "")
  if [ "$STATE" = "running" ]; then
    echo "MySQL 8.4 container already running."
  else
    echo "Starting existing MySQL 8.4 container..."
    podman start mysql
  fi
fi

# ── MongoDB Atlas Local ────────────────────────────────────────────
if ! podman ps -a --filter "name=^mongo-atlas$" --format "{{.Names}}" 2>/dev/null | grep -q "mongo-atlas"; then
  echo "Creating MongoDB Atlas Local container..."
  podman run -d --name mongo-atlas \
    --memory=4g \
    -p 27017:27017 \
    -v "$APPS_DIR/mongo-atlas/data:/data/db" \
    -v "$APPS_DIR/mongo-atlas/config:/data/configdb" \
    docker.io/mongodb/mongodb-atlas-local
else
  STATE=$(podman ps --filter "name=^mongo-atlas$" --format "{{.State}}" 2>/dev/null || echo "")
  if [ "$STATE" = "running" ]; then
    echo "MongoDB Atlas Local container already running."
  else
    echo "Starting existing MongoDB Atlas Local container..."
    podman start mongo-atlas
  fi
fi

echo ""
echo "Dev containers ready:"
podman ps --format "  {{.Names}}\t{{.State}}\t{{.Ports}}"
