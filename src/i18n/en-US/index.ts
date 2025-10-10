export default {
  menu: {
    dns: 'DNS Management',
    settings: 'Settings',
  },
  settings: {
    title: 'Settings',
    apiToken: 'Cloudflare API Token',
    apiTokenPlaceholder: 'Enter your API token',
    apiTokenHint: 'Your token is stored exclusively on your device.',
    apiTokenHelp: {
      title: 'The token requires the following permissions:',
      dns: 'Zone.DNS - To edit DNS records',
      analytics: 'Zone.Analytics - To view analytics',
      dnsSettings: 'Zone.DNSSettings - To modify general DNS options',
      createTokenLink: 'Create a new token',
    },
    apiTokenError: 'The API token must be at least 40 characters long.',
    apiTokenSaved: 'API Token saved successfully!',
    themeSaved: 'Theme preference saved!',
    languageSaved: 'Language preference saved!',
    tokenRequired: 'Please enter a valid API token first',
    tokenRequiredForDns: 'An API token is required to access the DNS section.',
    goToDns: 'Go to DNS Management',
    appearance: 'Appearance',
    darkMode: 'Dark Mode',
    light: 'Light',
    dark: 'Dark',
    uiMode: 'UI Mode',
    uiModeOptions: {
      auto: 'Auto',
      ios: 'iOS',
      md: 'Material Design',
    },
    language: 'Language',
    languageOptions: {
      en: 'English',
      ptBR: 'Portuguese (BR)',
    },
  },
  dns: {
    title: 'DNS Management',
    cloudflareProxy: 'Cloudflare Proxy',
    zoneSelector: 'Select a Zone',
    loadingZones: 'Loading zones...',
    noRecords: 'No DNS records found for this zone.',
    noRecordsForFilter: 'No records found for this filter.',
    selectZoneFirst: 'Please select a zone first',
    filterAll: 'All',
    save: 'Save',
    delete: 'Delete',
    record: {
      type: 'Type',
      name: 'Name',
      content: 'Content',
      proxied: 'Proxied',
      ttl: 'TTL',
    },
    toasts: {
      zoneSelected: 'Zone {zoneName} selected.',
      recordSaved: 'Record {recordName} saved successfully!',
      recordCreated: 'Record {recordName} created successfully!',
      recordDeleted: 'Record {recordName} deleted.',
      errorSaving: 'Error saving record: {error}',
      errorCreating: 'Error creating record: {error}',
      errorDeleting: 'Error deleting record: {error}',
      errorLoadingRecords: 'Error loading records: {error}',
    },
    confirmDelete: {
      title: 'Delete DNS Record',
      message:
        'Are you sure you want to delete the {recordType} record for "{recordName}"? This action cannot be undone.',
    },
    editRecord: {
      title: 'Edit DNS Record',
      type: 'Record Type',
      name: 'Name',
      content: 'Content',
      ttl: 'TTL',
      proxied: 'Cloudflare Proxy',
      proxiedDescription:
        "Route traffic through Cloudflare's network for enhanced security and performance",
      priority: 'Priority',
      namePlaceholder: "subdomain or {'@'} for root",
      create: 'Create Record',
      update: 'Update Record',
    },
    tabs: {
      records: 'Records',
      analytics: 'Analytics',
      settings: 'Settings',
    },
    analytics: {
      title: 'DNS Analytics',
      queryOverview: 'Query overview',
      queryStatistics: 'Query statistics',
      totalQueries: 'Total queries',
      totalQueriesHelp: 'Total number of DNS queries received in the selected period',
      avgQueriesPerSecond: 'Average queries per second',
      avgQueriesPerSecondHelp: 'Average DNS queries processed per second',
      avgProcessingTime: 'Average processing time (ms)',
      avgProcessingTimeHelp: 'Average time taken to process DNS queries',
      queriesOverTime: 'Queries over time',
      queryTypes: 'Query types',
      responseCodes: 'Response codes',
      topQueryNames: 'Top query names',
      noData: 'No analytics data to display for the selected period.',
      timeRange: {
        '24h': '24 Hours',
        '7d': '7 Days',
        '30d': '30 Days',
      },
    },
    settings: {
      title: 'DNS Settings',
      placeholder: 'Settings content will be implemented here.',
    },
    settingsPage: {
      title: 'Settings',
      subtitle: 'Manage DNS-specific settings for your domain.',
      docsLink: 'DNS documentation',
      dnssecCard: {
        title: 'DNSSEC',
        description: 'DNSSEC uses a cryptographic signature of published DNS records to protect your domain against forged DNS answers.',
        pending: 'DNSSEC is pending while we wait for the DS to be added to your registrar. This usually takes ten minutes, but can take up to an hour.',
        cancelBtn: 'Cancel Setup',
        dsRecordBtn: 'DS Record'
      },
      multiSigner: {
        title: 'Multi-signer DNSSEC',
        description: 'Multi-signer DNSSEC allows Cloudflare and your other authoritative DNS providers to serve the same zone and have DNSSEC enabled at the same time.'
      },
      multiProvider: {
        title: 'Multi-provider DNS',
        description: 'Multi-provider DNS allows domains using a full DNS setup to be active on Cloudflare while using another authoritative DNS provider in addition to Cloudflare. Also allows the domain to serve any apex NS records added to its DNS configuration at Cloudflare.'
      },
      cnameFlattening: {
        title: 'CNAME flattening for all CNAME records',
        description: 'Speed up DNS resolution on CNAMEs by having Cloudflare return the IP address of the final destination in the CNAME chain. Enabling this setting allows you to flatten all CNAMEs within your zone. With this setting disabled, any CNAME at the apex is flattened by default and you may choose to individually flatten specific CNAMEs.'
      },
      emailSecurity: {
        title: 'Email Security',
        description: 'Protect your domain from email spoofing and phishing by creating the required DNS records.',
        configureBtn: 'Configure'
      },
      help: 'Help',
      toasts: {
        fetchError: 'Failed to load DNS settings: {error}',
        updateSuccess: 'Setting "{setting}" updated successfully.',
        updateError: 'Failed to update setting "{setting}": {error}'
      }
    }
  },
  common: {
    cancel: 'Cancel',
    workInProgress: 'Sorry, work in progress',
  },
}