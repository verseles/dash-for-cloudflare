import { describe, it, expect, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createI18n } from 'vue-i18n'
import { defineComponent, h, nextTick } from 'vue'
import { useI18n } from '../useI18n'

const messages = {
  'en-US': {
    test: {
      hello: 'Hello World'
    }
  },
  'pt-BR': {
    test: {
      hello: 'Ola Mundo'
    }
  }
}

describe('useI18n', () => {
  let i18n: ReturnType<typeof createI18n>

  beforeEach(() => {
    i18n = createI18n({
      legacy: false,
      locale: 'en-US',
      fallbackLocale: 'en-US',
      messages
    })
  })

  it('should return t function', () => {
    const TestComponent = defineComponent({
      setup() {
        const { t } = useI18n()
        return { t }
      },
      render() {
        return h('div', this.t('test.hello'))
      }
    })

    const wrapper = mount(TestComponent, {
      global: {
        plugins: [i18n]
      }
    })

    expect(wrapper.text()).toBe('Hello World')
  })

  it('should return locale ref', () => {
    const TestComponent = defineComponent({
      setup() {
        const { locale } = useI18n()
        return { locale }
      },
      render() {
        return h('div', this.locale)
      }
    })

    const wrapper = mount(TestComponent, {
      global: {
        plugins: [i18n]
      }
    })

    expect(wrapper.text()).toBe('en-US')
  })

  it('should allow changing locale with setLocale', async () => {
    const TestComponent = defineComponent({
      setup() {
        const { t, setLocale, locale } = useI18n()
        return { t, setLocale, locale }
      },
      render() {
        return h('div', [
          h('span', { class: 'text' }, this.t('test.hello')),
          h('span', { class: 'locale' }, this.locale)
        ])
      }
    })

    const wrapper = mount(TestComponent, {
      global: {
        plugins: [i18n]
      }
    })

    expect(wrapper.find('.text').text()).toBe('Hello World')
    expect(wrapper.find('.locale').text()).toBe('en-US')

    wrapper.vm.setLocale('pt-BR')
    await nextTick()

    expect(wrapper.find('.locale').text()).toBe('pt-BR')
  })
})
