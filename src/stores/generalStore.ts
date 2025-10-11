import { defineStore } from 'pinia'
import { useQuasar } from 'quasar'
import { useI18n } from 'src/composables/useI18n'

export const useGeneralStore = defineStore('general', () => {
  const $q = useQuasar()
  const { t } = useI18n()

  function showWorkInProgressNotification() {
    $q.notify({
      message: t('common.workInProgress'),
      color: 'info',
      position: 'top',
    })
  }

  return {
    showWorkInProgressNotification,
  }
})