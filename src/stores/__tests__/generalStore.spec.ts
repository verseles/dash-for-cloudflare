import { describe, it, expect, beforeEach, vi } from 'vitest';
import { setActivePinia, createPinia } from 'pinia';
import { useGeneralStore } from '../generalStore';

// Mock useQuasar
const mockNotify = vi.fn();
vi.mock('quasar', async () => {
  // eslint-disable-next-line @typescript-eslint/consistent-type-imports
  const actual = await vi.importActual<typeof import('quasar')>('quasar');
  return {
    ...actual,
    useQuasar: () => ({
      notify: mockNotify,
    }),
  };
});

// Mock useI18n
vi.mock('src/composables/useI18n', () => ({
  useI18n: () => ({
    t: (key: string) => key,
  }),
}));

describe('generalStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
    vi.clearAllMocks();
  });

  it('should have showWorkInProgressNotification function', () => {
    const store = useGeneralStore();
    expect(typeof store.showWorkInProgressNotification).toBe('function');
  });

  it('should show notification when showWorkInProgressNotification is called', () => {
    const store = useGeneralStore();
    store.showWorkInProgressNotification();

    expect(mockNotify).toHaveBeenCalledWith({
      message: 'common.workInProgress',
      color: 'info',
      position: 'top',
    });
  });
});
