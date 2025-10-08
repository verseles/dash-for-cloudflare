<template>
  <q-page padding>
    <div class="q-mx-auto" style="max-width: 1024px">
      <!-- Header Section -->
      <div class="q-mb-lg">
        <div class="text-overline text-grey-8">DNS</div>
        <div class="text-h4 q-mt-xs q-mb-sm">Settings</div>
        <div class="row items-center">
          <span class="text-body1 text-grey-8 q-mr-sm"> Manage DNS-specific settings for your domain. </span>
          <a href="#" class="text-primary row items-center no-wrap" style="text-decoration: none; font-weight: 500">
            <span>DNS documentation</span>
            <q-icon name="open_in_new" size="xs" class="q-ml-xs" />
          </a>
        </div>
      </div>

      <!-- DNSSEC Card -->
      <q-card flat bordered class="q-mb-md">
        <q-card-section class="row items-start justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">DNSSEC</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              DNSSEC uses a cryptographic signature of published DNS records to protect your domain against forged DNS
              answers.
            </p>
            <div
              class="row items-center text-caption q-mt-sm q-pa-sm rounded-borders"
              :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-grey-2'"
            >
              <q-icon name="info_outline" class="q-mr-xs" :color="$q.dark.isActive ? 'grey-5' : 'grey-7'" />
              <span :class="$q.dark.isActive ? 'text-grey-5' : 'text-grey-7'">
                DNSSEC is pending while we wait for the DS to be added to your registrar. This usually takes ten
                minutes, but can take up to an hour.
              </span>
            </div>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right q-mt-sm q-mt-md-none">
            <q-btn flat color="primary" label="Cancel Setup" />
          </div>
        </q-card-section>
        <q-separator />
        <q-card-actions align="left" class="q-pa-md">
          <q-btn flat dense no-caps color="primary" label="DS Record" icon-right="arrow_forward" />
          <q-btn flat dense no-caps color="primary" label="Help" icon-right="open_in_new" class="q-ml-md" />
        </q-card-actions>
      </q-card>

      <!-- Multi-signer DNSSEC -->
      <q-card flat bordered class="q-mb-md">
        <q-card-section class="row items-center justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">Multi-signer DNSSEC</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              Multi-signer DNSSEC allows Cloudflare and your other authoritative DNS providers to serve the same zone
              and have DNSSEC enabled at the same time.
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right">
            <q-toggle v-model="multiSignerDnssec" />
          </div>
        </q-card-section>
        <q-separator />
        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat dense no-caps color="primary" label="Help" icon-right="open_in_new" />
        </q-card-actions>
      </q-card>

      <!-- Multi-provider DNS -->
      <q-card flat bordered class="q-mb-md">
        <q-card-section class="row items-center justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">Multi-provider DNS</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              Multi-provider DNS allows domains using a
              <a href="#" class="text-primary" style="text-decoration: none">full DNS setup</a>
              to be active on Cloudflare while using another authoritative DNS provider in addition to Cloudflare. Also
              allows the domain to serve any apex NS records added to its DNS configuration at Cloudflare.
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right">
            <q-toggle v-model="multiProviderDns" />
          </div>
        </q-card-section>
      </q-card>

      <!-- CNAME flattening for all CNAME records -->
      <q-card flat bordered class="q-mb-md">
        <q-card-section class="row items-center justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">CNAME flattening for all CNAME records</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              Speed up DNS resolution on CNAMEs by having Cloudflare return the IP address of the final destination in
              the CNAME chain. Enabling this setting allows you to flatten all CNAMEs within your zone, which is
              sicon.app. With this setting disabled, any CNAME at the apex is flattened by default and you may choose
              to individually flatten specific CNAMEs.
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right">
            <q-toggle v-model="cnameFlattening" />
          </div>
        </q-card-section>
      </q-card>

      <!-- Email Security -->
      <q-card flat bordered class="q-mb-md">
        <q-card-section class="row items-start justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">Email Security</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              Protect your domain from email spoofing and phishing by creating the required DNS records.
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right q-mt-sm q-mt-md-none">
            <q-btn color="primary" label="Configure" />
          </div>
        </q-card-section>
        <q-separator />
        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat dense no-caps color="primary" label="Help" icon-right="open_in_new" />
        </q-card-actions>
      </q-card>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const multiSignerDnssec = ref(false)
const multiProviderDns = ref(false)
const cnameFlattening = ref(false)
</script>

<style lang="scss" scoped>
.text-body2 a {
  text-decoration: none;
  font-weight: 500;
}
</style>