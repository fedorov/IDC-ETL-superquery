WITH
  pre_dicom_all AS (
  SELECT
    aux.idc_webapp_collection_id AS collection_id,
    aux.gcs_url as gcs_url,
    aux.gcs_bucket as gcs_bucket,
    aux.study_uuid as crdc_study_uuid,
    aux.series_uuid as crdc_series_uuid,
    aux.instance_uuid as crdc_instance_uuid,
    aux.source_doi as Source_DOI,
    dcm.*
  FROM
    `{0}` AS aux
  INNER JOIN
    `{1}` AS dcm
  ON
    aux.SOPInstanceUID = dcm.SOPInstanceUID)

  SELECT
    data_collections.Location AS tcia_tumorLocation,
    data_collections.Species AS tcia_species,
    data_collections.CancerType AS tcia_cancerType,
    pre_dicom_all.*
  FROM
    pre_dicom_all
  INNER JOIN
    `{2}` AS data_collections
  ON
    pre_dicom_all.collection_id = data_collections.idc_webapp_collection_id