# A dataset of tables of GOV.UK content and related raw statistics

resource "google_bigquery_dataset" "content" {
  dataset_id            = "content"
  friendly_name         = "content"
  description           = "GOV.UK content data"
  location              = "europe-west2"
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_content_dataEditor" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
      "serviceAccount:${google_service_account.gce_mongodb.email}",
      "serviceAccount:${google_service_account.gce_postgres.email}",
      "serviceAccount:${google_service_account.gce_neo4j.email}",
      "serviceAccount:${google_service_account.workflow_bank_holidays.email}",
      "serviceAccount:${google_service_account.bigquery_page_transitions.email}",
    ]
  }
  binding {
    role = "roles/bigquery.dataOwner"
    members = [
      "projectOwners",
    ]
  }
  binding {
    role = "roles/bigquery.dataViewer"
    members = [
      "projectReaders",
      "serviceAccount:ner-bulk-inference@cpto-content-metadata.iam.gserviceaccount.com",
      "serviceAccount:wif-ner-new-content-inference@cpto-content-metadata.iam.gserviceaccount.com",
      "serviceAccount:wif-govgraph-bigquery-access@govuk-llm-question-answering.iam.gserviceaccount.com",
      "serviceAccount:${google_service_account.bigquery_scheduled_queries_search.email}",
      "serviceAccount:${google_service_account.govgraphsearch.email}",
      "group:data-engineering@digital.cabinet-office.gov.uk",
      "group:data-analysis@digital.cabinet-office.gov.uk",
      "group:data-products@digital.cabinet-office.gov.uk"
    ]
  }
}

resource "google_bigquery_dataset_iam_policy" "content" {
  dataset_id  = google_bigquery_dataset.content.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_content_dataEditor.policy_data
}

resource "google_bigquery_table" "url" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "url"
  friendly_name = "GOV.UK unique URLs"
  description   = "Unique URLs of static content on the www.gov.uk domain, not including parts of 'guide' and 'travel_advice' pages, which are in the 'parts' table"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  }
]
EOF
}

resource "google_bigquery_table" "phase" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "phase"
  friendly_name = "Service design phases"
  description   = "The service design phase of content items - https://www.gov.uk/service-manual/phases"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "phase",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The service design phase of a content item - https://www.gov.uk/service-manual/phases"
  }
]
EOF
}

resource "google_bigquery_table" "internal_name" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "internal_name"
  friendly_name = "GOV.UK content ID"
  description   = "Internal name of a taxon"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a taxon"
  },
  {
    "name": "internal_name",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Internal name of a taxon"
  }
]
EOF
}

resource "google_bigquery_table" "content_id" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "content_id"
  friendly_name = "GOV.UK content ID"
  description   = "IDs of static content on the www.gov.uk domain"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "content_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The ID of a content item"
  }
]
EOF
}

resource "google_bigquery_table" "analytics_identifier" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "analytics_identifier"
  friendly_name = "Analytics identifier"
  description   = "A short identifier we send to Google Analytics for multi-valued fields. This means we avoid the truncated values we would get if we sent the path or slug of eg organisations."
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "analytics_identifier",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "A short identifier we send to Google Analytics for multi-valued fields. This means we avoid the truncated values we would get if we sent the path or slug of eg organisations."
  }
]
EOF
}

resource "google_bigquery_table" "acronym" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "acronym"
  friendly_name = "Acronym"
  description   = "The official acronym of an organisation on GOV.UK"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "acronym",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The official acronym of an organisation on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "document_type" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "document_type"
  friendly_name = "Document type"
  description   = "The kind of thing that a content item on GOV.UK represents"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "document_type",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The kind of thing that a content item on GOV.UK represents"
  }
]
EOF
}

resource "google_bigquery_table" "locale" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "locale"
  friendly_name = "Locale"
  description   = "The ISO 639-1 two-letter code of the language of an edition on GOV.UK"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "locale",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The ISO 639-1 two-letter code of the language of an edition on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "publishing_app" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "publishing_app"
  friendly_name = "Publishing app"
  description   = "The application that published a content item on GOV.UK"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "publishing_app",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The application that published a content item on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "updated_at" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "updated_at"
  friendly_name = "Updated at date-time"
  description   = "When a content item was last significantly changed (a major update). Shown to users.  Automatically determined by the publishing-api, unless overridden by the publishing application."
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "updated_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "When a content item was last changed (however insignificantly)"
  }
]
EOF
}

