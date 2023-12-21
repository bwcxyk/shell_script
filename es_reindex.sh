#!/bin/bash

# Source Elasticsearch host
source_host="http://192.168.6.218:9200"

# Target Elasticsearch host
target_host="http://192.168.6.56:9200"

# Array of index names to be migrated
indices=("idx_yuanfu" "idx_inventory_and_sale" "idx_location_container" "idx_location_container_item")

# Loop through each index and perform reindex
for index in "${indices[@]}"
do
  echo "Migrating index: $index"
  
  # Run reindex command for each index
  curl -X POST "$target_host/_reindex?pretty" -H 'Content-Type: application/json' -d'
  {
    "source": {
      "remote": {
        "host": "'$source_host'"
      },
      "index": "'$index'",
      "query": {
        "match_all": {}
      }
    },
    "dest": {
      "index": "'$index'"
    }
  }
  '
  
  # Add additional logic or logging if needed
done
