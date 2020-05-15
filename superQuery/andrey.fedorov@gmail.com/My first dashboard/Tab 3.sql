WITH ---
contentSequenceLevel3numeric AS (
  SELECT
    PatientID,
    SOPInstanceUID,
    contentSequence.ConceptNameCodeSequence [
  OFFSET
    (0)] AS ConceptNameCodeSequence,
    contentSequence.MeasuredValueSequence [
  OFFSET
    (0)] AS MeasuredValueSequence,
    contentSequence.MeasuredValueSequence [
  OFFSET
    (0)].MeasurementUnitsCodeSequence [
  OFFSET
    (0)] AS MeasurementUnits,
    contentSequence.ContentSequence,
    measurementGroup_number
  FROM
    `idc-dev-etl.pre_mvp_temp.measurement_groups`
    CROSS JOIN UNNEST (contentSequence.ContentSequence) AS contentSequence
  WHERE
    contentSequence.ValueType = "NUM"
),
---
contentSequenceLevel3codes AS (
  SELECT
    PatientID,
    SOPInstanceUID,
    contentSequence.ConceptNameCodeSequence [
  OFFSET
    (0)] AS ConceptNameCodeSequence,
    contentSequence.ConceptCodeSequence [
  OFFSET
    (0)] AS ConceptCodeSequence,
    measurementGroup_number
  FROM
    `idc-dev-etl.pre_mvp_temp.measurement_groups`
    CROSS JOIN UNNEST (contentSequence.ContentSequence) AS contentSequence
  WHERE
    contentSequence.ValueType = "CODE"
),
---
contentSequenceLevel3uidrefs AS (
  SELECT
    contentSequence.ConceptNameCodeSequence [
  OFFSET
    (0)] AS ConceptNameCodeSequence,
    contentSequence.ConceptCodeSequence [
  OFFSET
    (0)] AS ConceptCodeSequence,
    measurementGroup_number
  FROM
    `idc-dev-etl.pre_mvp_temp.measurement_groups`
    CROSS JOIN UNNEST (contentSequence.ContentSequence) AS contentSequence
  WHERE
    contentSequence.ValueType = "UIDREF"
    AND ConceptCodeSequence [
  OFFSET
    (0)].CodeMeaning = "Tracking Unique Identifier"
),
---
findings AS (
  SELECT
    PatientID,
    SOPInstanceUID,
    ConceptCodeSequence AS finding,
    measurementGroup_number
  FROM
    contentSequenceLevel3codes
  WHERE
    ConceptNameCodeSequence.CodeValue = "121071"
    AND ConceptNameCodeSequence.CodingSchemeDesignator = "DCM"
),
---
findingSites AS (
  SELECT
    PatientID,
    SOPInstanceUID,
    ConceptCodeSequence AS findingSite,
    measurementGroup_number
  FROM
    contentSequenceLevel3codes
  WHERE
    ConceptNameCodeSequence.CodeValue = "G-C0E3"
    AND ConceptNameCodeSequence.CodingSchemeDesignator = "SRT"
),
---
findingsAndFindingSites AS (
  SELECT
    findings.PatientID,
    findings.SOPInstanceUID,
    findings.finding,
    findingSites.findingSite,
    findingSites.measurementGroup_number
  FROM
    findings
    JOIN findingSites ON findings.SOPInstanceUID = findingSites.SOPInstanceUID
    AND findings.measurementGroup_number = findingSites.measurementGroup_number
) ---
# correctness check: the below should result in 11 rows (this is how many segments/measurement
# groups are there for each QIN-HEADNCK-01-0139 segmentation
#SELECT
#  *
#FROM
#  findingsAndFindingSites
#WHERE
#  SOPInstanceUID = "1.2.276.0.7230010.3.1.4.8323329.18336.1440004659.731760"
---
SELECT
  contentSequenceLevel3numeric.PatientID,
  contentSequenceLevel3numeric.SOPInstanceUID,
  contentSequenceLevel3numeric.ConceptNameCodeSequence AS Quantity,
      CASE
      (
        ARRAY_LENGTH(contentSequenceLevel3numeric.ContentSequence) > 0
        AND contentSequenceLevel3numeric.ContentSequence [OFFSET(0)].ConceptNameCodeSequence [OFFSET(0)].CodeValue = "121401"
        AND contentSequenceLevel3numeric.ContentSequence [OFFSET(0)].ConceptNameCodeSequence [OFFSET(0)].CodingSchemeDesignator = "DCM"
      )
      WHEN TRUE THEN STRUCT(
        contentSequenceLevel3numeric.ContentSequence [OFFSET(0)].ConceptCodeSequence [OFFSET(0)].CodeValue AS CodeValue,
        contentSequenceLevel3numeric.ContentSequence [OFFSET(0)].ConceptCodeSequence [OFFSET(0)].CodingSchemeDesignator AS CodingSchemeDesignator,
        contentSequenceLevel3numeric.ContentSequence [OFFSET(0)].ConceptCodeSequence [OFFSET(0)].CodeMeaning AS CodeMeaning
      )
      ELSE NULL
    END AS derivationModifier,
  SAFE_CAST(
    contentSequenceLevel3numeric.MeasuredValueSequence.NumericValue [
    OFFSET
      (0)] AS NUMERIC
  ) AS Value,
  contentSequenceLevel3numeric.MeasurementUnits AS Units,
  findingsAndFindingSites.finding,
  findingsAndFindingSites.findingSite,
  contentSequenceLevel3numeric.measurementGroup_number
FROM
  contentSequenceLevel3numeric
  JOIN findingsAndFindingSites ON contentSequenceLevel3numeric.SOPInstanceUID = findingsAndFindingSites.SOPInstanceUID
  AND contentSequenceLevel3numeric.measurementGroup_number = findingsAndFindingSites.measurementGroup_number ---
  # correctness check: for this patient, there should be 12 rows: 4 segmented nodules, with 3 numeric evaluations for each
  #WHERE
  #  contentSequenceLevel3numeric.PatientID = "LIDC-IDRI-0001"
  ---
  # correctness check: for this specific instance, there should be 238 rows (11 segments)
  #WHERE
  #  contentSequenceLevel3numeric.SOPInstanceUID = "1.2.276.0.7230010.3.1.4.8323329.18336.1440004659.731760"
  #where contentSequenceLevel3numeric.PatientID LIKE "%QIN%"