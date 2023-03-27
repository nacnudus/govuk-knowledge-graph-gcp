TRUNCATE TABLE search.role;
INSERT INTO search.role
WITH
persons AS (
  SELECT
    role.url AS role_url,
    ARRAY_AGG(STRUCT(
      person.title AS name,
      has_homepage.homepage_url AS homepage,
      has_role.started_on AS startDate,
      has_role.ended_on AS endDate
  )) AS personNames
  FROM graph.role
  -- If nobody has ever been appointed to the role, we don't want any null
  -- results here, therefore use INNER JOIN.
  INNER JOIN graph.has_role ON has_role.role_url = role.url
  INNER JOIN graph.person ON person.url = has_role.person_url
  LEFT JOIN graph.has_homepage ON has_homepage.url = person.url
  GROUP BY role.url
),
organisations AS (
  SELECT
    role.url AS role_url,
    -- Some roles don't have organisations.
    -- Example: f7668359-03ba-47b6-b495-5c8fa9fe023c
    -- Interim Chief Medical Officer
    ARRAY_AGG(organisation.title IGNORE NULLS) AS orgNames
  FROM graph.role
  LEFT JOIN content.role_organisation ON role_organisation.role_url = role.url
  LEFT JOIN graph.organisation ON organisation.url = role_organisation.organisation_url
  GROUP BY role.url
)
SELECT
  role.title AS name,
  has_homepage.homepage_url AS homepage,
  role.description,
  persons.personNames,
  organisations.orgNames
FROM graph.role
LEFT JOIN graph.has_homepage USING (url)
LEFT JOIN persons ON persons.role_url = role.url
LEFT JOIN organisations ON organisations.role_url = role.url
