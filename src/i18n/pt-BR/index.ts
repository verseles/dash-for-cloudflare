import dns from './modules/dns';
import settings from './modules/settings';

export default {
  common: {
    ok: 'OK',
    cancel: 'Cancelar',
    workInProgress: 'Em desenvolvimento. Esta funcionalidade estará disponível em breve!',
  },
  menu: {
    dns: 'DNS',
    settings: 'Configurações',
  },
  pwaUpdate: {
    newVersionAvailable: 'Uma nova versão está disponível!',
    updateNow: 'Atualizar Agora',
  },
  dns,
  settings,
};
