  WITH
    segs AS (
    SELECT
      PatientID, SOPInstanceUID, FrameOfReferenceUID, SegmentSequence
    FROM
      `chc-tcia.ispy1.ispy1`
      # Debug:
      #`idc-tcia.lidc_idri_seg_sr.lidc_idri_seg_sr`
    WHERE
      # more reliable than Modality = "SEG"
      SOPClassUID = "1.2.840.10008.5.1.4.1.1.66.4" AND ARRAY_LENGTH(SegmentSequence) <> 0)
  SELECT
    PatientID,
    SOPInstanceUID,
    FrameOfReferenceUID
    -- ,
    -- unnested.AnatomicRegionSequence,
    -- unnested.SegmentedPropertyCategoryCodeSequence,
    -- unnested.SegmentedPropertyTypeCodeSequence,
    -- unnested.SegmentAlgorithmType,
    -- unnested.SegmentNumber,
    #unnested.TrackingUID,
    #unnested.TrackingID
  FROM
    segs
  CROSS JOIN
    UNNEST(SegmentSequence) AS unnested
    limit 10