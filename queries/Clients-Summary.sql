select distinct 
	Name0 as ComputerName, 
	ResourceID, 
	Client0 as Client, 
	Client_Version0 as ClientVersion, 
	AD_Site_Name0 as ADSiteName, 
	Operating_System_Name_and0 AS OS,
	case 
		when (Operating_System_Name_and0 like '%workstation%') then 'Workstation'
		when (Operating_System_Name_and0 like '%server%') then 'Server'
		else 'Other' end as OSType 
from 
	v_R_System 
order by
	Name0 