resource "google_bigquery_table" "public_updated_at" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "public_updated_at"
  friendly_name = "Public updated at date-time"
  description   = "When a content item was last significantly changed (a major update). Shown to users.  Automatically determined by the publishing-api, unless overridden by the publishing application."
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "public_updated_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "When a content item was last significantly changed (a major update). Shown to users.  Automatically determined by the publishing-api, unless overridden by the publishing application."
  }
]
EOF
}

resource "google_bigquery_table" "first_published_at" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "first_published_at"
  friendly_name = "First published at date-time"
  description   = "The date the content was first published.  Automatically determined by the publishing-api, unless overridden by the publishing application."
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "first_published_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "The date the content was first published.  Automatically determined by the publishing-api, unless overridden by the publishing application."
  }
]
EOF
}

resource "google_bigquery_table" "withdrawn_at" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "withdrawn_at"
  friendly_name = "Withdrawn at date-time"
  description   = "The date the content was withdrawn."
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "withdrawn_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "The date the content was withdrawn."
  }
]
EOF
}

resource "google_bigquery_table" "withdrawn_explanation" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "withdrawn_explanation"
  friendly_name = "Withdrawn explanation date-time"
  description   = "The explanation for withdrawing the content."
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "html",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The explanation for withdrawing the content, as HTML."
  },
  {
    "name": "text",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The explanation for withdrawing the content, plain text extracted from the HTML."
  },
  {
    "name": "text_without_blank_lines",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The explanation for withdrawing the content, as plain text, omitting blank lines"
  }
]
EOF
}

resource "google_bigquery_table" "title" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "title"
  friendly_name = "Title"
  description   = "Titles of static content on the www.gov.uk domain, not including parts of 'guide' and 'travel_advice' pages, which are in the 'parts' table."
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "title",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The title of a content item"
  }
]
EOF
}

resource "google_bigquery_table" "description" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "description"
  friendly_name = "Description"
  description   = "Descriptions of static content on the www.gov.uk domain."
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "description",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Description of a piece of static content"
  }
]
EOF
}

resource "google_bigquery_table" "department_analytics_profile" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "department_analytics_profile"
  friendly_name = "Department analytics profile"
  description   = "Analytics identifier with which to record views"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "department_analytics_profile",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Analytics identifier with which to record views"
  }
]
EOF
}

resource "google_bigquery_table" "transaction_start_link" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "transaction_start_link"
  friendly_name = "Transaction start link"
  description   = "Link that the start button will link the user to"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "link_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Link that the start button will link the user to"
  },
  {
    "name": "link_url_bare",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Link that the start button will link the user to, omitting parameters and anchors"
  }
]
EOF
}

resource "google_bigquery_table" "start_button_text" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "start_button_text"
  friendly_name = "Start-button text"
  description   = "Custom text to be displayed on the green button that leads you to another page"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "start_button_text",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Custom text to be displayed on the green button that leads you to another page"
  }
]
EOF
}

resource "google_bigquery_table" "expanded_links" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "expanded_links"
  friendly_name = "Expanded links"
  description   = "Typed relationships between two URLs, from one to the other"
  schema        = <<EOF
[
  {
    "name": "link_type",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The type of the relationship between the URLs"
  },
  {
    "name": "from_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The origin URL"
  },
  {
    "name": "to_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The destination URL"
  }
]
EOF
}

resource "google_bigquery_table" "expanded_links_content_ids" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "expanded_links_content_ids"
  friendly_name = "Expanded links (content IDs)"
  description   = "Typed relationships between two content IDs, from one to the other"
  schema        = <<EOF
[
  {
    "name": "link_type",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The type of relationship between two content IDs, from one to the other"
  },
  {
    "name": "from_content_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The origin content ID"
  },
  {
    "name": "to_content_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The destination content ID"
  }
]
EOF
}

resource "google_bigquery_table" "parts" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "parts"
  friendly_name = "URLs and titles of parts of 'guide' and 'travel_advice' documents"
  description   = "URLs, base_paths, slugs, indexes and titles of parts of 'guide' and 'travel_advice' documents"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Complete URL of the part"
  },
  {
    "name": "base_path",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of the parent document of the part"
  },
  {
    "name": "slug",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "What to add to the base_path to get the url"
  },
  {
    "name": "part_index",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "The order of the part among other parts in the same document, counting from 0"
  },
  {
    "name": "part_title",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The title of the part"
  }
]
EOF
}

