#! /bin/bash

# Extract datasets of nodes, attributes and edges from the MongoDB content store
# database.

# Count the number of times that each distinct row of a CSV appears.
#
# This handles newlines in quoted columns.  You have to pass a comma-separated
# list of column names that could contain newlines.
#
# Input is via stdin.
#
# Usage:
# command_that_emits_csv | count_distinct escape_cols=col1,col2
#
# Where col1 and col2 are columns that might contain newlines.
#
# This depends on Python's CSV library to escape and unescape newline
# characters.
#
# Performance (speed and memory) should be okay.  The Python steps are
# parallelised, and only load a few lines at a time.  The unix steps are also
# efficient.
count_distinct () {
  local escape_cols    # reset first
  local "${@}"
  python3 ../../src/utils/toggle_escapes.py \
    --escape_cols=${escape_cols} \
  | ( \
    read -r; \
    printf "count,%s\n" "$REPLY"; \
    LC_ALL=C sort -S 100% \
    | LC_ALL=C uniq -c \
    | sed -E 's/(\s*)([[:digit:]]+)(\s+)/\2,/' \
  ) \
  | python3 ../../src/utils/toggle_escapes.py \
    --unescape_cols=${escape_cols}
}

# Wrapper around sed to replace single backslash with double backslashes,
# because Neo4j interprets a single backslash as an escpae character.
double_backslashes () {
  sed 's/\\/\\\\/g'
}

# Compress and upload to cloud bucket
#
# Usage:
# command_that_emits_text | upload file_name=myfile
#
# The suffix ".csv.gz" is automatically appended to the file name.
#
# Single backslashes are doubled, because Neo4j interprets a single backslash as
# an escape character.
upload () {
  local file_name # reset in case they are defined globally
  local "${@}"
  double_backslashes \
  | gzip -c \
  | gsutil cp - "gs://govuk-knowledge-graph-data-processed/content-store/${file_name}.csv.gz"
}

# For local development
upload () {
  local file_name # reset in case they are defined globally
  local "${@}"
  double_backslashes \
  | gzip -c \
  > data/${file_name}.csv.gz
}

# Wrapper around mongoexport to preset --db=content_store and --type=csv
#
# The `collection=` parameter is optional.  Its default is `content_items`.
#
# The `query=` parameter is optional.
#
# Usage:
#
# query_mongo \
#   collection=my_collection \
#   fields=col1,col2
#
# query_mongo \
#   collection=my_collection \
#   fields=col1,col2 \
#   query='{ "my_field": { "$exists": true } }'
query_mongo () {
  local collection fields query # reset in case they are defined globally
  local "${@}"
  mongoexport \
    --db=content_store \
    --type=csv \
    --collection=${collection:-content_items} \
    --fields=${fields} \
    --query="${query}"
}

# Wrappers around python scripts
#
# Usage:
#
# extract_text_from_html
#   input_col=html \
#   id_cols=url,html \
#
# extract_lines_from_html
#   input_col=html \
#   id_cols=url \
#
# extract_hyperlinks_from_html \
#   input_col=html \
#   id_cols=url \
extract_text_from_html () {
  local input_col id_cols # reset in case they are defined globally
  local "${@}"
  python3 ../../src/utils/extract_text_from_html.py \
    --input_col=${input_col} \
    --id_cols=${id_cols}
}
extract_lines_from_html () {
  local input_col id_cols # reset in case they are defined globally
  local "${@}"
  python3 ../../src/utils/extract_lines_from_html.py \
    --input_col=${input_col} \
    --id_cols=${id_cols}
}
extract_hyperlinks_from_html () {
  local input_col id_cols # reset in case they are defined globally
  local "${@}"
  python3 ../../src/utils/extract_hyperlinks_from_html.py \
    --input_col=${input_col} \
    --id_cols=${id_cols}
}