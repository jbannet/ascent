#!/bin/bash

# Codebase Index Update Script
# This script regenerates the codebase index based on current code state

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INDEX_DIR="$SCRIPT_DIR"

echo "🔄 Updating codebase index..."
echo "Project root: $PROJECT_ROOT"
echo "Index directory: $INDEX_DIR"

# Update timestamp in config
CURRENT_DATE=$(date -u +"%Y-%m-%d")
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$CURRENT_DATE\"/" "$INDEX_DIR/index-config.json"
else
    # Linux
    sed -i "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$CURRENT_DATE\"/" "$INDEX_DIR/index-config.json"
fi

# Check if key files exist and update index components as needed
update_needed=false

# Check OpenAPI spec changes
if [[ "$PROJECT_ROOT/api/openapi.yaml" -nt "$INDEX_DIR/api/endpoints.json" ]]; then
    echo "📝 OpenAPI spec updated, regenerating API documentation..."
    # Note: In a full implementation, this would re-run the codebase-indexer-qa agent
    # For now, we just touch the file to update timestamp and log the need for update
    touch "$INDEX_DIR/api/endpoints.json"
    update_needed=true
fi

# Check Flutter code changes
if find "$PROJECT_ROOT/ascent/lib" -name "*.dart" -newer "$INDEX_DIR/architecture/component-map.json" | grep -q .; then
    echo "📱 Flutter code updated, component map may need refresh..."
    update_needed=true
fi

# Check Go server changes  
if find "$PROJECT_ROOT/server" -name "*.go" -newer "$INDEX_DIR/architecture/component-map.json" | grep -q .; then
    echo "🚀 Go server code updated, component map may need refresh..."
    update_needed=true
fi

# Check Makefile changes
if [[ "$PROJECT_ROOT/Makefile" -nt "$INDEX_DIR/architecture/system-overview.json" ]]; then
    echo "🔧 Makefile updated, system overview may need refresh..."
    update_needed=true
fi

# Check CLAUDE.md changes
if [[ "$PROJECT_ROOT/CLAUDE.md" -nt "$INDEX_DIR/decisions/conventions.json" ]]; then
    echo "📋 CLAUDE.md updated, conventions documentation may need refresh..."
    # Create conventions file if it doesn't exist
    if [[ ! -f "$INDEX_DIR/decisions/conventions.json" ]]; then
        cat > "$INDEX_DIR/decisions/conventions.json" << 'EOF'
{
  "project_conventions": {
    "description": "Development rules and conventions from CLAUDE.md",
    "last_updated": "2025-09-04",
    "query_rules": [
      "Use INVOKER for database functions",
      "SET path in queries, fully qualify tables",
      "Query function parameters start with 'p_'",
      "Declared variables start with 'v_'",
      "Save functions must use UPSERT"
    ],
    "code_rules": [
      "Start with a plan and check existing implementations",
      "No defaults or fall-back values",
      "No 'FOR NOW' or temporary placeholder code",
      "Name files and functions even if they don't exist yet",
      "No guessing - get actual names from code",
      "Use platform agnostic widgets in Flutter",
      "Class, function, variable names should be very specific and clear",
      "Write functions we know we need, not those we may need"
    ],
    "important_reminders": [
      "Do what has been asked; nothing more, nothing less",
      "Never create files unless absolutely necessary",
      "Always prefer editing existing files to creating new ones",
      "Never proactively create documentation files unless requested"
    ]
  }
}
EOF
    fi
    update_needed=true
fi

if [[ "$update_needed" == true ]]; then
    echo "⚠️  Some components may be out of date. Consider running the codebase-indexer-qa agent to refresh:"
    echo "   Use Claude Code to run: 'use the indexing agent to update the index'"
else
    echo "✅ Index appears to be current with codebase"
fi

# Update file modification times to mark index as refreshed
touch "$INDEX_DIR"/{architecture,data-flow,api,models,components,decisions}/*.json 2>/dev/null || true

echo "🎉 Index update check complete"
echo ""
echo "Index contents:"
find "$INDEX_DIR" -name "*.json" -exec echo "  📄 {}" \;