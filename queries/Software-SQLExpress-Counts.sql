SELECT DISTINCT
  ProductName0 as ProductName,
  ProductVersion0 as Version, 
  Publisher0 as Publisher, 
  case 
  when (ProductVersion0 like '9.%') then 'UNSUPPORTED'
  when (ProductVersion0 like '10.%') then 'EOL 2019/07/09'
  else 'SUPPORTED' end as Support, 
  COUNT(*) AS Installs
FROM 
  v_GS_INSTALLED_SOFTWARE_CATEGORIZED
WHERE
  ProductName0 LIKE 'Microsoft SQL Server % Express%'
GROUP BY
  ProductName0, ProductVersion0, Publisher0 
ORDER BY 
  ProductName0 