resource "google_bigquery_table" "step_by_step_content" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "step_by_step_content"
  friendly_name = "Step-by-step content"
  description   = "Content of step-by-step pages"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "html",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as HTML"
  },
  {
    "name": "text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text extracted from the HTML"
  },
  {
    "name": "text_without_blank_lines",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text, omitting blank lines"
  }
]
EOF
}

resource "google_bigquery_table" "parts_content" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "parts_content"
  friendly_name = "Step-by-step content"
  description   = "Content of parts of 'guide' and 'travel_advice' documents"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "base_path",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of the parent document of the part"
  },
  {
    "name": "part_index",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "The order of the part among other parts in the same document, counting from 0"
  },
  {
    "name": "html",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as HTML"
  },
  {
    "name": "text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text extracted from the HTML"
  },
  {
    "name": "text_without_blank_lines",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text, omitting blank lines"
  }
]
EOF
}

resource "google_bigquery_table" "transaction_content" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "transaction_content"
  friendly_name = "Transaction content"
  description   = "Content of 'transaction' documents"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "html",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as HTML"
  },
  {
    "name": "text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text extracted from the HTML"
  },
  {
    "name": "text_without_blank_lines",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text, omitting blank lines"
  }
]
EOF
}

resource "google_bigquery_table" "place_content" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "place_content"
  friendly_name = "Place content"
  description   = "Content of 'place' pages"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "html",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as HTML"
  },
  {
    "name": "text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text extracted from the HTML"
  },
  {
    "name": "text_without_blank_lines",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text, omitting blank lines"
  }
]
EOF
}

resource "google_bigquery_table" "body" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "body"
  friendly_name = "Body content"
  description   = "Content of several types of pages, others are in tables with the suffix '_content'"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "html",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as HTML"
  },
  {
    "name": "text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text extracted from the HTML"
  },
  {
    "name": "text_without_blank_lines",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text, omitting blank lines"
  }
]
EOF
}

resource "google_bigquery_table" "body_content" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "body_content"
  friendly_name = "Body content content"
  description   = "Content of several types of pages, others are in tables with the suffix '_content'"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "html",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as HTML"
  },
  {
    "name": "text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text extracted from the HTML"
  },
  {
    "name": "text_without_blank_lines",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text, omitting blank lines"
  }
]
EOF
}

resource "google_bigquery_table" "lines" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "lines"
  friendly_name = "Lines"
  description   = "Individual lines of content of pages"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "line_number",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "The order of the line of content in the document"
  },
  {
    "name": "line",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "A single line of plain-text content"
  }
]
EOF
}

resource "google_bigquery_table" "step_by_step_embedded_links" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "step_by_step_embedded_links"
  friendly_name = "Step-by-step embedded links"
  description   = "Text and URLs of hyperlinks from the text of step-by-step pages"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "link_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL target of a hyperlink"
  },
  {
    "name": "link_url_bare",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "URL target of a hyperlink, omitting parameters and anchors"
  },
  {
    "name": "link_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Plain text that is displayed in place of the URL"
  }
]
EOF
}

resource "google_bigquery_table" "parts_embedded_links" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "parts_embedded_links"
  friendly_name = "Parts embedded links"
  description   = "Text and URLs of hyperlinks from the text of parts of 'guide' and 'travel_advice' documents"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "base_path",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of the parent document of the part"
  },
  {
    "name": "part_index",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "The order of the part among other parts in the same document, counting from 0"
  },
  {
    "name": "link_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL target of a hyperlink"
  },
  {
    "name": "link_url_bare",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "URL target of a hyperlink, omitting parameters and anchors"
  },
  {
    "name": "link_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Plain text that is displayed in place of the URL"
  }
]
EOF
}

resource "google_bigquery_table" "transaction_embedded_links" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "transaction_embedded_links"
  friendly_name = "Transaction embedded links"
  description   = "Text and URLs of hyperlinks from the text of 'transaction' pages"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "link_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL target of a hyperlink"
  },
  {
    "name": "link_url_bare",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "URL target of a hyperlink, omitting parameters and anchors"
  },
  {
    "name": "link_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Plain text that is displayed in place of the URL"
  }
]
EOF
}

