WITH measurementGroups AS (
  WITH contentSequenceLevel1 AS (
    WITH structuredReports AS (
      SELECT
        *
      FROM
        `idc-dev-etl.pre_mvp_temp.dicom_all`
      WHERE
        (
          SOPClassUID = "1.2.840.10008.5.1.4.1.1.88.11"
          OR SOPClassUID = "1.2.840.10008.5.1.4.1.1.88.22"
          OR SOPClassUID = "1.2.840.10008.5.1.4.1.1.88.33"
          OR SOPClassUID = "1.2.840.10008.5.1.4.1.1.88.34"
          OR SOPClassUID = "1.2.840.10008.5.1.4.1.1.88.35"
        )
        AND ARRAY_LENGTH(ContentTemplateSequence) <> 0
        AND ContentTemplateSequence [
      OFFSET
        (0)].TemplateIdentifier = "1500"
        AND ContentTemplateSequence [
      OFFSET
        (0)].MappingResource = "DCMR"
    )
    SELECT
      PatientID,
      SOPInstanceUID,
      SeriesDescription,
      contentSequence
    FROM
      structuredReports
      CROSS JOIN UNNEST(ContentSequence) AS contentSequence
  )
  SELECT
    PatientID,
    SOPInstanceUID,
    SeriesDescription,
    contentSequence,
    measurementGroup_number
  FROM
    contentSequenceLevel1
    CROSS JOIN UNNEST (contentSequence.ContentSequence) AS contentSequence WITH OFFSET AS measurementGroup_number
  WHERE
    contentSequence.ValueType = "CONTAINER"
    AND contentSequence.ConceptNameCodeSequence [
  OFFSET
    (0)].CodeMeaning = "Measurement Group"
),
measurementGroups_withTrackingID AS (
  SELECT
    SOPInstanceUID,
    measurementGroup_number,
    unnestedContentSequence.TextValue AS trackingIdentifier
  FROM
    measurementGroups
    CROSS JOIN UNNEST(contentSequence.ContentSequence) AS unnestedContentSequence
  WHERE
    unnestedContentSequence.ValueType = "TEXT"
    AND (
      unnestedContentSequence.ConceptNameCodeSequence [
    OFFSET
      (0)].CodeValue = "112039"
      AND unnestedContentSequence.ConceptNameCodeSequence [
    OFFSET
      (0)].CodingSchemeDesignator = "DCM"
    )
),
measurementGroups_withTrackingUID AS (
  SELECT
    SOPInstanceUID,
    measurementGroup_number,
    unnestedContentSequence.UID AS trackingUniqueIdentifier
  FROM
    measurementGroups
    CROSS JOIN UNNEST(contentSequence.ContentSequence) AS unnestedContentSequence
  WHERE
    unnestedContentSequence.ValueType = "UIDREF"
    AND (
      unnestedContentSequence.ConceptNameCodeSequence [
    OFFSET
      (0)].CodeValue = "112040"
      AND unnestedContentSequence.ConceptNameCodeSequence [
    OFFSET
      (0)].CodingSchemeDesignator = "DCM"
    )
),
measurementGroups_withSourceSeries AS (
  SELECT
    SOPInstanceUID,
    measurementGroup_number,
    unnestedContentSequence.UID AS sourceSegmentedSeriesUID
  FROM
    measurementGroups
    CROSS JOIN UNNEST(contentSequence.ContentSequence) AS unnestedContentSequence
  WHERE
    unnestedContentSequence.ValueType = "UIDREF"
    AND (
      unnestedContentSequence.ConceptNameCodeSequence [
    OFFSET
      (0)].CodeValue = "121232"
      AND unnestedContentSequence.ConceptNameCodeSequence [
    OFFSET
      (0)].CodingSchemeDesignator = "DCM"
    )
),
measurementGroups_withFinding AS (
  SELECT
    SOPInstanceUID,
    measurementGroup_number,
    unnestedContentSequence.ConceptCodeSequence [OFFSET(0)] as finding
  FROM
    measurementGroups
    CROSS JOIN UNNEST(contentSequence.ContentSequence) AS unnestedContentSequence
  WHERE
    unnestedContentSequence.ValueType = "CODE"
    AND (
      unnestedContentSequence.ConceptNameCodeSequence [
    OFFSET
      (0)].CodeValue = "121071"
      AND unnestedContentSequence.ConceptNameCodeSequence [
    OFFSET
      (0)].CodingSchemeDesignator = "DCM"
    )
),
measurementGroups_withFindingSite AS (
  SELECT
    SOPInstanceUID,
    measurementGroup_number,
    unnestedContentSequence.ConceptCodeSequence [OFFSET(0)] as findingSite
  FROM
    measurementGroups
    CROSS JOIN UNNEST(contentSequence.ContentSequence) AS unnestedContentSequence
  WHERE
    unnestedContentSequence.ValueType = "CODE"
    AND (
      unnestedContentSequence.ConceptNameCodeSequence [
    OFFSET
      (0)].CodeValue = "G-C0E3"
      AND unnestedContentSequence.ConceptNameCodeSequence [
    OFFSET
      (0)].CodingSchemeDesignator = "SRT"
    )
)
SELECT
  mWithUID.SOPInstanceUID,
  mWithUID.measurementGroup_number,
  mWithUID.trackingUniqueIdentifier,
  mWithID.trackingIdentifier,
  mWithFinding.finding,
  mWithFindingSite.findingSite,
  mWithSourceSeries.sourceSegmentedSeriesUID
FROM
  measurementGroups_withTrackingUID AS mWithUID
  LEFT JOIN measurementGroups_withTrackingID AS mWithID ON mWithID.SOPInstanceUID = mWithUID.SOPInstanceUID
  AND mWithID.measurementGroup_number = mWithUID.measurementGroup_number #  unnest (measurementGroups.ContentSequence)
  LEFT JOIN measurementGroups_withFinding AS mWithFinding ON mWithID.SOPInstanceUID = mWithFinding.SOPInstanceUID
  AND mWithID.measurementGroup_number = mWithFinding.measurementGroup_number
  LEFT JOIN measurementGroups_withFindingSite AS mWithFindingSite ON mWithID.SOPInstanceUID = mWithFindingSite.SOPInstanceUID
  AND mWithID.measurementGroup_number = mWithFindingSite.measurementGroup_number
  LEFT JOIN measurementGroups_withSourceSeries AS mWithSourceSeries ON mWithID.SOPInstanceUID = mWithSourceSeries.SOPInstanceUID
  AND mWithID.measurementGroup_number = mWithSourceSeries.measurementGroup_number