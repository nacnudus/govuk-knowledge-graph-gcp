// HTML content of document types that have it in the "body" field.
db.content_items.aggregate([
  { $match: { "schema_name": { $in: [
    "calendar",
    "case_study",
    "consultation",
    "corporate_information_page",
    "detailed_guide",
    "document_collection",
    "fatality_notice",
    "history",
    "hmrc_manual_section",
    "html_publication",
    "news_article",
    "organisation",
    "publication",
    "service_manual_guide",
    "service_manual_service_standard",
    "speech",
    "statistical_data_set",
    "take_part",
    "topical_event_about_page",
    "working_group"
  ] } } },
  { $project: { url: true, html: "$details.body" } },
  { $match: { "html": { "$exists": true, $ne: null } } },
  { $out: "body"}
])