resource "google_bigquery_table" "place_embedded_links" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "place_embedded_links"
  friendly_name = "Place embedded links"
  description   = "Text and URLs of hyperlinks from the text of 'place' pages"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "link_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL target of a hyperlink"
  },
  {
    "name": "link_url_bare",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "URL target of a hyperlink, omitting parameters and anchors"
  },
  {
    "name": "link_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Plain text that is displayed in place of the URL"
  }
]
EOF
}

resource "google_bigquery_table" "body_embedded_links" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "body_embedded_links"
  friendly_name = "Body embedded links"
  description   = "Text and URLs of hyperlinks from the text of several types of pages, others are in tables with the suffix '_embedded_links'"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "link_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL target of a hyperlink"
  },
  {
    "name": "link_url_bare",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "URL target of a hyperlink, omitting parameters and anchors"
  },
  {
    "name": "link_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Plain text that is displayed in body of the URL"
  }
]
EOF
}

resource "google_bigquery_table" "body_content_embedded_links" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "body_content_embedded_links"
  friendly_name = "Body content embedded links"
  description   = "Text and URLs of hyperlinks from the text of several types of pages, others are in tables with the suffix '_embedded_links'"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "link_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL target of a hyperlink"
  },
  {
    "name": "link_url_bare",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "URL target of a hyperlink, omitting parameters and anchors"
  },
  {
    "name": "link_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Plain text that is displayed in body of the URL"
  }
]
EOF
}

resource "google_bigquery_table" "step_by_step_abbreviations" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "step_by_step_abbreviations"
  friendly_name = "Step-by-step abbreviations"
  description   = "Text and acronyms of abbreviations from the text of step-by-step pages"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "abbreviation_title",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Title of an abbreviation"
  },
  {
    "name": "abbreviation_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Acronym of an abbreviation"
  }
]
EOF
}

resource "google_bigquery_table" "parts_abbreviations" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "parts_abbreviations"
  friendly_name = "Parts abbreviations"
  description   = "Text and acronyms of abbreviations from the text of parts of 'guide' and 'travel_advice' documents"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "base_path",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of the parent document of the part"
  },
  {
    "name": "part_index",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "The order of the part among other parts in the same document, counting from 0"
  },
  {
    "name": "abbreviation_title",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Title of an abbreviation"
  },
  {
    "name": "abbreviation_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Acronym of an abbreviation"
  }
]
EOF
}

resource "google_bigquery_table" "transaction_abbreviations" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "transaction_abbreviations"
  friendly_name = "Transaction abbreviations"
  description   = "Text and acronyms of abbreviations from the text of 'transaction' pages"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "abbreviation_title",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Title of an abbreviation"
  },
  {
    "name": "abbreviation_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Acronym of an abbreviation"
  }
]
EOF
}

resource "google_bigquery_table" "place_abbreviations" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "place_abbreviations"
  friendly_name = "Place abbreviations"
  description   = "Text and acronyms of abbreviations from the text of 'place' pages"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "abbreviation_title",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Title of an abbreviation"
  },
  {
    "name": "abbreviation_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Acronym of an abbreviation"
  }
]
EOF
}

resource "google_bigquery_table" "body_abbreviations" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "body_abbreviations"
  friendly_name = "Body abbreviations"
  description   = "Text and acronyms of abbreviations from the text of several types of pages, others are in tables with the suffix '_abbreviations'"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "abbreviation_title",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Title of an abbreviation"
  },
  {
    "name": "abbreviation_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Acronym of an abbreviation"
  }
]
EOF
}

resource "google_bigquery_table" "body_content_abbreviations" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "body_content_abbreviations"
  friendly_name = "Body content abbreviations"
  description   = "Text and acronyms from the text of several types of pages, others are in tables with the suffix '_abbreviations'"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "abbreviation_title",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Title of an abbreviation"
  },
  {
    "name": "abbreviation_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Acronym  of an abbreviation"
  }
]
EOF
}

resource "google_bigquery_table" "url_override" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "url_override"
  friendly_name = "URL override"
  description   = "A kind of redirect on GOV.UK.  Another is 'redirects'"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "url_override",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL that overrides the other"
  }
]
EOF
}

