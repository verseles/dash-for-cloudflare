import { setActivePinia, createPinia } from 'pinia';
import { beforeEach } from 'vitest';

export function setupStoreTests() {
  beforeEach(() => {
    setActivePinia(createPinia());
  });
}
