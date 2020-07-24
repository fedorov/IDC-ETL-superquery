SELECT
  aux.Webapp_CollectionID AS collection_id,
  dcm.*
FROM
  `{0}` AS aux
INNER JOIN
  `{1}` AS dcm
ON
  aux.SOPInstanceUID = dcm.SOPInstanceUID