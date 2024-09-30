/*
select 
SMS_R_SYSTEM.ResourceID,
SMS_R_SYSTEM.ResourceType,
SMS_R_SYSTEM.Name,
SMS_R_SYSTEM.SMSUniqueIdentifier,
SMS_R_SYSTEM.ResourceDomainORWorkgroup,
SMS_R_SYSTEM.Client 
from SMS_R_System 
inner join SMS_G_System_SYSTEM_DEVICES
on SMS_G_System_SYSTEM_DEVICES.ResourceID = SMS_R_System.ResourceId 
where 
SMS_G_System_SYSTEM_DEVICES.Name in ("Dell Universal Dock D6000") order by SMS_R_System.Name
*/
select  
v_R_SYSTEM.ResourceID,
v_R_SYSTEM.ResourceType,
v_R_SYSTEM.Name0,
from v_R_System 
inner join v_GS_SYSTEM_DEVICES
on v_GS_SYSTEM_DEVICES.ResourceID = v_R_System.ResourceId 
where v_GS_SYSTEM_DEVICES.Name in ("Dell Universal Dock D6000") 
order by v_R_System.Name
