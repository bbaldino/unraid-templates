#!/bin/bash
# Unraid User Scripts plugin script
# Syncs Docker template XMLs from a GitHub repo to Unraid's templates-user directory.
#
# Setup:
#   1. Install "User Scripts" plugin from Community Applications
#   2. Add new script, paste this in
#   3. Set schedule (e.g. daily, or "At Startup of Array")
#
# Configuration:
REPO="bbaldino/unraid-templates"
BRANCH="main"
TEMPLATE_DIR="/boot/config/plugins/dockerMan/templates-user"

BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

echo "Syncing Unraid templates from ${REPO}..."

# Fetch the file listing from the GitHub API
FILE_LIST=$(curl -sf "https://api.github.com/repos/${REPO}/contents/templates?ref=${BRANCH}")
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to fetch file list from GitHub. Check repo/branch."
    exit 1
fi

# Parse XML filenames from the JSON response
FILES=$(echo "$FILE_LIST" | grep '"name"' | grep '\.xml"' | sed 's/.*"name": "//;s/".*//')

if [ -z "$FILES" ]; then
    echo "No XML templates found in ${REPO}/templates/"
    exit 0
fi

for file in $FILES; do
    echo "  Downloading ${file}..."
    curl -sf -o "${TEMPLATE_DIR}/${file}" "${BASE_URL}/templates/${file}"
    if [ $? -eq 0 ]; then
        echo "    OK"
    else
        echo "    FAILED"
    fi
done

echo "Done. Templates synced to ${TEMPLATE_DIR}/"
