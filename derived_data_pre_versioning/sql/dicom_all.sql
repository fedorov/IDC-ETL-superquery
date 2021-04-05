WITH
  pre_pre_dicom_all AS (
  SELECT
    aux.IDC_Webapp_CollectionID AS collection_id,
    aux.GCS_URL as gcs_url,
    aux.GCS_Bucket as gcs_bucket,
    aux.GCS_Generation as gcs_generation,
    aux.CRDC_UUIDs.Study as crdc_study_uuid,
    aux.CRDC_UUIDs.Series as crdc_series_uuid,
    aux.CRDC_UUIDs.Instance as crdc_instance_uuid,
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
    data_collections.Species AS tcia_species,
    data_collections.CancerType AS tcia_cancerType,
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