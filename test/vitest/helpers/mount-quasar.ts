import { mount, VueWrapper } from '@vue/test-utils'
import { Quasar } from 'quasar'
import { Component } from 'vue'
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
  const plugins: unknown[] = [Quasar]

  if (options.usePinia !== false) {
    plugins.push(createPinia())
  }

  if (options.useI18n) {
    plugins.push(
      createI18n({
        legacy: false,
        locale: 'en-US',
        fallbackLocale: 'en-US',
        messages: {}
      })
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
