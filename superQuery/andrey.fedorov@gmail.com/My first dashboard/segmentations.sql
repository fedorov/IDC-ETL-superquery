# Debug:
#WITH
#  segs_details AS (
  WITH
    segs AS (
    SELECT
      *
    FROM
      `idc-dev-etl.pre_mvp_temp.dicom_all`
      # Debug:
      #`idc-tcia.lidc_idri_seg_sr.lidc_idri_seg_sr`
    WHERE
      # more reliable than Modality = "SEG"
      SOPClassUID = "1.2.840.10008.5.1.4.1.1.66.4")
  SELECT
    PatientID,
    SOPInstanceUID,
    FrameOfReferenceUID,
    unnested.AnatomicRegionSequence,
    unnested.SegmentedPropertyCategoryCodeSequence,
    unnested.SegmentedPropertyTypeCodeSequence,
    unnested.SegmentAlgorithmType,
    unnested.SegmentNumber,
    unnested.TrackingUID,
    unnested.TrackingID
  FROM
    segs
  CROSS JOIN
    UNNEST(SegmentSequence) AS unnested
  # correctness check: there should be 4 segmented nodules for this subject
  #where PatientID = "LIDC-IDRI-0001"
  
  
    # Note that it is possible to have some of those sequences empty!
    
    # Debug:
    #WHERE
    #  ARRAY_LENGTH(unnested.AnatomicRegionSequence) = 0

# Debug:
#    )
#SELECT
#  DISTINCT SegmentedPropertyTypeCodeSequence[
#OFFSET
#  (0)].CodeMeaning
#FROM
#  segs_details
#WHERE
#  ARRAY_LENGTH(SegmentedPropertyTypeCodeSequence) <> 0