resource "google_bigquery_table" "redirect" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "redirects"
  friendly_name = "Redirects"
  description   = "A kind of redirect on GOV.UK. Another is 'url_override'"
  schema        = <<EOF
[
  {
    "name": "from_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "to_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL that overrides the other"
  },
  {
    "name": "to_url_bare",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL that overrides the other, omitting parameters and anchors"
  }
]
EOF
}

resource "google_bigquery_table" "taxon_levels" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "taxon_levels"
  friendly_name = "Taxon levels"
  description   = "The level of each taxon in the hierarchy, with level 1 as the top"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a taxon"
  },
  {
    "name": "homepage_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a taxon's home page on GOV.UK"
  },
  {
    "name": "level",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Level of the taxon in the hierarchy, with level 1 as the top"
  }
]
EOF
}

resource "google_bigquery_table" "appointment_current" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "appointment_current"
  friendly_name = "Appointment current"
  description   = "Whether a role appointment is current"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role appointment on GOV.UK"
  },
  {
    "name": "current",
    "type": "BOOLEAN",
    "mode": "REQUIRED",
    "description": "Whether a role appointment is current"
  }
]
EOF
}

resource "google_bigquery_table" "appointment_ended_on" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "appointment_ended_on"
  friendly_name = "Appointment ended on"
  description   = "When an appointment to a role ended"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role appointment on GOV.UK"
  },
  {
    "name": "ended_on",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "When an appointment to a role ended"
  }
]
EOF
}

resource "google_bigquery_table" "appointment_person" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "appointment_person"
  friendly_name = "Appointment person"
  description   = "The person appointed to a role"
  schema        = <<EOF
[
  {
    "name": "appointment_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role appointment on GOV.UK"
  },
  {
    "name": "person_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a person on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "appointment_role" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "appointment_role"
  friendly_name = "Appointment role"
  description   = "The role that a person is appointed to"
  schema        = <<EOF
[
  {
    "name": "appointment_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role appointment on GOV.UK"
  },
  {
    "name": "role_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "appointment_started_on" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "appointment_started_on"
  friendly_name = "Appointment started on"
  description   = "When an appointment to a role started"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role appointment on GOV.UK"
  },
  {
    "name": "started_on",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "When an appointment to a role started"
  }
]
EOF
}

resource "google_bigquery_table" "appointment_url" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "appointment_url"
  friendly_name = "Appointment url"
  description   = "Unique URLs of role appointments on GOV.UK"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role appointment on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "role_url" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_url"
  friendly_name = "Unique URLs of roles on GOV.UK"
  description   = "Unique URLs of roles on the www.gov.uk domain"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a 'role' on the www.gov.uk domain"
  }
]
EOF
}

resource "google_bigquery_table" "role_content_id" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_content_id"
  friendly_name = "Role content ID"
  description   = "Content IDs of roles on GOV.UK"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "content_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The ID of a content item"
  }
]
EOF
}

resource "google_bigquery_table" "role_description" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_description"
  friendly_name = "Role description"
  description   = "Description of a role on GOV.UK"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "description",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Description of a role"
  }
]
EOF
}

resource "google_bigquery_table" "role_document_type" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_document_type"
  friendly_name = "Role document type"
  description   = "Document type of a role on GOV.UK"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "document_type",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Document type of a role on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "role_attends_cabinet_type" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_attends_cabinet_type"
  friendly_name = "Role attends cabinet type"
  description   = "Whether the incumbent of a role attends cabinet"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "attends_cabinet_type",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Whether the incumbent of a role attends cabinet"
  }
]
EOF
}

resource "google_bigquery_table" "role_homepage_url" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_homepage_url"
  friendly_name = "Role hompage URL"
  description   = "URL of the homepage of a role"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "homepage_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of the homepage of a role"
  }
]
EOF
}

resource "google_bigquery_table" "role_content" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_content"
  friendly_name = "Role content"
  description   = "Content of 'role' pages"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "govspeak",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as govspeak"
  },
  {
    "name": "html",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as HTML"
  },
  {
    "name": "text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text extracted from the HTML"
  },
  {
    "name": "text_without_blank_lines",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The content of the page as plain text, omitting blank lines"
  }
]
EOF
}

