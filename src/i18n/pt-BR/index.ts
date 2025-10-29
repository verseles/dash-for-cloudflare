import dns from './modules/dns'
import domains from './modules/domains'
import settings from './modules/settings'

export default {
  common: {
    ok: 'OK',
    cancel: 'Cancelar',
    workInProgress: 'Em desenvolvimento. Esta funcionalidade estará disponível em breve!',
  },
  menu: {
    dns: 'DNS',
    domains: 'Domínios',
    settings: 'Configurações',
  },
  pwaUpdate: {
    newVersionAvailable: 'Uma nova versão está disponível!',
    updateNow: 'Atualizar Agora',
  },
  dns,
  domains,
  settings,
}