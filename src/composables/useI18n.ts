import { useI18n as useVueI18n } from 'vue-i18n'

export function useI18n() {
  const { t, locale } = useVueI18n()

  const setLocale = (newLocale: string) => {
    locale.value = newLocale
  }

  return {
    t,
    setLocale,
    locale,
  }
}
