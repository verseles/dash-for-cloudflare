export default {
  menu: {
    dns: 'Gerenciar DNS',
    settings: 'Configurações',
  },
  settings: {
    title: 'Configurações',
    apiToken: 'Token da API Cloudflare',
    apiTokenPlaceholder: 'Insira seu token da API',
    apiTokenHint: 'Seu token é salvo exclusivamente no seu aparelho.',
    apiTokenHelp: {
      title: 'O token requer as seguintes permissões:',
      dns: 'Zone.DNS - para editar registros DNS',
      analytics: 'Zone.Analytics - para visualizar analytics',
      dnsSettings: 'Zone.DNSSettings - para modificar opções gerais de DNS',
      createTokenLink: 'Criar um token novo',
    },
    apiTokenError: 'O token da API deve ter pelo menos 40 caracteres.',
    apiTokenSaved: 'Token da API salvo com sucesso!',
    themeSaved: 'Preferência de tema salva!',
    languageSaved: 'Preferência de idioma salva!',
    tokenRequired: 'Por favor, insira um token da API válido primeiro',
    tokenRequiredForDns: 'É necessário um token de API para acessar a seção de DNS.',
    goToDns: 'Ir para o Gerenciamento de DNS',
    appearance: 'Aparência',
    darkMode: 'Modo Escuro',
    light: 'Claro',
    dark: 'Escuro',
    uiMode: 'Modo de UI',
    uiModeOptions: {
      auto: 'Auto',
      ios: 'iOS',
      md: 'Material Design',
    },
    language: 'Idioma',
    languageOptions: {
      en: 'Inglês',
      ptBR: 'Português (BR)',
    },
  },
  dns: {
    title: 'Gerenciamento de DNS',
    cloudflareProxy: 'Proxy Cloudflare',
    zoneSelector: 'Selecione uma Zona',
    loadingZones: 'Carregando zonas...',
    noRecords: 'Nenhum registro DNS encontrado para esta zona.',
    noRecordsForFilter: 'Nenhum registro encontrado para este filtro.',
    selectZoneFirst: 'Por favor, selecione uma zona primeiro',
    filterAll: 'Todos',
    save: 'Salvar',
    delete: 'Excluir',
    record: {
      type: 'Tipo',
      name: 'Nome',
      content: 'Conteúdo',
      proxied: 'Proxy',
      ttl: 'TTL',
    },
    toasts: {
      zoneSelected: 'Zona {zoneName} selecionada.',
      recordSaved: 'Registro {recordName} salvo com sucesso!',
      recordCreated: 'Registro {recordName} criado com sucesso!',
      recordDeleted: 'Registro {recordName} excluído.',
      errorSaving: 'Erro ao salvar registro: {error}',
      errorCreating: 'Erro ao criar registro: {error}',
      errorDeleting: 'Erro ao excluir registro: {error}',
      errorLoadingRecords: 'Erro ao carregar registros: {error}',
    },
    confirmDelete: {
      title: 'Excluir Registro DNS',
      message:
        'Tem certeza que deseja excluir o registro {recordType} para "{recordName}"? Esta ação não pode ser desfeita.',
    },
    editRecord: {
      title: 'Editar Registro DNS',
      type: 'Tipo de Registro',
      name: 'Nome',
      content: 'Conteúdo',
      ttl: 'TTL',
      proxied: 'Proxy Cloudflare',
      proxiedDescription:
        'Roteia o tráfego pela rede da Cloudflare para maior segurança e desempenho',
      priority: 'Prioridade',
      namePlaceholder: "subdomínio ou {'@'} para raiz",
      create: 'Criar Registro',
      update: 'Atualizar Registro',
    },
    tabs: {
      records: 'Registros',
      analytics: 'Analytics',
      settings: 'Configurações',
    },
    analytics: {
      title: 'Análise DNS',
      queryOverview: 'Visão geral de consultas',
      queryStatistics: 'Estatísticas de consultas',
      totalQueries: 'Total de consultas',
      totalQueriesHelp: 'Número total de consultas DNS recebidas no período selecionado',
      avgQueriesPerSecond: 'Consultas médias por segundo',
      avgQueriesPerSecondHelp: 'Média de consultas DNS processadas por segundo',
      avgProcessingTime: 'Tempo médio de processamento (ms)',
      avgProcessingTimeHelp: 'Tempo médio levado para processar consultas DNS',
      queriesOverTime: 'Consultas ao longo do tempo',
      queryTypes: 'Tipos de consulta',
      responseCodes: 'Códigos de resposta',
      topQueryNames: 'Principais nomes consultados',
      noData: 'Nenhum dado de análise disponível para o período selecionado.',
      timeRange: {
        '24h': '24 Horas',
        '7d': '7 Dias',
        '30d': '30 Dias',
      },
    },
    settings: {
      title: 'Configurações de DNS',
      placeholder: 'O conteúdo de Configurações será implementado aqui.',
    },
    settingsPage: {
      title: 'Configurações',
      subtitle: 'Gerencie as configurações específicas de DNS para o seu domínio.',
      docsLink: 'Documentação de DNS',
      dnssecCard: {
        title: 'DNSSEC',
        description: 'O DNSSEC usa uma assinatura criptográfica dos registros DNS publicados para proteger seu domínio contra respostas DNS falsificadas.',
        pending: 'O DNSSEC está pendente enquanto aguardamos a adição do registro DS ao seu registrador. Isso geralmente leva dez minutos, mas pode levar até uma hora.',
        cancelBtn: 'Cancelar Configuração',
        dsRecordBtn: 'Registro DS'
      },
      multiSigner: {
        title: 'DNSSEC Multi-signer',
        description: 'O DNSSEC Multi-signer permite que a Cloudflare e seus outros provedores de DNS autoritativos sirvam a mesma zona e tenham o DNSSEC ativado ao mesmo tempo.'
      },
      multiProvider: {
        title: 'DNS Multi-provedor',
        description: 'O DNS Multi-provedor permite que domínios usando uma configuração de DNS completa estejam ativos na Cloudflare enquanto usam outro provedor de DNS autoritativo além da Cloudflare. Também permite que o domínio sirva quaisquer registros NS de ápice adicionados à sua configuração de DNS na Cloudflare.'
      },
      cnameFlattening: {
        title: 'CNAME flattening para todos os registros CNAME',
        description: 'Acelere a resolução de DNS em CNAMEs fazendo com que a Cloudflare retorne o endereço IP do destino final na cadeia de CNAME. Habilitar esta configuração permite achatar todos os CNAMEs dentro da sua zona. Com esta configuração desativada, qualquer CNAME no ápice é achatado por padrão e você pode optar por achatar CNAMEs específicos individualmente.'
      },
      emailSecurity: {
        title: 'Segurança de E-mail',
        description: 'Proteja seu domínio contra falsificação de e-mail e phishing criando os registros DNS necessários.',
        configureBtn: 'Configurar'
      },
      help: 'Ajuda',
      toasts: {
        fetchError: 'Falha ao carregar as configurações de DNS: {error}',
        updateSuccess: 'Configuração "{setting}" atualizada com sucesso.',
        updateError: 'Falha ao atualizar a configuração "{setting}": {error}'
      }
    }
  },
  common: {
    cancel: 'Cancelar',
  },
}