	  SELECT
    'GuardAppEvent:Start',
    'GuardAppEventType:METADADOS',
    'GuardAppEventStrValue:METADADOS';

    GO
    SELECT
    'GuardAppEvent:Released';

/*
Parametros sp_WhoIsActive:


	--Filtors -- Incluir ou excluir do resultado
	--Se fitro for branco '' - disable (Default)
	--Tipos validos de filtros: session, program, database, login, and host
	--Session eh o session ID da conexao, e zero(0) ou '' mostra todas as sessions
	@filter sysname = '',
	@filter_type VARCHAR(10) = 'session',
	@not_filter sysname = '',
	@not_filter_type VARCHAR(10) = 'session',

	--Controls how sleeping SPIDs are handled, based on the idea of levels of interest
	--0 nao exibe nenhum sleeping SPIDs
	--1 exibe sleeping SPIDs que possuem transacao aberta
	--2 exibe todos sleeping SPIDs
	@show_sleeping_spids TINYINT = 1,


	--Se 1, mostra astored procedure or running batch, quando disponivel
	--Se 0, mostra so o statement atual que esta sendo executado no batch ou procedure
	@get_full_inner_text BIT = 0,


	--Mostra locks associados pada cada request, em formato XML 
	@get_locks BIT = 0,

	--Mosta media de tempo da ultima execucao com a execucao atual
	--(based on the combination of plan handle, sql handle, and offset)
	,@get_avg_time BIT = 0

*/
exec sp_WhoIsActive 
		@filter = ''
		,@filter_type  = 'session'		-- session, program, database, login, and hostname
		,@not_filter = ''				
		,@not_filter_type = 'session'	-- session, program, database, login, and hostname
		,@show_sleeping_spids  = 2
		,@get_full_inner_text = 0
		,@get_locks = 0
		,@get_avg_time = 0
		,@get_plans = 2
		--Help! Descomentar a linha abaixo
		--,@help = 1
