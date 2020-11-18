# count all distinct UIDs used for Study/Series/SOPInstanceUID
# to confirm each one is unique at its own level of hierarchy
WITH
  all_uids AS (
  WITH
    distinct_studies AS (
    SELECT
      DISTINCT(StudyInstanceUID) AS UID
    FROM
      `idc-dev-etl.idc_tcia_views_dev.dicom_all`),
    distinct_series AS (
    SELECT
      DISTINCT(SeriesInstanceUID) AS UID
    FROM
      `idc-dev-etl.idc_tcia_views_dev.dicom_all`),
    distinct_instances AS (
    SELECT
      DISTINCT(SOPInstanceUID) AS UID
    FROM
      `idc-dev-etl.idc_tcia_views_dev.dicom_all`)
  SELECT
    UID
  FROM
    distinct_studies
  UNION ALL
  SELECT
    UID
  FROM
    distinct_series)
SELECT
  COUNT(UID) AS uid_counts,
  uid
FROM
  all_uids
GROUP BY
  uid
ORDER BY
  uid_counts DESC
