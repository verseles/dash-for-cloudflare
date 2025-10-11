<template>
  <q-page padding>
    <div class="q-mx-auto" style="max-width: 800px">
      <div class="text-h4 q-mb-md">{{ t('dnsSettings.title') }}</div>

      <q-card flat bordered>
        <q-list separator>
          <q-item>
            <q-item-section>
              <q-item-label class="text-h6">Documentation</q-item-label>
            </q-item-section>
          </q-item>

          <q-item
            clickable
            tag="a"
            :href="dnsDocLink"
            target="_blank"
            rel="noopener noreferrer"
          >
            <q-item-section avatar>
              <q-icon name="description" />
            </q-item-section>
            <q-item-section>
              <q-item-label>DNS Security Documentation</q-item-label>
              <q-item-label caption
                >Learn about DNS security concepts from Cloudflare.</q-item-label
              >
            </q-item-section>
            <q-item-section side>
              <q-icon name="launch" />
            </q-item-section>
          </q-item>

          <q-item>
            <q-item-section avatar>
              <q-icon name="verified_user" />
            </q-item-section>
            <q-item-section>
              <q-item-label>DNSSEC</q-item-label>
              <q-item-label caption
                >Domain Name System Security Extensions</q-item-label
              >
            </q-item-section>
            <q-item-section side>
              <q-btn flat round color="primary" icon="help_outline">
                <q-tooltip> How DNSSEC works </q-tooltip>
                <q-menu anchor="bottom end" self="top end">
                  <q-list style="min-width: 120px">
                    <q-item
                      clickable
                      v-close-popup
                      tag="a"
                      href="https://www.cloudflare.com/learning/dns/dnssec/how-dnssec-works/"
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <q-item-section>English</q-item-section>
                    </q-item>
                    <q-item
                      clickable
                      v-close-popup
                      tag="a"
                      href="https://www.cloudflare.com/pt-br/learning/dns/dnssec/how-dnssec-works/"
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <q-item-section>Português</q-item-section>
                    </q-item>
                  </q-list>
                </q-menu>
              </q-btn>
            </q-item-section>
          </q-item>
        </q-list>
      </q-card>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n';
import { computed } from 'vue';

const { t, locale } = useI18n();

const dnsDocLink = computed(() => {
  if (locale.value === 'pt-BR') {
    return 'https://www.cloudflare.com/pt-br/learning/dns/dns-security/';
  }
  return 'https://www.cloudflare.com/learning/dns/dns-security/';
});
</script>