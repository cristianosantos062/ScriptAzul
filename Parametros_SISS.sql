 /*
 SELECT
    'GuardAppEvent:Start',
    'GuardAppEventType: METADADOS',
    'GuardAppEventStrValue: METADADOS';
	
    GO
    SELECT
    'GuardAppEvent:Released';	
*/


SELECT
    prj.name                        AS [nome_projeto],
    PKG.name                        AS [nome_pacote],
    parm.parameter_name                AS [nome_parametro],
    parm.data_type                    AS [nome_tipo_parametro],
    parm.required                    AS [ind_preenhimento_obrigatorio],
    parm.sensitive                    AS [ind_valor_sensivel],
    parm.referenced_variable_name    AS [nome_variavel_ambiente],
    parm.value_set                    AS [ind_parametro_atribuido],
    parm.value_type                    AS [cod_tipo_valor]    -- V para valor literal e R quando o parâmetro é referenciado a uma variável de ambiente
FROM SSISDB.catalog.object_parameters parm
INNER JOIN ssisdb.catalog.projects prj
ON prj.project_id = parm.project_id
LEFT JOIN ssisdb.catalog.packages pkg
ON pkg.name = parm.object_name
WHERE prj.name = 'SSIS_DWBALCAO_BACEN'
and parm.value_type = 'R'
GO