resource "google_bigquery_table" "role_embedded_links" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_embedded_links"
  friendly_name = "Role embedded links"
  description   = "Text and URLs of hyperlinks from the text of 'role' pages"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "link_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL target of a hyperlink"
  },
  {
    "name": "link_url_bare",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "URL target of a hyperlink, omitting parameters and anchors"
  },
  {
    "name": "link_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Plain text that is displayed in place of the URL"
  }
]
EOF
}

resource "google_bigquery_table" "role_abbreviations" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_abbreviations"
  friendly_name = "Role abbreviations"
  description   = "Text and acronyms of abbreviations from the text of 'role' pages"
  schema        = <<EOF
[
  {
    "name": "count",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Number of occurrences of a link with the same URL and link-text in the same document"
  },
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a piece of static content on the www.gov.uk domain"
  },
  {
    "name": "abbreviation_title",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Title of an abbreviation"
  },
  {
    "name": "abbreviation_text",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Acronym  of an abbreviation"
  }
]
EOF
}

resource "google_bigquery_table" "role_locale" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_locale"
  friendly_name = "Role locale"
  description   = "Locale of a role"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "locale",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Locale of a role on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "role_first_published_at" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_first_published_at"
  friendly_name = "Role first published at"
  description   = "When a role was first published"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role role on GOV.UK"
  },
  {
    "name": "first_published_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "When a role was first published"
  }
]
EOF
}

resource "google_bigquery_table" "role_phase" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_phase"
  friendly_name = "Role phase"
  description   = "Phase of a role"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "phase",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The service design phase of a role - https://www.gov.uk/service-manual/phases"
  }
]
EOF
}

resource "google_bigquery_table" "role_public_updated_at" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_public_updated_at"
  friendly_name = "Role publicly updated at"
  description   = "When a role was publicly updated"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role role on GOV.UK"
  },
  {
    "name": "public_updated_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "When a role was publicly updated"
  }
]
EOF
}

resource "google_bigquery_table" "role_publishing_app" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_publishing_app"
  friendly_name = "Role publishing app"
  description   = "Publishing app of a role"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "publishing_app",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Publishing app of a role on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "role_redirect" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_redirect"
  friendly_name = "Role redirect"
  description   = "Redirects of homepates of roles"
  schema        = <<EOF
[
  {
    "name": "from_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a homepage of a role on GOV.UK being redirected from"
  },
  {
    "name": "to_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a homepage of a role on GOV.UK being redirected to"
  }
]
EOF
}

resource "google_bigquery_table" "role_organisation" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_organisation"
  friendly_name = "Role organisation"
  description   = "Organisation to which a role belongs"
  schema        = <<EOF
[
  {
    "name": "organisation_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of an organisation on GOV.UK"
  },
  {
    "name": "role_url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "role_payment_type" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_payment_type"
  friendly_name = "Role payment type"
  description   = "Payment type of roles"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "payment_type",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Payment type of a role on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "role_seniority" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_seniority"
  friendly_name = "Role seniority"
  description   = "Seniority of roles"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "seniority",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Seniority of a role on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "role_title" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_title"
  friendly_name = "Role title"
  description   = "Title of roles"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "title",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Title of a role on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "role_updated_at" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_updated_at"
  friendly_name = "Role updated at"
  description   = "When a role was updated"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role role on GOV.UK"
  },
  {
    "name": "updated_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "When a role was updated"
  }
]
EOF
}

resource "google_bigquery_table" "role_whip_organisation" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "role_whip_organisation"
  friendly_name = "Role whip organisation"
  description   = "Whip organisation of roles"
  schema        = <<EOF
[
  {
    "name": "url",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "URL of a role on GOV.UK"
  },
  {
    "name": "whip_organisation",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Whip organisation of a role on GOV.UK"
  }
]
EOF
}

