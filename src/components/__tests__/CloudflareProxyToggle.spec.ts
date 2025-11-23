import { describe, it, expect, vi } from 'vitest';
import { mount } from '@vue/test-utils';
import { createI18n } from 'vue-i18n';
import CloudflareProxyToggle from '../CloudflareProxyToggle.vue';

// Mock useI18n
vi.mock('src/composables/useI18n', () => ({
  useI18n: () => ({
    t: (key: string) => key,
  }),
}));

const messages = {
  'en-US': {
    dns: {
      cloudflareProxy: 'Cloudflare Proxy',
    },
  },
};

describe('CloudflareProxyToggle', () => {
  const mountComponent = (
    props: { modelValue: boolean; disable?: boolean; tooltip?: boolean } = { modelValue: false },
  ) => {
    const i18n = createI18n({
      legacy: false,
      locale: 'en-US',
      fallbackLocale: 'en-US',
      messages,
    });

    return mount(CloudflareProxyToggle, {
      props,
      global: {
        plugins: [i18n],
      },
    });
  };

  it('should mount correctly', () => {
    const wrapper = mountComponent();
    expect(wrapper.exists()).toBe(true);
  });

  it('should render toggle in unchecked state', () => {
    const wrapper = mountComponent({ modelValue: false });
    const toggle = wrapper.find('.q-toggle');
    expect(toggle.exists()).toBe(true);
  });

  it('should render toggle in checked state', () => {
    const wrapper = mountComponent({ modelValue: true });
    const toggle = wrapper.find('.q-toggle');
    expect(toggle.exists()).toBe(true);
  });

  it('should emit update:modelValue when toggled', async () => {
    const wrapper = mountComponent({ modelValue: false });
    const toggle = wrapper.findComponent({ name: 'QToggle' });

    await toggle.vm.$emit('update:modelValue', true);

    expect(wrapper.emitted('update:modelValue')).toBeTruthy();
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([true]);
  });

  it('should be disabled when disable prop is true', () => {
    const wrapper = mountComponent({ modelValue: false, disable: true });
    const toggle = wrapper.find('.q-toggle');
    expect(toggle.classes()).toContain('disabled');
  });

  it('should show tooltip when tooltip prop is true', () => {
    const wrapper = mountComponent({ modelValue: false, tooltip: true });
    const tooltip = wrapper.findComponent({ name: 'QTooltip' });
    expect(tooltip.exists()).toBe(true);
  });
});
