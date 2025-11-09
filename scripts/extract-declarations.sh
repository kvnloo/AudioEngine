#!/bin/bash
set -e

SWIFT_DIR="Phase 1 Wireframe"
OUTPUT_JSON="swift_docs_enhanced.json"

echo "🔍 Extracting Swift declarations with SourceKitten..."

# Start JSON array
echo "[" > "$OUTPUT_JSON"
first=true

# Process each Swift file
for swift_file in "$SWIFT_DIR"/*.swift; do
  if [ ! -f "$swift_file" ]; then
    continue
  fi

  filename=$(basename "$swift_file")
  echo "  📄 Processing $filename..."

  # Get SourceKitten structure (has offsets/lengths)
  if ! structure=$(sourcekitten structure --file "$swift_file" 2>/dev/null); then
    echo "  ⚠️  Warning: Failed to get structure for $filename, skipping..." >&2
    continue
  fi

  # Get SourceKitten docs (has documentation comments)
  if ! docs=$(sourcekitten doc --single-file "$swift_file" -- -target arm64-apple-ios10.3 2>/dev/null); then
    echo "  ⚠️  Warning: Failed to get docs for $filename, skipping..." >&2
    continue
  fi

  # Get file content for substring extraction
  file_content=$(cat "$swift_file")

  # Merge using Python script
  python3 scripts/merge-sourcekitten-data.py \
    --structure "$structure" \
    --docs "$docs" \
    --source "$file_content" \
    --output temp_merged.json

  # Read merged data and check if non-empty
  merged_content=$(cat temp_merged.json | jq -c '.[]')

  # Only append if we have actual content
  if [ -n "$merged_content" ]; then
    # Append comma if not first item
    if [ "$first" = true ]; then
      first=false
    else
      echo "," >> "$OUTPUT_JSON"
    fi

    # Append the content
    echo "$merged_content" >> "$OUTPUT_JSON"
  fi
done

# Close JSON array
echo "]" >> "$OUTPUT_JSON"

# Cleanup
rm -f temp_merged.json

echo "✅ Declaration extraction complete!"
echo "📊 Generated: $OUTPUT_JSON"

# Show summary
item_count=$(jq '. | length' "$OUTPUT_JSON")
echo "📈 Total items: $item_count"
