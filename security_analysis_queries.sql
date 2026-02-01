/*
 * PROJECT: Weblog Security Analysis System
 * AUTHOR: Christopher Wilt
 * DESCRIPTION:
 * This script contains the analytical queries used to parse server logs,
 * identify security threats (bot traffic, unauthorized access), and
 * generate daily traffic reports.
 */

-- =============================================
-- SECTION 1: SCHEMA OPTIMIZATION & INDEXING
-- =============================================

-- Add Primary Key to Client Table (Non-Auto Increment)
ALTER TABLE `log_clients` ADD PRIMARY KEY (`ID`);

-- Create Unique Indexes to prevent data duplication
ALTER TABLE `log_areas` ADD UNIQUE (`area`);
ALTER TABLE `log_clients` ADD UNIQUE (`client_ip`);
ALTER TABLE `log_pages` ADD UNIQUE (`page`);
ALTER TABLE `log_referers` ADD UNIQUE (`referer`);

-- Create Performance Index on Filetype for faster filtering
ALTER TABLE `log_pages` ADD INDEX (`filetype`);

-- Create Composite Primary Key for the main Hit Log
ALTER TABLE `log_all` ADD PRIMARY KEY (`hit_date`, `hit_time`, `hit_ms`);

-- Establish Foreign Key Relationships with Cascade rules
ALTER TABLE `log_hits` ADD FOREIGN KEY (`page_id`) REFERENCES `log_pages`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `log_hits` ADD FOREIGN KEY (`client_id`) REFERENCES `log_clients`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `log_hits` ADD FOREIGN KEY (`referer_id`) REFERENCES `log_referers`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `log_hits` ADD FOREIGN KEY (`area_id`) REFERENCES `log_areas`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE;


-- =============================================
-- SECTION 2: DATA NORMALIZATION (ETL)
-- =============================================

-- Populate Lookup Table: Site Areas
INSERT INTO log_areas (area)
SELECT DISTINCT site_area
FROM log_all
WHERE site_area IS NOT NULL AND site_area <> '';

-- Populate Lookup Table: Referrers
INSERT INTO log_referers (referer)
SELECT DISTINCT referer
FROM log_all
WHERE referer IS NOT NULL AND referer <> '';

-- Populate Lookup Table: Pages and File Types
INSERT INTO log_pages (page, filetype)
SELECT
  uri_stem,
  MAX(file_type)
FROM log_all
WHERE
  uri_stem IS NOT NULL AND uri_stem <> ''
GROUP BY
  uri_stem;

-- Populate Lookup Table: Clients (IP Conversion)
-- utilizing INET_ATON to convert IP strings to numeric IDs for storage efficiency
INSERT INTO log_clients (id, client_ip)
SELECT DISTINCT
  INET_ATON(ip_client),
  ip_client
FROM log_all
WHERE
  ip_client IS NOT NULL;

-- Populate Main Fact Table (log_hits)
-- Joining legacy flat-file data with new normalized lookup tables
INSERT INTO log_hits (
    hit_date, hit_time, hit_ms, time_ms, method, uri_query,
    http_version, bytes_sent, bytes_rcvd, user_agent,
    page_id, client_id, referer_id, area_id
)
SELECT
    la.hit_date, la.hit_time, la.hit_ms, la.time_ms, la.method, la.uri_query,
    la.http_version, la.bytes_sent, la.bytes_rcvd, la.user_agent,
    p.id, c.id, r.id, a.id
FROM
    log_all la
LEFT JOIN
    log_pages p ON la.uri_stem = p.page
LEFT JOIN
    log_clients c ON INET_ATON(la.ip_client) = c.id
LEFT JOIN
    log_referers r ON la.referer = r.referer
LEFT JOIN
    log_areas a ON la.site_area = a.area;


-- =============================================
-- SECTION 3: ANALYTICAL VIEWS
-- =============================================

-- View: Filter for Executable Scripts (Security Auditing scope)
CREATE VIEW log_scripts AS
SELECT
    id,
    page,
    filetype
FROM
    log_pages
WHERE
    filetype IN ('php', 'cfm');

-- View: Script Execution Hits
-- Joins traffic data with the script filter to isolate potential vulnerability vectors
CREATE VIEW log_script_hits AS
SELECT h.*
FROM log_hits h
JOIN log_scripts s ON h.page_id = s.id;


-- =============================================
-- SECTION 4: TRAFFIC ANALYSIS
-- =============================================

-- Identify High-Traffic Scripts
SELECT
    p.page,
    COUNT(h.page_id) AS hit_count
FROM
    log_script_hits h
JOIN
    log_pages p ON h.page_id = p.id
GROUP BY
    p.page
ORDER BY
    hit_count DESC;