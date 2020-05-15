 SELECT
      ARRAY_LENGTH(SegmentSequence) as arr_len
    FROM
      `idc-dev-etl.tcia.dicom_metadata`
      # Debug:
      #`idc-tcia.lidc_idri_seg_sr.lidc_idri_seg_sr`
    WHERE
      # more reliable than Modality = "SEG"
      SOPClassUID = "1.2.840.10008.5.1.4.1.1.66.4"
    ORDER BY arr_len ASC