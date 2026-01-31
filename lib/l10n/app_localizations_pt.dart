// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Dash for CF';

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
  String get common_add => 'Adicionar';

  @override
  String get common_delete => 'Excluir';

  @override
  String get common_deleted => 'Excluído com sucesso';

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
      'Trabalho em andamento. Este recurso estará disponível em breve!';

  @override
  String get common_clearSearch => 'Limpar busca';

  @override
  String get common_clearFilters => 'Limpar filtros';

  @override
  String get common_all => 'Tudo';

  @override
  String get common_none => 'Nenhum';

  @override
  String get common_proxy => 'Proxy';

  @override
  String get common_rootOnly => 'Apenas raiz';

  @override
  String get common_disable => 'Desativar';

  @override
  String get menu_dns => 'DNS';

  @override
  String get menu_analytics => 'Analytics';

  @override
  String get menu_pages => 'Pages';

  @override
  String get menu_workers => 'Workers';

  @override
  String get menu_settings => 'Configurações';

  @override
  String get menu_about => 'Sobre';

  @override
  String get menu_debugLogs => 'Logs de Depuração';

  @override
  String get menu_selectZone => 'Selecionar Zona';

  @override
  String get menu_noZones => 'Sem zonas';

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
  String get zone_selectZone => 'Selecione uma zona';

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
  String get dns_filterAll => 'Tudo';

  @override
  String get dns_searchRecords => 'Buscar registros...';

  @override
  String get dns_noRecords => 'Sem registros DNS';

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
  String get record_proxied => 'Com Proxy';

  @override
  String get record_proxiedTooltip => 'Trafégo passa pelo Cloudflare';

  @override
  String get record_dnsOnly => 'Apenas DNS';

  @override
  String get record_dnsOnlyTooltip => 'Apenas DNS (sem proxy)';

  @override
  String get analytics_title => 'DNS Analytics';

  @override
  String get analytics_selectZone => 'Selecione uma zona para ver o analytics';

  @override
  String get analytics_noData => 'Sem dados de analytics';

  @override
  String get analytics_loadAnalytics => 'Carregar Analytics';

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
  String get analytics_topQueryNames => 'Principais Nomes';

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
  String get analytics_topQueryNamesChart => 'Principais Nomes de Consulta';

  @override
  String get analytics_requests => 'Requisições';

  @override
  String get analytics_bandwidth => 'Largura de Banda';

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
  String get analytics_threatsStopped => 'Ameaças Detidas';

  @override
  String get analytics_totalThreatsBlocked => 'Total de Ameaças Bloqueadas';

  @override
  String get analytics_actionsTaken => 'Ações Tomadas';

  @override
  String get analytics_threatsByCountry => 'Ameaças por País';

  @override
  String get analytics_topThreatSources => 'Principais Fontes de Ameaça';

  @override
  String get analytics_threatOrigins => 'Origens de Ameaça';

  @override
  String get analytics_cacheHitRatio => 'Taxa de Cache';

  @override
  String get analytics_bandwidthSaved => 'Banda Economizada';

  @override
  String get analytics_requestsCacheVsOrigin => 'Requisições (Cache vs Origem)';

  @override
  String get analytics_bandwidthCacheVsOrigin => 'Banda (Cache vs Origem)';

  @override
  String get analytics_cacheStatusByHttpStatus =>
      'Status de Cache por HTTP Status';

  @override
  String get analytics_securityRequiresPaidPlan =>
      'Security Analytics requer um plano pago do Cloudflare (Pro ou superior).';

  @override
  String get dnsSettings_title => 'Configurações DNS';

  @override
  String get dnsSettings_dnssec => 'DNSSEC';

  @override
  String get dnsSettings_dnssecDescription =>
      'Extensões de Segurança do DNS adicionam uma camada de segurança assinando registros DNS. Isso ajuda a proteger seu domínio contra ataques de falsificação de DNS.';

  @override
  String get dnsSettings_dnssecDisabled => 'DNSSEC está desativado';

  @override
  String get dnsSettings_dnssecPending => 'DNSSEC aguardando ativação';

  @override
  String get dnsSettings_dnssecPendingCf =>
      'DNSSEC será configurado automaticamente pelo Cloudflare Registrar';

  @override
  String get dnsSettings_dnssecActive => 'DNSSEC está ativo';

  @override
  String get dnsSettings_dnssecPendingDisable =>
      'DNSSEC aguardando desativação';

  @override
  String get dnsSettings_enableDnssec => 'Ativar DNSSEC';

  @override
  String get dnsSettings_disableDnssec => 'Desativar DNSSEC';

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
  String get dnsSettings_dsRecordCopied => 'Registro DS copiado';

  @override
  String get dnsSettings_addDsToRegistrar =>
      'Adicione este registro DS ao seu registrador de domínio para concluir a configuração do DNSSEC:';

  @override
  String get dnsSettings_multiSignerDnssec => 'DNSSEC Multi-assinatário';

  @override
  String get dnsSettings_multiSignerDescription =>
      'Permite que vários provedores de DNS assinem sua zona';

  @override
  String get dnsSettings_multiProviderDns => 'DNS Multi-provedor';

  @override
  String get dnsSettings_multiProviderDescription =>
      'Ativar DNS secundário com outros provedores';

  @override
  String get dnsSettings_cnameFlattening => 'Achatamento de CNAME';

  @override
  String get dnsSettings_cnameFlatteningDescription =>
      'Achatar registros CNAME na raiz da zona (apex)';

  @override
  String get dnsSettings_cnameFlattenNone => 'Nenhum';

  @override
  String get dnsSettings_cnameFlattenAtRoot => 'Achatar na raiz';

  @override
  String get dnsSettings_cnameFlattenAll => 'Achatar tudo';

  @override
  String get dnsSettings_emailSecurity => 'Segurança de E-mail';

  @override
  String get dnsSettings_emailSecurityDescription =>
      'Configurar registros DMARC, SPF e DKIM para autenticação de e-mail';

  @override
  String get dnsSettings_configureEmail => 'Configurar';

  @override
  String get dnsSettings_disableDnssecTitle => 'Desativar DNSSEC?';

  @override
  String get dnsSettings_cancelDeactivation => 'Cancelar Desativação';

  @override
  String get emailSecurity_spfExists => 'Registro SPF já configurado';

  @override
  String get emailSecurity_spfNotConfigured => 'SPF não configurado';

  @override
  String get emailSecurity_spfDescription =>
      'Sender Policy Framework (SPF) especifica quais servidores de e-mail estão autorizados a enviar e-mails em nome do seu domínio.';

  @override
  String get emailSecurity_spfIncludes => 'Remetentes Autorizados (includes)';

  @override
  String get emailSecurity_spfIncludesHint =>
      'ex: _spf.google.com sendgrid.net';

  @override
  String get emailSecurity_spfPolicy => 'Política (All)';

  @override
  String get emailSecurity_spfPolicyHint =>
      '~all (soft fail), -all (hard fail), ou +all (permitir)';

  @override
  String get emailSecurity_spfSaved => 'Registro SPF salvo com sucesso';

  @override
  String get emailSecurity_dkimExists => 'Registro DKIM já configurado';

  @override
  String get emailSecurity_dkimNotConfigured => 'DKIM não configurado';

  @override
  String get emailSecurity_dkimDescription =>
      'DomainKeys Identified Mail (DKIM) adiciona uma assinatura digital aos seus e-mails para verificar que não foram adulterados.';

  @override
  String get emailSecurity_dkimSelector => 'Seletor';

  @override
  String get emailSecurity_dkimSelectorHint => 'ex: default, google, mailgun';

  @override
  String get emailSecurity_dkimPublicKey => 'Chave Pública (p=)';

  @override
  String get emailSecurity_dkimPublicKeyHint =>
      'Cole a chave pública fornecida pelo seu provedor de e-mail (sem o prefixo v=DKIM1; k=rsa; p=)';

  @override
  String get emailSecurity_dkimPublicKeyRequired =>
      'Chave pública é obrigatória';

  @override
  String get emailSecurity_dkimSaved => 'Registro DKIM salvo com sucesso';

  @override
  String get emailSecurity_dmarcExists => 'Registro DMARC já configurado';

  @override
  String get emailSecurity_dmarcNotConfigured => 'DMARC não configurado';

  @override
  String get emailSecurity_dmarcDescription =>
      'Domain-based Message Authentication, Reporting & Conformance (DMARC) informa aos servidores de e-mail o que fazer quando as verificações SPF ou DKIM falharem.';

  @override
  String get emailSecurity_dmarcPolicy => 'Política';

  @override
  String get emailSecurity_dmarcPolicyHint =>
      'Ação a tomar em caso de falha de autenticação';

  @override
  String get emailSecurity_dmarcPolicyNone => 'Nenhuma (Apenas monitorar)';

  @override
  String get emailSecurity_dmarcPolicyQuarantine =>
      'Quarentena (Marcar como spam)';

  @override
  String get emailSecurity_dmarcPolicyReject => 'Rejeitar (Bloquear entrega)';

  @override
  String get emailSecurity_dmarcRua => 'E-mail para Relatórios Agregados (rua)';

  @override
  String get emailSecurity_dmarcRuaHint => 'ex: dmarc-reports@seudominio.com';

  @override
  String get emailSecurity_dmarcRuf => 'E-mail para Relatórios Forenses (ruf)';

  @override
  String get emailSecurity_dmarcRufHint =>
      'Opcional: relatórios forenses de falhas';

  @override
  String get emailSecurity_dmarcPct => 'Percentual de e-mails a filtrar';

  @override
  String get emailSecurity_dmarcSaved => 'Registro DMARC salvo com sucesso';

  @override
  String get emailSecurity_preview => 'Pré-visualização';

  @override
  String get emailSecurity_recordName => 'Nome do Registro';

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
  String get dnssecDetails_keyTag => 'Key Tag';

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
  String get settings_apiTokenHint => 'Insira seu Token da API Cloudflare';

  @override
  String get settings_apiTokenDescription =>
      'Seu token precisa das seguintes permissões:';

  @override
  String get settings_apiTokenPermission1 =>
      'Zone:Read - para listar suas zonas';

  @override
  String get settings_apiTokenPermission2 =>
      'DNS:Edit - para gerenciar registros DNS';

  @override
  String get settings_apiTokenPermission3 =>
      'Zone Settings:Read - para status DNSSEC';

  @override
  String get settings_apiTokenPermission4 =>
      'Zone Settings:Edit - para alternar DNSSEC';

  @override
  String get settings_apiTokenPermission5 =>
      'Analytics:Read - para analytics DNS';

  @override
  String get settings_createToken => 'Crie um token em dash.cloudflare.com';

  @override
  String get settings_tokenValid => 'Token válido';

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
  String get settings_amoledMode => 'AMOLED Black';

  @override
  String get settings_amoledModeDescription =>
      'Fundo preto puro no modo escuro (economiza bateria em telas OLED)';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_languageEn => 'Inglês';

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
  String get error_network => 'Erro de rede. Verifique sua conexão.';

  @override
  String get error_unauthorized => 'Token de API inválido ou expirado';

  @override
  String get error_forbidden =>
      'Você não tem permissão para acessar este recurso';

  @override
  String get error_notFound => 'Recurso não encontrado';

  @override
  String get error_rateLimited =>
      'Muitas requisições. Tente novamente mais tarde.';

  @override
  String get error_serverError =>
      'Erro no servidor. Tente novamente mais tarde.';

  @override
  String error_prefix(String message) {
    return 'Erro: $message';
  }

  @override
  String get error_copyError => 'Copiar Detalhes do Erro';

  @override
  String get error_permissionsRequired => 'Permissões Necessárias';

  @override
  String get error_permissionsDescription =>
      'Seu token de API não tem as permissões necessárias. Verifique as configurações no painel da Cloudflare.';

  @override
  String get error_checkCloudflareDashboard => 'Verificar Painel Cloudflare';

  @override
  String get error_commonPermissionsTitle => 'Permissões comuns necessárias:';

  @override
  String get pwa_updateAvailable => 'Nova versão disponível';

  @override
  String get pwa_updateNow => 'Atualizar Agora';

  @override
  String get pwa_installApp => 'Instalar App';

  @override
  String get pwa_installDescription =>
      'Instale o Dash for CF para acesso rápido';

  @override
  String get settings_cloudflareApiToken => 'Token API Cloudflare';

  @override
  String get settings_requiredPermissions =>
      'Permissões: Zone:Read, DNS:Read, DNS:Edit';

  @override
  String get settings_createTokenOnCloudflare => 'Criar token no Cloudflare';

  @override
  String get settings_tokenPastedFromClipboard =>
      'Token colado da área de transferência';

  @override
  String get settings_storage => 'Armazenamento';

  @override
  String get settings_clearCache => 'Limpar Cache';

  @override
  String get settings_clearCacheDescription =>
      'Registros DNS, analytics e data centers';

  @override
  String get settings_clearCacheTitle => 'Limpar Cache';

  @override
  String get settings_clearCacheMessage =>
      'Isso limpará todos os dados em cache.\n\nOs dados serão recarregados da API no próximo acesso.';

  @override
  String get settings_cacheCleared => 'Cache limpo com sucesso';

  @override
  String get settings_debug => 'Depuração';

  @override
  String get settings_saveLogsToFile => 'Salvar logs em arquivo';

  @override
  String get settings_saveLogsDescription =>
      'Mantém logs para análise posterior';

  @override
  String get settings_viewDebugLogs => 'Ver Logs de Depuração';

  @override
  String get settings_goToDnsManagement => 'Gerenciar DNS';

  @override
  String get debugLogs_title => 'Logs de Depuração';

  @override
  String get debugLogs_copyAll => 'Copiar Tudo';

  @override
  String get debugLogs_saveToFile => 'Salvar em Arquivo';

  @override
  String get debugLogs_shareAsText => 'Compartilhar Texto';

  @override
  String get debugLogs_shareAsFile => 'Compartilhar Arquivo';

  @override
  String get debugLogs_clearLogs => 'Limpar Logs';

  @override
  String get debugLogs_logsCopied => 'Logs copiados';

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
  String get debugLogs_logEntryCopied => 'Log copiado';

  @override
  String get debugLogs_timeRange => 'Período:';

  @override
  String get debugLogs_filter => 'Filtro:';

  @override
  String debugLogs_entries(int count) {
    return '$count entradas';
  }

  @override
  String get debugLogs_noLogsInRange => 'Sem logs neste período';

  @override
  String get debugLogs_tryLongerRange => 'Tente um período maior';

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
  String get dnsRecord_enterValue => 'Insira o valor';

  @override
  String emptyState_noResultsFor(String query) {
    return 'Nenhum resultado para \"$query\"';
  }

  @override
  String get emptyState_tryAdjustingSearch =>
      'Tente ajustar seus termos de busca';

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
  String get pages_statusBuilding => 'Construindo';

  @override
  String get pages_statusQueued => 'Na fila';

  @override
  String get pages_statusSkipped => 'Pulado';

  @override
  String get pages_statusUnknown => 'Desconhecido';

  @override
  String get pages_openInBrowser => 'Abrir no navegador';

  @override
  String get pages_deployments => 'Implantações';

  @override
  String get pages_noDeployments => 'Nenhuma implantação encontrada';

  @override
  String get pages_production => 'Produção';

  @override
  String get pages_preview => 'Preview';

  @override
  String get pages_deploymentDetails => 'Detalhes da Implantação';

  @override
  String get pages_commitInfo => 'Informações do Commit';

  @override
  String get pages_buildStages => 'Etapas do Build';

  @override
  String get pages_rollback => 'Reverter';

  @override
  String get pages_rollbackConfirmTitle => 'Reverter Implantação';

  @override
  String get pages_rollbackConfirmMessage =>
      'Tem certeza que deseja reverter para esta implantação? Ela se tornará a versão atual de produção.';

  @override
  String get pages_rollbackSuccess => 'Reversão concluída';

  @override
  String get pages_retry => 'Tentar novamente';

  @override
  String get pages_retryConfirmTitle => 'Repetir Implantação';

  @override
  String get pages_retryConfirmMessage =>
      'Tem certeza que deseja repetir esta implantação? Isso iniciará um novo build.';

  @override
  String get pages_retrySuccess => 'Repetição iniciada';

  @override
  String get pages_autoDeployPaused => 'Auto-deploy pausado';

  @override
  String get pages_buildLogs => 'Logs do Build';

  @override
  String get pages_noLogs => 'Nenhum log disponível';

  @override
  String get pages_autoScrollOn => 'Auto-scroll ativado';

  @override
  String get pages_autoScrollOff => 'Auto-scroll desativado';

  @override
  String pages_logCount(int current, int total) {
    return '$current de $total linhas';
  }

  @override
  String get pages_customDomains => 'Domínios Customizados';

  @override
  String get pages_addDomain => 'Adicionar Domínio';

  @override
  String get pages_deleteDomainConfirmTitle => 'Excluir Domínio Customizado?';

  @override
  String pages_deleteDomainConfirmMessage(String domain) {
    return 'Tem certeza que deseja excluir \"$domain\"?';
  }

  @override
  String get pages_buildSettings => 'Configurações de Build';

  @override
  String get pages_buildCommand => 'Comando de Build';

  @override
  String get pages_outputDirectory => 'Diretório de Saída';

  @override
  String get pages_rootDirectory => 'Diretório Raiz';

  @override
  String get pages_environmentVariables => 'Variáveis de Ambiente';

  @override
  String get pages_productionEnv => 'Ambiente de Produção';

  @override
  String get pages_previewEnv => 'Ambiente de Preview';

  @override
  String get pages_addVariable => 'Adicionar Variável';

  @override
  String get pages_variableName => 'Nome';

  @override
  String get pages_variableValue => 'Valor';

  @override
  String get pages_secret => 'Secret';

  @override
  String get pages_plainText => 'Texto Simples';

  @override
  String get pages_compatibilityDate => 'Data de Compatibilidade';

  @override
  String get pages_compatibilityFlags => 'Flags de Compatibilidade';

  @override
  String get pages_saveSettings => 'Salvar Configurações';

  @override
  String get pages_settingsUpdated => 'Configurações atualizadas';

  @override
  String get pages_domainAdded => 'Domínio adicionado';

  @override
  String get pages_domainDeleted => 'Domínio excluído';

  @override
  String get pages_domainNameHint => 'exemplo.com';

  @override
  String get pages_gitRepository => 'Repositório Git';

  @override
  String get pages_productionBranch => 'Branch de Produção';

  @override
  String get pages_automaticDeployments => 'Deployments de Preview';

  @override
  String get pages_automaticDeploymentsDescription =>
      'Implantações automáticas para branches de preview';

  @override
  String get pages_productionDeployments => 'Deployments de Produção';

  @override
  String get pages_productionDeploymentsDescription =>
      'Implantações automáticas para a branch de produção';

  @override
  String get pages_prComments => 'Comentários em PR';

  @override
  String get pages_buildSystemVersion => 'Versão do Sistema de Build';

  @override
  String get pages_buildOutput => 'Saída do Build';

  @override
  String get pages_buildComments => 'Comentários do Build';

  @override
  String get pages_buildCache => 'Cache do Build';

  @override
  String get pages_buildWatchPaths => 'Caminhos de Monitoramento';

  @override
  String get pages_includePaths => 'Caminhos Incluídos';

  @override
  String get pages_deployHooks => 'Hooks de Deploy';

  @override
  String get pages_noDeployHooks => 'Nenhum hook de deploy definido';

  @override
  String get pages_runtime => 'Runtime';

  @override
  String get pages_placement => 'Placement';

  @override
  String get pages_usageModel => 'Modelo de Uso';

  @override
  String get pages_bindings => 'Bindings';

  @override
  String get pages_addBinding => 'Adicionar Binding';

  @override
  String get pages_variableType => 'Tipo';

  @override
  String get pages_variableSecret => 'Secret';

  @override
  String get pages_variablePlainText => 'Texto Simples';

  @override
  String get pages_functionsBilling => 'Faturamento de Functions';

  @override
  String get pages_cpuTimeLimit => 'Limite de tempo de CPU';

  @override
  String get pages_accessPolicy => 'Política de Acesso';

  @override
  String get pages_dangerZone => 'Zona de Perigo';

  @override
  String get pages_deleteProject => 'Excluir Projeto';

  @override
  String get pages_deleteProjectDescription =>
      'Excluir permanentemente este projeto Pages, incluindo todos os deployments, assets, funções e configurações associadas.';

  @override
  String get pages_deleteProjectConfirmTitle => 'Excluir Projeto?';

  @override
  String pages_deleteProjectConfirmMessage(String project) {
    return 'Tem certeza que deseja excluir $project? Esta ação não pode ser desfeita e excluirá todos os deployments.';
  }

  @override
  String get pages_projectDeleted => 'Projeto excluído com sucesso';

  @override
  String get workers_title => 'Workers';

  @override
  String get workers_noWorkers => 'Nenhum script Workers encontrado';

  @override
  String get workers_searchWorkers => 'Buscar Workers...';

  @override
  String workers_lastModified(String date) {
    return 'Modificado em: $date';
  }

  @override
  String get workers_tabs_overview => 'Visão Geral';

  @override
  String get workers_tabs_triggers => 'Gatilhos';

  @override
  String get workers_tabs_settings => 'Configurações';

  @override
  String get workers_metrics_requests => 'Requisições';

  @override
  String get workers_metrics_errors => 'Exceções';

  @override
  String get workers_metrics_cpuTime => 'Tempo de CPU';

  @override
  String get workers_metrics_noData =>
      'Sem métricas disponíveis para este período';

  @override
  String get workers_triggers_customDomains => 'Domínios Customizados';

  @override
  String get workers_triggers_routes => 'Rotas';

  @override
  String get workers_triggers_addRoute => 'Adicionar Rota';

  @override
  String get workers_triggers_addDomain => 'Adicionar Domínio Customizado';

  @override
  String get workers_triggers_routePattern => 'Padrão da Rota';

  @override
  String get workers_triggers_routePatternHint => 'exemplo.com/*';

  @override
  String get workers_triggers_deleteRouteConfirm =>
      'Tem certeza que deseja excluir esta rota?';

  @override
  String get workers_triggers_deleteDomainConfirm =>
      'Tem certeza que deseja desconectar este domínio?';

  @override
  String get workers_triggers_routeAdded => 'Rota adicionada com sucesso';

  @override
  String get workers_triggers_routeDeleted => 'Rota excluída com sucesso';

  @override
  String get workers_triggers_domainAdded => 'Domínio conectado com sucesso';

  @override
  String get workers_triggers_domainDeleted =>
      'Domínio desconectado com sucesso';

  @override
  String get workers_triggers_cron => 'Cron Triggers';

  @override
  String get workers_triggers_cronExpression => 'Expressão Cron';

  @override
  String get workers_triggers_cronFormat =>
      'Formato: Minuto Hora Dia Mês DiaSemana';

  @override
  String get workers_triggers_deleteScheduleConfirm =>
      'Tem certeza que deseja remover este cron trigger?';

  @override
  String get workers_triggers_noRoutes =>
      'Nenhuma rota configurada para esta zona';

  @override
  String get workers_triggers_noSchedules => 'Nenhum cron trigger configurado';

  @override
  String get workers_triggers_domainManagedByCloudflare =>
      'O domínio deve ser gerenciado pelo Cloudflare.';

  @override
  String get workers_triggers_zoneNotFound =>
      'Zona não encontrada para este hostname.';

  @override
  String get workers_settings_bindings => 'Bindings';

  @override
  String get workers_settings_variables => 'Variáveis de Ambiente';

  @override
  String get workers_settings_compatibility => 'Compatibilidade';

  @override
  String get workers_settings_usageModel => 'Modelo de Uso';

  @override
  String get workers_bindings_kv => 'Namespace KV';

  @override
  String get workers_bindings_r2 => 'Bucket R2';

  @override
  String get workers_bindings_d1 => 'Banco de Dados D1';

  @override
  String get workers_bindings_do => 'Durable Object';

  @override
  String get workers_bindings_service => 'Serviço';

  @override
  String get workers_bindings_queue => 'Fila';

  @override
  String get workers_settings_addBinding => 'Adicionar Binding';

  @override
  String get workers_settings_bindingType => 'Tipo';

  @override
  String get workers_settings_envVariable => 'Variável de Ambiente';

  @override
  String get workers_settings_bindingSecret => 'Secret';

  @override
  String get workers_settings_updateSecret => 'Atualizar Secret';

  @override
  String get workers_settings_secretValue => 'Valor do Secret';

  @override
  String get workers_settings_secretHint =>
      'Insira o valor do secret (somente escrita)';

  @override
  String get workers_settings_observability => 'Observabilidade';

  @override
  String get workers_settings_logs => 'Logs do Workers';

  @override
  String get workers_settings_traces => 'Traces do Workers';

  @override
  String get workers_settings_logpush => 'Logpush';

  @override
  String get workers_settings_tail => 'Tail Worker';

  @override
  String get workers_settings_tailDescription =>
      'Transmitir logs em tempo real do seu Worker';

  @override
  String get workers_settings_deleteWorker => 'Excluir Worker';

  @override
  String get workers_settings_deleteWorkerConfirm =>
      'Tem certeza que deseja excluir este Worker? Esta ação não pode ser desfeita e excluirá todos os arquivos, configurações e deployments.';

  @override
  String get workers_settings_domainsAndRoutes => 'Domínios e Rotas';

  @override
  String get workers_settings_build => 'Build';

  @override
  String get workers_settings_gitIntegration => 'Integração Git';

  @override
  String get workers_settings_gitIntegrationDescription =>
      'Configurar CI/CD no Dashboard da Cloudflare';

  @override
  String get workers_settings_noAccountSelected => 'Nenhuma conta selecionada';

  @override
  String get workers_tail_title => 'Logs do Worker (Tail)';

  @override
  String get workers_tail_connected => 'Conectado';

  @override
  String get workers_tail_connecting => 'Conectando...';

  @override
  String get workers_tail_disconnected => 'Desconectado';

  @override
  String get workers_tail_start => 'Iniciar';

  @override
  String get workers_tail_stop => 'Parar';

  @override
  String get workers_tail_clear => 'Limpar logs';

  @override
  String get workers_tail_autoScroll => 'Auto-scroll';

  @override
  String get workers_tail_filterAll => 'Todos';

  @override
  String get workers_tail_filterLog => 'Log';

  @override
  String get workers_tail_filterWarn => 'Avisos';

  @override
  String get workers_tail_filterError => 'Erros';

  @override
  String workers_tail_logCount(int count) {
    return '$count logs';
  }

  @override
  String get workers_tail_noLogsYet =>
      'Nenhum log ainda. Acione seu worker para ver logs.';

  @override
  String get workers_tail_notConnected =>
      'Não conectado. Clique em Iniciar para começar.';

  @override
  String get workers_settings_viewDomains => 'Ver Domínios';

  @override
  String get workers_settings_viewRoutes => 'Ver Rotas';

  @override
  String get workers_settings_pricing => 'Preço';
}
