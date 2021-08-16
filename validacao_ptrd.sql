SELECT   GETDATE() as [PRTD - UIF],@@SERVERNAME ServerName_Global_Variable
,SERVERPROPERTY('ServerName') ServerName
,SERVERPROPERTY('InstanceName') InstanceName
,SERVERPROPERTY('MachineName') MachineName
,SERVERPROPERTY('ComputerNamePhysicalNetBIOS') ComputerNamePhysicalNetBIOS
GO
