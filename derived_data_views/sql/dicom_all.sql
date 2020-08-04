with pre_dicom_all as (SELECT
  aux.IDC_Webapp_CollectionID AS collection_id,
  dcm.*
FROM
  `{0}` AS aux
INNER JOIN
  `{1}` AS dcm
ON
  aux.SOPInstanceUID = dcm.SOPInstanceUID)
select DOIs.Source_DOI as Source_DOI, pre_dicom_all.*
from `{2}` as DOIs
inner join pre_dicom_all
on DOIs.SeriesInstanceUID = pre_dicom_all.SeriesInstanceUID
