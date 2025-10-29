import dns from './modules/dns'
import domains from './modules/domains'
import settings from './modules/settings'

export default {
  common: {
    ok: 'OK',
    cancel: 'Cancel',
    workInProgress: 'Work in progress. This feature will be available soon!',
  },
  menu: {
    dns: 'DNS',
    domains: 'Domains',
    settings: 'Settings',
  },
  pwaUpdate: {
    newVersionAvailable: 'A new version is available!',
    updateNow: 'Update Now',
  },
  dns,
  domains,
  settings,
}