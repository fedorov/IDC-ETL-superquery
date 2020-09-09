WITH
  pre_pre_dicom_all AS (
  SELECT
    aux.IDC_Webapp_CollectionID AS collection_id,
    aux.GCS_URL as gcs_url,
    dcm.*
  FROM
    `{0}` AS aux
  INNER JOIN
    `{1}` AS dcm
  ON
    aux.SOPInstanceUID = dcm.SOPInstanceUID),
  pre_dicom_all AS (
  SELECT
    data_collections.Location AS tcia_tumorLocation,
    pre_pre_dicom_all.*
  FROM
    pre_pre_dicom_all
  INNER JOIN
    `{2}` AS data_collections
  ON
    pre_pre_dicom_all.collection_id = data_collections.IDC_Webapp_CollectionID)
SELECT
  DOIs.Source_DOI AS Source_DOI,
  pre_dicom_all.*
FROM
  `{3}` AS DOIs
INNER JOIN
  pre_dicom_all
ON
  DOIs.SeriesInstanceUID = pre_dicom_all.SeriesInstanceUID