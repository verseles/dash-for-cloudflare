import { mount, VueWrapper } from '@vue/test-utils'
import { Quasar } from 'quasar'
import { Component, Plugin } from 'vue'
import { createPinia } from 'pinia'
import { createI18n } from 'vue-i18n'

interface MountQuasarOptions {
  props?: Record<string, unknown>
  slots?: Record<string, unknown>
  global?: Record<string, unknown>
  usePinia?: boolean
  useI18n?: boolean
}

export function mountQuasar(
  component: Component,
  options: MountQuasarOptions = {}
): VueWrapper {
  const plugins: Plugin[] = [Quasar as unknown as Plugin]

  if (options.usePinia !== false) {
    plugins.push(createPinia() as unknown as Plugin)
  }

  if (options.useI18n) {
    plugins.push(
      createI18n({
        legacy: false,
        locale: 'en-US',
        fallbackLocale: 'en-US',
        messages: {}
      }) as unknown as Plugin
    )
  }

  return mount(component, {
    props: options.props,
    slots: options.slots,
    global: {
      plugins,
      ...options.global
    }
  })
}
