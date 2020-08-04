WITH
  Series2CollectionID AS (
  SELECT
    DISTINCT dicom.SeriesInstanceUID,
    aux.IDC_Webapp_CollectionID AS IDC_Webapp_CollectionID
  FROM
    `{0}` dicom
  INNER JOIN
    `{1}` aux
  ON
    dicom.SOPInstanceUID = aux.SOPInstanceUID ),
  Series2DOI AS (
  SELECT
    DISTINCT Series2CollectionID.SeriesInstanceUID,
    coll_meta.DOI
  FROM
    `{2}` coll_meta
    #INNER join
  INNER JOIN
    Series2CollectionID
  ON
    coll_meta.IDC_Webapp_CollectionID = Series2CollectionID.IDC_Webapp_CollectionID)
SELECT
  DISTINCT Series2DOI.SeriesInstanceUID,
  CASE
    WHEN third.SourceDOI IS NULL THEN Series2DOI.DOI
  ELSE
  third.SourceDOI
END
  AS SOURCE_DOI
FROM
  `{3}` AS third
Right JOIN
  Series2DOI
ON
  third.SeriesInstanceUID = Series2DOI.SeriesInstanceUID