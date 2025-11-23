import { describe, it, expect, vi } from 'vitest';
import { mount } from '@vue/test-utils';
import { createI18n } from 'vue-i18n';
import DnsRecordItem from '../DnsRecordItem.vue';

// Mock useI18n
vi.mock('src/composables/useI18n', () => ({
  useI18n: () => ({
    t: (key: string) => key,
  }),
}));

const messages = {
  'en-US': {
    dns: {
      record: {
        ttl: 'Time to Live',
      },
      cloudflareProxy: 'Cloudflare Proxy',
    },
  },
};

const mockRecord = {
  id: 'record-1',
  type: 'A',
  name: 'example.com',
  content: '192.168.1.1',
  ttl: 3600,
  proxied: false,
  zone_id: 'zone-1',
  zone_name: 'example.com',
};

describe('DnsRecordItem', () => {
  const mountComponent = (props = {}) => {
    const i18n = createI18n({
      legacy: false,
      locale: 'en-US',
      fallbackLocale: 'en-US',
      messages,
    });

    return mount(DnsRecordItem, {
      props: {
        record: mockRecord,
        isSaving: false,
        ...props,
      },
      global: {
        plugins: [i18n],
      },
    });
  };

  it('should mount correctly', () => {
    const wrapper = mountComponent();
    expect(wrapper.exists()).toBe(true);
  });

  it('should display record type', () => {
    const wrapper = mountComponent();
    expect(wrapper.text()).toContain('A');
  });

  it('should display record content', () => {
    const wrapper = mountComponent();
    expect(wrapper.text()).toContain('192.168.1.1');
  });

  it('should display TTL', () => {
    const wrapper = mountComponent();
    expect(wrapper.text()).toContain('3600');
  });

  it('should display Auto for TTL of 1', () => {
    const wrapper = mountComponent({
      record: { ...mockRecord, ttl: 1 },
    });
    expect(wrapper.text()).toContain('Auto');
  });

  it('should emit edit event when item is clicked', async () => {
    const wrapper = mountComponent();
    const item = wrapper.find('.q-item');

    await item.trigger('click');

    expect(wrapper.emitted('edit')).toBeTruthy();
    expect(wrapper.emitted('edit')?.[0]).toEqual([mockRecord]);
  });

  it('should show @ for root domain record', () => {
    const wrapper = mountComponent({
      record: { ...mockRecord, name: 'example.com' },
      zoneName: 'example.com',
    });
    expect(wrapper.text()).toContain('@');
  });

  it('should strip zone name from subdomain', () => {
    const wrapper = mountComponent({
      record: { ...mockRecord, name: 'www.example.com' },
      zoneName: 'example.com',
    });
    expect(wrapper.find('strong').text()).toBe('www');
  });

  it('should show proxy toggle for A records', () => {
    const wrapper = mountComponent({
      record: { ...mockRecord, type: 'A' },
    });
    const toggle = wrapper.findComponent({ name: 'CloudflareProxyToggle' });
    expect(toggle.exists()).toBe(true);
  });

  it('should not show proxy toggle for MX records', () => {
    const wrapper = mountComponent({
      record: { ...mockRecord, type: 'MX' },
    });
    const toggle = wrapper.findComponent({ name: 'CloudflareProxyToggle' });
    expect(toggle.exists()).toBe(false);
  });

  it('should apply highlight class for new records', () => {
    const wrapper = mountComponent({
      isNewRecord: true,
    });
    expect(wrapper.find('.item-highlight-new').exists()).toBe(true);
  });

  it('should apply highlight class for deleting records', () => {
    const wrapper = mountComponent({
      isDeleting: true,
    });
    expect(wrapper.find('.item-highlight-delete').exists()).toBe(true);
  });
});
