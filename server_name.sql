select * from [ctrl].[ListConnect] where idProduct=2 and flg_dashboard=1

select * from [dbo].[instance_server] where 1=1
	--AND DR2 like 'SQLBAL00101P%'
	OR PROD like 'SQLBAL00101P%'
--	AND instance_name like ''


select * from [dbo].[instance_server] where PROD like 'SQLBAL00101P%'

select * from STG.SISTEMAS_SCHEMAS where db_name like 'GMC%'


SELECT * FROM [CTRL].[LISTCONNECT]
/*
[stg].[MSSQL_Volumetria] - > Lista a volumetria do ambiente 
[CTRL].[LISTCONNECT] -> Cadastro de todas as Instancias
        duas colunas importantes -> não_atualizar = 1 (não terá coleta)
                                                      flg_dashboard = 1 contabiliza no Dash
 
[DBO].[TB_STORAGE_INFOS] -> tabela com cadastro de todos os nodes
STG.SISTEMAS_SCHEMAS -> Cadastro de todos os bancos 
*/