resource "google_bigquery_table" "bank_holiday_raw" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "bank_holiday_raw"
  friendly_name = "UK Bank Holiday raw JSON data"
  description   = "UK Bank Holiday raw JSON data"
  schema = jsonencode(
    [
      {
        fields = [
          {
            fields = [
              {
                mode        = "NULLABLE"
                name        = "title"
                type        = "STRING"
                description = "Name of the bank holiday"
              },
              {
                mode        = "NULLABLE"
                name        = "notes"
                type        = "STRING"
                description = "Notes about the bank holiday"
              },
              {
                mode        = "NULLABLE"
                name        = "date"
                type        = "DATE"
                description = "Date of a single occurrence of the bank holiday"
              },
              {
                mode        = "NULLABLE"
                name        = "bunting"
                type        = "BOOLEAN"
                description = "Whether to display bunting on the GOV.UK website on the date of the bank holiday"
              },
            ]
            mode        = "REPEATED"
            name        = "events"
            type        = "RECORD"
            description = "Bank holidays in the given division"
          },
          {
            mode        = "NULLABLE"
            name        = "division"
            type        = "STRING"
            description = "Part of the UK"
          },
        ]
        mode        = "REPEATED"
        name        = "body"
        type        = "RECORD"
        description = "Root of the JSON data"
      },
    ]
  )
}

resource "google_bigquery_table" "bank_holiday_occurrence" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "bank_holiday_occurrence"
  friendly_name = "UK Bank Holiday occurrences"
  description   = "UK Bank Holiday occurrences"
  schema = jsonencode(
    [
      {
        mode        = "REQUIRED"
        name        = "url"
        type        = "STRING"
        description = "URL of a bank holiday"
      },
      {
        mode        = "REQUIRED"
        name        = "date"
        type        = "DATE"
        description = "Date of a single occurrence of the bank holiday"
      },
      {
        mode        = "REQUIRED"
        name        = "division"
        type        = "STRING"
        description = "Part of the UK"
      },
      {
        mode        = "REQUIRED"
        name        = "bunting"
        type        = "BOOLEAN"
        description = "Whether to display bunting on the GOV.UK website on the date of the bank holiday"
      },
      {
        mode        = "NULLABLE"
        name        = "notes"
        type        = "STRING"
        description = "Notes about the bank holiday"
      },
    ]
  )
}

resource "google_bigquery_table" "bank_holiday_url" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "bank_holiday_url"
  friendly_name = "Bank holiday URL"
  description   = "Unique URLs of UK bank holidays"
  schema = jsonencode(
    [
      {
        mode        = "REQUIRED"
        name        = "url"
        type        = "STRING"
        description = "URL of a bank holiday, derived from its title"
      }
    ]
  )
}

resource "google_bigquery_table" "bank_holiday_title" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "bank_holiday_title"
  friendly_name = "Bank holiday title"
  description   = "Titles of UK bank holidays"
  schema = jsonencode(
    [
      {
        mode        = "REQUIRED"
        name        = "url"
        type        = "STRING"
        description = "URL of a bank holiday"
      },
      {
        mode        = "REQUIRED"
        name        = "title"
        type        = "STRING"
        description = "Title of the bank holiday"
      }
    ]
  )
}

resource "google_bigquery_table" "page_views" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "page_views"
  friendly_name = "Page views"
  description   = "Number of views of GOV.UK pages over 7 days"
  schema = jsonencode(
    [
      {
        mode        = "REQUIRED"
        name        = "url"
        type        = "STRING"
        description = "URL of a page"
      },
      {
        mode        = "REQUIRED"
        name        = "number_of_views"
        type        = "INTEGER"
        description = "Number of views of the URL"
      }
    ]
  )
}

resource "google_bigquery_table" "content_items" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "content_items"
  friendly_name = "Content items"
  description   = "The raw JSON from the MongoDB Content Store database"
  schema = jsonencode(
    [
      {
        mode        = "REQUIRED"
        name        = "item"
        type        = "JSON"
        description = "JSON representation of a content item"
      }
    ]
  )
}

resource "google_bigquery_table" "organisation_govuk_status" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "organisation_govuk_status"
  friendly_name = "Organisation GOV.UK status"
  description   = "The status of the organisation in GOV.UK"
  schema = jsonencode(
    [
      {
        mode        = "REQUIRED"
        name        = "url"
        type        = "STRING"
        description = "URL of an organisation on the GOV.UK website"
      },
      {
        mode        = "NULLABLE"
        name        = "status"
        type        = "STRING"
        description = "Status of an organisation on the GOV.UK website"
      },
      {
        mode        = "NULLABLE"
        name        = "updated_at"
        type        = "TIMESTAMP"
        description = "Date and time that an organisation's status was last updated"
      },
      {
        mode        = "NULLABLE"
        name        = "organisation_url"
        type        = "STRING"
        description = "URL of an organisation, not necessarily on GOV.UK"
      }
    ]
  )
}
