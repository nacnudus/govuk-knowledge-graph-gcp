-- Table of things on GOV.UK, and the type of thing that they are
DELETE FROM search.thing WHERE TRUE;
INSERT INTO search.thing
SELECT 'Person' AS type, title AS name
FROM graph.person
UNION ALL
SELECT 'Organisation' AS type, title AS name
FROM graph.organisation
UNION ALL
SELECT 'Role' AS type, title AS name
FROM graph.role
UNION ALL
SELECT 'BankHoliday' AS type, title AS name
FROM content.bank_holiday_title
UNION ALL
SELECT 'Taxon' AS type, title AS name
FROM graph.taxon
UNION ALL
SELECT 'Transaction' AS type, title AS name
FROM graph.page
WHERE document_type = 'transaction'