#!/bin/bash

set -e
set -x

exec > >(tee /var/log/user-data.log) 2>&1

echo "======================================"
echo "Starting EC2 User Data Script"
echo "======================================"

# Variables from Terraform
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"
DB_HOST="localhost"
DB_PORT="5432"

echo "Database configuration:"
echo "DB_NAME: $${DB_NAME}"
echo "DB_USER: $${DB_USER}"
echo "DB_HOST: $${DB_HOST}"
echo "DB_PORT: $${DB_PORT}"

echo "Step 1: Waiting for PostgreSQL to be ready..."
until sudo -u postgres psql -c '\q' 2>/dev/null; do
  echo "Waiting for PostgreSQL to start..."
  sleep 2
done
echo "PostgreSQL is ready"

echo "Step 2: Creating database user..."
sudo -u postgres psql <<EOSQL
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$${DB_USER}') THEN
        CREATE USER $${DB_USER} WITH PASSWORD '$${DB_PASSWORD}';
    END IF;
END
\$\$;
EOSQL
echo "Database user created or already exists"

echo "Step 3: Creating database..."
sudo -u postgres psql <<EOSQL
SELECT 'CREATE DATABASE $${DB_NAME}'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$${DB_NAME}')\gexec
EOSQL
echo "Database created or already exists"

echo "Step 4: Granting privileges..."
sudo -u postgres psql <<EOSQL
GRANT ALL PRIVILEGES ON DATABASE $${DB_NAME} TO $${DB_USER};
EOSQL

echo "Step 5: Granting schema permissions..."
sudo -u postgres psql -d $${DB_NAME} <<EOSQL
GRANT ALL ON SCHEMA public TO $${DB_USER};
ALTER SCHEMA public OWNER TO $${DB_USER};
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $${DB_USER};
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $${DB_USER};
EOSQL
echo "Schema permissions granted"

echo "Step 6: Configuring PostgreSQL authentication..."

# Detect PG version, config file, and service name across distros
PG_VERSION=$(sudo -u postgres psql -t -c 'SHOW server_version;' | awk -F. '{print $1}' | tr -d ' ')
echo "Detected PostgreSQL major version: $${PG_VERSION}"

# Try common locations for pg_hba.conf
if [ -f "/etc/postgresql/$${PG_VERSION}/main/pg_hba.conf" ]; then
  PG_HBA_FILE="/etc/postgresql/$${PG_VERSION}/main/pg_hba.conf"
  PG_SERVICE="postgresql"
elif [ -f "/var/lib/pgsql/$${PG_VERSION}/data/pg_hba.conf" ]; then
  PG_HBA_FILE="/var/lib/pgsql/$${PG_VERSION}/data/pg_hba.conf"
  PG_SERVICE="postgresql-$${PG_VERSION}"
elif [ -f "/var/lib/pgsql/data/pg_hba.conf" ]; then
  PG_HBA_FILE="/var/lib/pgsql/data/pg_hba.conf"
  PG_SERVICE="postgresql"
else
  echo "ERROR: Could not find pg_hba.conf. Known locations checked."
  exit 1
fi
echo "Using pg_hba.conf at: $${PG_HBA_FILE}"
echo "PostgreSQL service name: $${PG_SERVICE}"

sudo cp "$${PG_HBA_FILE}" "$${PG_HBA_FILE}.backup"
echo "Backed up pg_hba.conf"

# Ensure local and host loopback lines use md5 (or scram). Prefer md5 for widest compatibility.
# 1) Convert local line auth peer|ident -> md5
sudo sed -i -E 's/^(local[[:space:]]+all[[:space:]]+all[[:space:]]+)(peer|ident|scram-sha-256)([[:space:]]*.*)$/\1md5\3/' "$${PG_HBA_FILE}"

# 2) Ensure a host line for IPv4 loopback is md5
if ! grep -Eq '^[[:space:]]*host[[:space:]]+all[[:space:]]+all[[:space:]]+127\.0\.0\.1/32[[:space:]]+md5' "$${PG_HBA_FILE}"; then
  echo "host all all 127.0.0.1/32 md5" | sudo tee -a "$${PG_HBA_FILE}" >/dev/null
fi

# 3) Ensure a host line for IPv6 loopback is md5 (optional)
if grep -q '::1/128' "$${PG_HBA_FILE}"; then
  if ! grep -Eq '^[[:space:]]*host[[:space:]]+all[[:space:]]+all[[:space:]]+::1/128[[:space:]]+md5' "$${PG_HBA_FILE}"; then
    echo "host all all ::1/128 md5" | sudo tee -a "$${PG_HBA_FILE}" >/dev/null
  fi
fi

echo "Updated pg_hba.conf for md5 authentication on local/loopback"

sudo systemctl restart "$${PG_SERVICE}"
echo "PostgreSQL restarted"

echo "Step 7: Creating application environment file..."
sudo mkdir -p /opt/csye6225
sudo tee /opt/csye6225/webapp.env > /dev/null <<ENVFILE
DB_HOST=$${DB_HOST}
DB_PORT=$${DB_PORT}
DB_NAME=$${DB_NAME}
DB_USER=$${DB_USER}
DB_PASSWORD=$${DB_PASSWORD}
ENVFILE

# Ensure app user exists, else default to root ownership
if id csye6225 >/dev/null 2>&1; then
  sudo chown csye6225:csye6225 /opt/csye6225/webapp.env
else
  echo "Warning: user 'csye6225' not found; leaving root ownership."
fi
sudo chmod 400 /opt/csye6225/webapp.env
echo "Environment file created"

ls -la /opt/csye6225/webapp.env
echo "Environment file contents (password masked):"
sudo sed 's/DB_PASSWORD=.*/DB_PASSWORD=***/' /opt/csye6225/webapp.env

echo "Step 8: Starting web application..."
sudo systemctl daemon-reload

# If the unit might not be present yet, don’t fail the whole script
if systemctl list-unit-files | grep -q '^webapp\.service'; then
  sudo systemctl start webapp.service || true
  sleep 5
  sudo systemctl status webapp.service --no-pager || true
else
  echo "Warning: webapp.service not found yet. Skipping start."
fi

echo "======================================"
echo "User Data Script Complete!"
echo "======================================"
echo "Check logs: sudo journalctl -u webapp -f"
echo "======================================"