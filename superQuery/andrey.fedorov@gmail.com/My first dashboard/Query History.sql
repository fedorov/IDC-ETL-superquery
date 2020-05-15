WITH
  contentSequenceLevel1 AS (
  WITH
    structuredReports AS (
    SELECT
      *
    FROM
      `idc-dev-etl.pre_mvp_temp.dicom_all`
    WHERE
      (SOPClassUID = "1.2.840.10008.5.1.4.1.1.88.11"
        OR SOPClassUID = "1.2.840.10008.5.1.4.1.1.88.22"
        OR SOPClassUID = "1.2.840.10008.5.1.4.1.1.88.33"
        OR SOPClassUID = "1.2.840.10008.5.1.4.1.1.88.34"
        OR SOPClassUID = "1.2.840.10008.5.1.4.1.1.88.35")
      AND ARRAY_LENGTH(ContentTemplateSequence) <> 0
      AND ContentTemplateSequence[
    OFFSET
      (0)].TemplateIdentifier = "1500"
      AND ContentTemplateSequence[
    OFFSET
      (0)].MappingResource = "DCMR")
  SELECT
    PatientID,
    SOPInstanceUID,
    SeriesDescription,
    contentSequence
  FROM
    structuredReports
  CROSS JOIN
    UNNEST(ContentSequence) AS contentSequence )
SELECT
  PatientID,
  SOPInstanceUID,
  SeriesDescription,
  contentSequence,
  measurementGroup_number
FROM
  contentSequenceLevel1
CROSS JOIN
  UNNEST (contentSequence.ContentSequence) AS contentSequence
WITH
OFFSET
  AS measurementGroup_number
WHERE
  contentSequence.ValueType = "CONTAINER"
  AND contentSequence.ConceptNameCodeSequence[
OFFSET
  (0)].CodeMeaning = "Measurement Group"