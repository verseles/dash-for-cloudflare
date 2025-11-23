import { reactive, watch } from 'vue';
import { useI18n } from 'src/composables/useI18n';
import { useQuasar, LocalStorage } from 'quasar';

// Storage key for settings
const STORAGE_KEY = 'dash_settings';

// Default settings
const defaultSettings = {
  cloudflareApiToken: '',


  theme: 'auto', // 'auto', 'light', 'dark'
  language: 'en-US',
};

// Reactive settings object - defined outside to act as a singleton state
const settings = reactive({ ...defaultSettings });

// Flag to ensure initialization only runs once
let isInitialized = false;

// Function to apply the current theme/mode using Quasar's Dark Plugin
const applyTheme = (themeValue: string, $q: ReturnType<typeof useQuasar>) => {
  if (themeValue === 'auto') {
    $q.dark.set('auto');
  } else {
    $q.dark.set(themeValue === 'dark');
  }
};

// Function to save settings to LocalStorage
const saveSettings = () => {
  try {
    LocalStorage.set(STORAGE_KEY, settings);
    console.log('Settings saved:', settings);
  } catch (error) {
    console.error('Failed to save settings:', error);
  }
};

// Function to load settings from LocalStorage
const loadSettings = () => {
  try {
    const storedSettings = LocalStorage.getItem(STORAGE_KEY);
    if (storedSettings) {
      // Merge stored settings with current settings
      Object.assign(settings, storedSettings);
      console.log('Settings loaded:', settings);
    } else {
      console.log('No stored settings found, using defaults');
    }
  } catch (error) {
    console.error('Failed to load settings:', error);
  }
};

export function useSettings() {
  const $q = useQuasar();
  const { setLocale } = useI18n();

  if (!isInitialized) {
    // Load settings from LocalStorage on first initialization
    loadSettings();

    // Apply loaded settings
    try {
      applyTheme(settings.theme, $q);
      setLocale(settings.language);
    } catch (e) {
      console.error('Failed to apply initial settings:', e);
    }

    // Watch for changes and save to LocalStorage
    watch(
      settings,
      (newSettings) => {
        // Save to LocalStorage
        saveSettings();

        // Apply changes dynamically
        applyTheme(newSettings.theme, $q);
        setLocale(newSettings.language);
      },
      { deep: true },
    );

    isInitialized = true;
    console.log('Settings initialized');
  }

  return {
    settings,
    loadSettings,
    saveSettings,
  };
}
