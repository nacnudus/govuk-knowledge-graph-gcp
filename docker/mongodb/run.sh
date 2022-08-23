# Restore the content_store from its backup .bson file in GCP Storage
# https://stackoverflow.com/questions/6575221
gsutil cat gs://govuk-knowledge-graph-content-store/mongo.tar.gz \
  | tar xzvO var/lib/mongodb/backup/mongodump/content_store_production/content_items.bson \
  | mongorestore -v --db=content_store --collection=content_items -

# Query the content store into intermediate datasets
gsutil cat gs://govuk-knowledge-graph-repository/src/mongodb/prepare-content-store.js \
  | bash

# Download from the content store and intermediate datasets, upload to storage
gsutil cat gs://govuk-knowledge-graph-repository/src/mongodb/extract-from-mongodb.sh \
  | bash