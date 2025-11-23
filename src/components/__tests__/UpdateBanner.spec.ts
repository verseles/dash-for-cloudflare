import { describe, it, expect } from 'vitest';
import { mount, flushPromises } from '@vue/test-utils';
import { createI18n } from 'vue-i18n';
import UpdateBanner from '../UpdateBanner.vue';

const messages = {
  'en-US': {
    pwaUpdate: {
      newVersionAvailable: 'New version available!',
      updateNow: 'Update Now',
    },
  },
};

describe('UpdateBanner', () => {
  const mountComponent = (props = { modelValue: true }) => {
    // Create fresh i18n instance for each test
    const i18n = createI18n({
      legacy: false,
      locale: 'en-US',
      fallbackLocale: 'en-US',
      messages,
    });

    return mount(UpdateBanner, {
      props,
      global: {
        plugins: [i18n],
      },
    });
  };

  it('mounts the component correctly', () => {
    const wrapper = mountComponent();
    expect(wrapper.exists()).toBe(true);
  });

  it('shows banner when modelValue is true', () => {
    const wrapper = mountComponent({ modelValue: true });
    expect(wrapper.find('.q-banner').exists()).toBe(true);
  });

  it('hides banner when modelValue is false', () => {
    const wrapper = mountComponent({ modelValue: false });
    expect(wrapper.find('.q-banner').exists()).toBe(false);
  });

  it('displays the update message', () => {
    const wrapper = mountComponent({ modelValue: true });
    expect(wrapper.text()).toContain('New version available!');
  });

  it('emits update-app event when update button is clicked', async () => {
    const wrapper = mountComponent({ modelValue: true });
    const updateBtn = wrapper.findAll('.q-btn').find((btn) => btn.text().includes('Update Now'));
    expect(updateBtn).toBeDefined();

    await updateBtn?.trigger('click');
    expect(wrapper.emitted('update-app')).toBeTruthy();
  });

  it('emits update:modelValue when close button is clicked', async () => {
    const wrapper = mountComponent({ modelValue: true });
    const closeBtn = wrapper.findAll('.q-btn').find((btn) => btn.find('.q-icon').exists());

    await closeBtn?.trigger('click');
    await flushPromises();

    expect(wrapper.emitted('update:modelValue')).toBeTruthy();
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false]);
  });
});
