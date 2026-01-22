// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Dash for Cloudflare';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_close => 'Fechar';

  @override
  String get common_copied => 'Copiado para a área de transferência';

  @override
  String get common_copy => 'Copiar';

  @override
  String get common_copyFailed => 'Falha ao copiar';

  @override
  String get common_create => 'Criar';

  @override
  String get common_delete => 'Excluir';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_error => 'Erro';

  @override
  String get common_loading => 'Carregando...';

  @override
  String get common_noData => 'Nenhum dado disponível';

  @override
  String get common_ok => 'OK';

  @override
  String get common_refresh => 'Atualizar';

  @override
  String get common_retry => 'Tentar novamente';

  @override
  String get common_save => 'Salvar';

  @override
  String get common_workInProgress =>
      'Em desenvolvimento. Esta funcionalidade estará disponível em breve!';

  @override
  String get common_clearSearch => 'Limpar busca';

  @override
  String get common_clearFilters => 'Limpar filtros';

  @override
  String get common_all => 'Todos';

  @override
  String get common_none => 'Nenhum';

  @override
  String get common_proxy => 'Proxy';

  @override
  String get common_rootOnly => 'Apenas raiz';

  @override
  String get common_disable => 'Desabilitar';

  @override
  String get menu_dns => 'DNS';

  @override
  String get menu_analytics => 'Analytics';

  @override
  String get menu_pages => 'Pages';

  @override
  String get menu_settings => 'Configurações';

  @override
  String get menu_about => 'Sobre';

  @override
  String get menu_debugLogs => 'Logs de Depuração';

  @override
  String get menu_selectZone => 'Selecionar Zona';

  @override
  String get menu_noZones => 'Nenhuma zona';

  @override
  String get tabs_records => 'Registros';

  @override
  String get tabs_analytics => 'Analytics';

  @override
  String get tabs_settings => 'Configurações';

  @override
  String get tabs_web => 'Web';

  @override
  String get tabs_security => 'Segurança';

  @override
  String get tabs_cache => 'Cache';

  @override
  String get zone_selectZone => 'Selecionar zona';

  @override
  String get zone_searchZones => 'Buscar zonas...';

  @override
  String get zone_noZones => 'Nenhuma zona encontrada';

  @override
  String get zone_status_active => 'Ativo';

  @override
  String get zone_status_pending => 'Pendente';

  @override
  String get zone_status_initializing => 'Inicializando';

  @override
  String get zone_status_moved => 'Movido';

  @override
  String get zone_status_deleted => 'Excluído';

  @override
  String get zone_status_deactivated => 'Desativado';

  @override
  String get dns_records => 'Registros DNS';

  @override
  String get dns_filterAll => 'Todos';

  @override
  String get dns_searchRecords => 'Buscar registros...';

  @override
  String get dns_noRecords => 'Nenhum registro DNS';

  @override
  String get dns_noRecordsDescription =>
      'Adicione um registro DNS para começar';

  @override
  String get dns_noRecordsMatch => 'Nenhum registro corresponde ao filtro';

  @override
  String get dns_selectZoneFirst => 'Selecione uma zona para ver os registros';

  @override
  String get dns_addRecord => 'Adicionar Registro';

  @override
  String get dns_editRecord => 'Editar Registro';

  @override
  String get dns_deleteRecord => 'Excluir Registro';

  @override
  String get dns_deleteConfirmTitle => 'Excluir Registro DNS?';

  @override
  String dns_deleteConfirmMessage(String name) {
    return 'Tem certeza que deseja excluir $name? Esta ação não pode ser desfeita.';
  }

  @override
  String get dns_recordSaved => 'Registro salvo com sucesso';

  @override
  String get dns_recordDeleted => 'Registro excluído com sucesso';

  @override
  String get dns_recordDeletedUndo => 'Registro excluído. Toque para desfazer.';

  @override
  String get dns_deleteRecordConfirmTitle => 'Excluir Registro?';

  @override
  String dns_deleteRecordConfirmMessage(String name) {
    return 'Tem certeza que deseja excluir \"$name\"?';
  }

  @override
  String get record_type => 'Tipo';

  @override
  String get record_name => 'Nome';

  @override
  String get record_nameHint => 'Nome ou @ para raiz';

  @override
  String get record_nameRequired => 'Nome é obrigatório';

  @override
  String get record_content => 'Conteúdo';

  @override
  String get record_contentRequired => 'Conteúdo é obrigatório';

  @override
  String get record_ttl => 'TTL';

  @override
  String get record_ttlAuto => 'Auto';

  @override
  String get record_priority => 'Prioridade';

  @override
  String get record_proxied => 'Proxied';

  @override
  String get record_proxiedTooltip => 'Proxied pela Cloudflare';

  @override
  String get record_dnsOnly => 'Somente DNS';

  @override
  String get record_dnsOnlyTooltip => 'Somente DNS (sem proxy)';

  @override
  String get analytics_title => 'Analytics DNS';

  @override
  String get analytics_selectZone =>
      'Selecione uma zona para ver as estatísticas';

  @override
  String get analytics_noData => 'Nenhum dado de estatística';

  @override
  String get analytics_loadAnalytics => 'Carregar Estatísticas';

  @override
  String get analytics_timeRange30m => '30m';

  @override
  String get analytics_timeRange6h => '6h';

  @override
  String get analytics_timeRange12h => '12h';

  @override
  String get analytics_timeRange24h => '24h';

  @override
  String get analytics_timeRange7d => '7d';

  @override
  String get analytics_timeRange30d => '30d';

  @override
  String get analytics_totalQueries => 'Total de Consultas';

  @override
  String get analytics_topQueryNames => 'Principais Nomes Consultados';

  @override
  String get analytics_clearSelection => 'Limpar seleção';

  @override
  String get analytics_total => 'Total';

  @override
  String get analytics_queryTypes => 'Tipos de Consulta';

  @override
  String get analytics_dataCenters => 'Data Centers';

  @override
  String get analytics_queriesOverTime => 'Consultas ao Longo do Tempo';

  @override
  String get analytics_queriesByDataCenter => 'Consultas por Data Center';

  @override
  String get analytics_queriesByLocation => 'Consultas por Localização';

  @override
  String get analytics_queriesByRecordType => 'Consultas por Tipo de Registro';

  @override
  String get analytics_queriesByResponseCode =>
      'Consultas por Código de Resposta';

  @override
  String get analytics_queriesByIpVersion => 'Consultas por Versão IP';

  @override
  String get analytics_queriesByProtocol => 'Consultas por Protocolo';

  @override
  String get analytics_topQueryNamesChart => 'Principais Nomes Consultados';

  @override
  String get analytics_requests => 'Requisições';

  @override
  String get analytics_bandwidth => 'Banda';

  @override
  String get analytics_uniqueVisitors => 'Visitantes Únicos';

  @override
  String get analytics_requestsByStatus => 'Requisições por Status';

  @override
  String get analytics_requestsByCountry => 'Requisições por País';

  @override
  String get analytics_geographicDistribution => 'Distribuição Geográfica';

  @override
  String get analytics_requestsByProtocol => 'Requisições por Protocolo';

  @override
  String get analytics_requestsByHost => 'Requisições por Host';

  @override
  String get analytics_topPaths => 'Principais Caminhos';

  @override
  String get analytics_threatsStopped => 'Ameaças Bloqueadas';

  @override
  String get analytics_totalThreatsBlocked => 'Total de Ameaças Bloqueadas';

  @override
  String get analytics_actionsTaken => 'Ações Tomadas';

  @override
  String get analytics_threatsByCountry => 'Ameaças por País';

  @override
  String get analytics_topThreatSources => 'Principais Fontes de Ameaças';

  @override
  String get analytics_threatOrigins => 'Origem das Ameaças';

  @override
  String get analytics_cacheHitRatio => 'Hits de Cache';

  @override
  String get analytics_bandwidthSaved => 'Banda Economizada';

  @override
  String get analytics_requestsCacheVsOrigin => 'Requisições (Cache vs Origin)';

  @override
  String get analytics_bandwidthCacheVsOrigin => 'Banda (Cache vs Origin)';

  @override
  String get analytics_cacheStatusByHttpStatus => 'Cache por Status HTTP';

  @override
  String get analytics_securityRequiresPaidPlan =>
      'As Estatísticas de Segurança requerem um plano Cloudflare pago (Pro ou superior).';

  @override
  String get dnsSettings_title => 'Configurações DNS';

  @override
  String get dnsSettings_dnssec => 'DNSSEC';

  @override
  String get dnsSettings_dnssecDescription =>
      'DNS Security Extensions adiciona uma camada de segurança assinando os registros DNS. Isso ajuda a proteger seu domínio contra spoofing e ataques de envenenamento de cache.';

  @override
  String get dnsSettings_dnssecDisabled => 'DNSSEC está desabilitado';

  @override
  String get dnsSettings_dnssecPending => 'DNSSEC está pendente de ativação';

  @override
  String get dnsSettings_dnssecPendingCf =>
      'DNSSEC será configurado automaticamente pelo Cloudflare Registrar';

  @override
  String get dnsSettings_dnssecActive => 'DNSSEC está ativo';

  @override
  String get dnsSettings_dnssecPendingDisable =>
      'DNSSEC está pendente de desativação';

  @override
  String get dnsSettings_enableDnssec => 'Habilitar DNSSEC';

  @override
  String get dnsSettings_disableDnssec => 'Desabilitar DNSSEC';

  @override
  String get dnsSettings_cancelDnssec => 'Cancelar';

  @override
  String get dnsSettings_viewDetails => 'Ver Detalhes';

  @override
  String get dnsSettings_viewDsRecord => 'Ver Registro DS';

  @override
  String get dnsSettings_dsRecord => 'Registro DS';

  @override
  String get dnsSettings_copyDsRecord => 'Copiar Registro DS';

  @override
  String get dnsSettings_dsRecordCopied =>
      'Registro DS copiado para a área de transferência';

  @override
  String get dnsSettings_addDsToRegistrar =>
      'Adicione este registro DS ao seu registrador de domínio para completar a configuração do DNSSEC:';

  @override
  String get dnsSettings_multiSignerDnssec => 'DNSSEC Multi-assinante';

  @override
  String get dnsSettings_multiSignerDescription =>
      'Permite que múltiplos provedores DNS assinem sua zona';

  @override
  String get dnsSettings_multiProviderDns => 'DNS Multi-provedor';

  @override
  String get dnsSettings_multiProviderDescription =>
      'Habilitar DNS secundário com outros provedores';

  @override
  String get dnsSettings_cnameFlattening => 'CNAME Flattening';

  @override
  String get dnsSettings_cnameFlatteningDescription =>
      'Achatar registros CNAME no apex da zona';

  @override
  String get dnsSettings_cnameFlattenNone => 'Nenhum';

  @override
  String get dnsSettings_cnameFlattenAtRoot => 'Achatar na raiz';

  @override
  String get dnsSettings_cnameFlattenAll => 'Achatar todos';

  @override
  String get dnsSettings_emailSecurity => 'Segurança de Email';

  @override
  String get dnsSettings_emailSecurityDescription =>
      'Configurar registros DMARC, SPF e DKIM para autenticação de email';

  @override
  String get dnsSettings_configureEmail => 'Configurar';

  @override
  String get dnsSettings_disableDnssecTitle => 'Desabilitar DNSSEC?';

  @override
  String get dnsSettings_cancelDeactivation => 'Cancelar Desativação';

  @override
  String get dnssecDetails_title => 'Detalhes DNSSEC';

  @override
  String get dnssecDetails_dsRecord => 'Registro DS';

  @override
  String get dnssecDetails_digest => 'Digest';

  @override
  String get dnssecDetails_digestType => 'Tipo de Digest';

  @override
  String get dnssecDetails_algorithm => 'Algoritmo';

  @override
  String get dnssecDetails_publicKey => 'Chave Pública';

  @override
  String get dnssecDetails_keyTag => 'Tag da Chave';

  @override
  String get dnssecDetails_keyType => 'Tipo de Chave';

  @override
  String get dnssecDetails_flags => 'Flags';

  @override
  String get dnssecDetails_modifiedOn => 'Modificado em';

  @override
  String get dnssecDetails_tapToCopy => 'Toque para copiar';

  @override
  String get settings_title => 'Configurações';

  @override
  String get settings_apiToken => 'Token da API';

  @override
  String get settings_apiTokenHint => 'Digite seu token da API Cloudflare';

  @override
  String get settings_apiTokenDescription =>
      'Seu token da API precisa das seguintes permissões:';

  @override
  String get settings_apiTokenPermission1 =>
      'Zone:Read - para listar suas zonas';

  @override
  String get settings_apiTokenPermission2 =>
      'DNS:Edit - para gerenciar registros DNS';

  @override
  String get settings_apiTokenPermission3 =>
      'Zone Settings:Read - para status do DNSSEC';

  @override
  String get settings_apiTokenPermission4 =>
      'Zone Settings:Edit - para alternar DNSSEC';

  @override
  String get settings_apiTokenPermission5 =>
      'Analytics:Read - para estatísticas DNS';

  @override
  String get settings_createToken => 'Crie um token em dash.cloudflare.com';

  @override
  String get settings_tokenValid => 'Token é válido';

  @override
  String get settings_tokenInvalid => 'Token deve ter pelo menos 40 caracteres';

  @override
  String get settings_tokenSaved => 'Token salvo';

  @override
  String get settings_goToDns => 'Ir para DNS';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_themeLight => 'Claro';

  @override
  String get settings_themeDark => 'Escuro';

  @override
  String get settings_themeSystem => 'Sistema';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_languageEn => 'English';

  @override
  String get settings_languagePt => 'Português';

  @override
  String get settings_about => 'Sobre';

  @override
  String settings_version(String version) {
    return 'Versão $version';
  }

  @override
  String get error_generic => 'Algo deu errado';

  @override
  String get error_network => 'Erro de rede. Por favor, verifique sua conexão.';

  @override
  String get error_unauthorized => 'Token da API inválido ou expirado';

  @override
  String get error_forbidden =>
      'Você não tem permissão para acessar este recurso';

  @override
  String get error_notFound => 'Recurso não encontrado';

  @override
  String get error_rateLimited =>
      'Muitas requisições. Por favor, tente novamente mais tarde.';

  @override
  String get error_serverError =>
      'Erro no servidor. Por favor, tente novamente mais tarde.';

  @override
  String error_prefix(String message) {
    return 'Erro: $message';
  }

  @override
  String get pwa_updateAvailable => 'Uma nova versão está disponível';

  @override
  String get pwa_updateNow => 'Atualizar Agora';

  @override
  String get pwa_installApp => 'Instalar App';

  @override
  String get pwa_installDescription =>
      'Instale o Dash for Cloudflare para acesso rápido';

  @override
  String get settings_cloudflareApiToken => 'Token da API Cloudflare';

  @override
  String get settings_requiredPermissions =>
      'Permissões necessárias: Zone:Read, DNS:Read, DNS:Edit';

  @override
  String get settings_createTokenOnCloudflare => 'Criar token na Cloudflare';

  @override
  String get settings_tokenPastedFromClipboard =>
      'Token colado da área de transferência';

  @override
  String get settings_storage => 'Armazenamento';

  @override
  String get settings_clearCache => 'Limpar Cache';

  @override
  String get settings_clearCacheDescription =>
      'Registros DNS, estatísticas e data centers';

  @override
  String get settings_clearCacheTitle => 'Limpar Cache';

  @override
  String get settings_clearCacheMessage =>
      'Isso irá limpar todos os dados em cache incluindo registros DNS, estatísticas e informações de data centers.\n\nOs dados serão recarregados da API no próximo acesso.';

  @override
  String get settings_cacheCleared => 'Cache limpo com sucesso';

  @override
  String get settings_debug => 'Depuração';

  @override
  String get settings_saveLogsToFile => 'Salvar logs em arquivo';

  @override
  String get settings_saveLogsDescription =>
      'Persiste logs para análise posterior';

  @override
  String get settings_viewDebugLogs => 'Ver Logs de Depuração';

  @override
  String get settings_goToDnsManagement => 'Ir para Gerenciamento DNS';

  @override
  String get debugLogs_title => 'Logs de Depuração';

  @override
  String get debugLogs_copyAll => 'Copiar Todos';

  @override
  String get debugLogs_saveToFile => 'Salvar em Arquivo';

  @override
  String get debugLogs_shareAsText => 'Compartilhar como Texto';

  @override
  String get debugLogs_shareAsFile => 'Compartilhar como Arquivo';

  @override
  String get debugLogs_clearLogs => 'Limpar Logs';

  @override
  String get debugLogs_logsCopied =>
      'Logs copiados para a área de transferência';

  @override
  String debugLogs_savedTo(String path) {
    return 'Salvo em $path';
  }

  @override
  String debugLogs_failedToSave(String error) {
    return 'Falha ao salvar: $error';
  }

  @override
  String debugLogs_failedToShare(String error) {
    return 'Falha ao compartilhar: $error';
  }

  @override
  String debugLogs_copyTimeRange(String timeRange) {
    return 'Copiar $timeRange';
  }

  @override
  String get debugLogs_logEntryCopied => 'Entrada de log copiada';

  @override
  String get debugLogs_timeRange => 'Período:';

  @override
  String get debugLogs_filter => 'Filtro:';

  @override
  String debugLogs_entries(int count) {
    return '$count entradas';
  }

  @override
  String get debugLogs_noLogsInRange => 'Nenhum log neste período';

  @override
  String get debugLogs_tryLongerRange => 'Tente selecionar um período maior';

  @override
  String get debugLogs_autoScrollOn => 'Auto-scroll LIGADO';

  @override
  String get debugLogs_autoScrollOff => 'Auto-scroll DESLIGADO';

  @override
  String get dnsRecord_createTitle => 'Criar Registro DNS';

  @override
  String get dnsRecord_editTitle => 'Editar Registro DNS';

  @override
  String get dnsRecord_recordCreated => 'Registro criado';

  @override
  String get dnsRecord_recordUpdated => 'Registro atualizado';

  @override
  String get dnsRecord_ttlAuto => 'Auto';

  @override
  String get dnsRecord_ttl2min => '2 minutos';

  @override
  String get dnsRecord_ttl5min => '5 minutos';

  @override
  String get dnsRecord_ttl10min => '10 minutos';

  @override
  String get dnsRecord_ttl15min => '15 minutos';

  @override
  String get dnsRecord_ttl30min => '30 minutos';

  @override
  String get dnsRecord_ttl1hour => '1 hora';

  @override
  String get dnsRecord_ttl2hours => '2 horas';

  @override
  String get dnsRecord_ttl5hours => '5 horas';

  @override
  String get dnsRecord_ttl12hours => '12 horas';

  @override
  String get dnsRecord_ttl1day => '1 dia';

  @override
  String get dnsRecord_enterValue => 'Digite o valor';

  @override
  String emptyState_noResultsFor(String query) {
    return 'Nenhum resultado para \"$query\"';
  }

  @override
  String get emptyState_tryAdjustingSearch =>
      'Tente ajustar os termos de busca';

  @override
  String get pages_title => 'Pages';

  @override
  String get pages_selectAccount => 'Selecionar conta';

  @override
  String get pages_noProjects => 'Nenhum projeto Pages encontrado';

  @override
  String pages_lastDeployment(String date) {
    return 'Último deploy: $date';
  }

  @override
  String get pages_statusSuccess => 'Sucesso';

  @override
  String get pages_statusFailed => 'Falhou';

  @override
  String get pages_statusBuilding => 'Compilando';

  @override
  String get pages_statusQueued => 'Na fila';

  @override
  String get pages_statusSkipped => 'Ignorado';

  @override
  String get pages_statusUnknown => 'Desconhecido';

  @override
  String get pages_openInBrowser => 'Abrir no navegador';

  @override
  String get pages_deployments => 'Deployments';

  @override
  String get pages_noDeployments => 'Nenhum deployment encontrado';

  @override
  String get pages_production => 'Produção';

  @override
  String get pages_preview => 'Preview';

  @override
  String get pages_deploymentDetails => 'Detalhes do Deployment';

  @override
  String get pages_commitInfo => 'Informações do Commit';

  @override
  String get pages_buildStages => 'Etapas do Build';

  @override
  String get pages_rollback => 'Rollback';

  @override
  String get pages_rollbackConfirmTitle => 'Rollback do Deployment';

  @override
  String get pages_rollbackConfirmMessage =>
      'Tem certeza que deseja fazer rollback para este deployment? Isso tornará este deployment a versão de produção atual.';

  @override
  String get pages_rollbackSuccess => 'Rollback realizado com sucesso';

  @override
  String get pages_retry => 'Repetir';

  @override
  String get pages_retryConfirmTitle => 'Repetir Deployment';

  @override
  String get pages_retryConfirmMessage =>
      'Tem certeza que deseja repetir este deployment? Isso iniciará um novo build com a mesma configuração.';

  @override
  String get pages_retrySuccess => 'Deploy reiniciado';

  @override
  String get pages_autoDeployPaused => 'Auto-deploy pausado';
}
