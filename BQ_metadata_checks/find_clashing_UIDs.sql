WITH
  more_than_once_uids AS (
  WITH
    all_uids AS (
    WITH
      distinct_studies AS (
      SELECT
        StudyInstanceUID AS UID,
        "study" AS where_used,
        STRING_AGG(DISTINCT(collection_id)) AS collections,
        STRING_AGG(DISTINCT(PatientID)) AS patientIDs
      FROM
        `idc-dev-etl.idc_tcia_views_dev.dicom_all`
      GROUP BY
        StudyInstanceUID),
      distinct_series AS (
      SELECT
        SeriesInstanceUID AS UID,
        "series" AS where_used,
        STRING_AGG(DISTINCT(collection_id)) AS collections,
        STRING_AGG(DISTINCT(PatientID)) AS patientIDs
      FROM
        `idc-dev-etl.idc_tcia_views_dev.dicom_all`
      GROUP BY
        SeriesInstanceUID),
      distinct_instances AS (
      SELECT
        SOPInstanceUID AS UID,
        "instance" AS where_used,
        STRING_AGG(DISTINCT(collection_id)) AS collections,
        STRING_AGG(DISTINCT(PatientID)) AS patientIDs
      FROM
        `idc-dev-etl.idc_tcia_views_dev.dicom_all`
      GROUP BY
        SOPInstanceUID)
    SELECT
      UID,
      where_used,
      collections,
      patientIDs
    FROM
      distinct_studies
    UNION ALL
    SELECT
      UID,
      where_used,
      collections,
      patientIDs
    FROM
      distinct_series
    UNION ALL
    SELECT
      UID,
      where_used,
      collections,
      patientIDs
    FROM
      distinct_instances)
  SELECT
    COUNT(UID) AS uid_counts,
    STRING_AGG(DISTINCT(where_used)) AS where_used,
    STRING_AGG(DISTINCT(collections)) AS collections,
    STRING_AGG(DISTINCT(patientIDs)) AS patientIDs,
    uid
  FROM
    all_uids
  GROUP BY
    uid
  ORDER BY
    uid_counts DESC )
SELECT
  UID,
  where_used,
  collections,
  patientIDs,
  uid_counts
FROM
  more_than_once_uids
WHERE
  uid_counts > 1
ORDER BY
  collections
