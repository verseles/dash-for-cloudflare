import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', redirect: '/dns/records' },
      {
        path: 'dns',
        component: () => import('pages/DnsPage.vue'),
        children: [
          { path: '', redirect: 'records' },
          {
            path: 'records',
            component: () => import('pages/dns/DnsRecordsPage.vue'),
          },
          {
            path: 'analytics',
            component: () => import('pages/dns/DnsAnalyticsPage.vue'),
          },
          {
            path: 'settings',
            component: () => import('pages/dns/DnsSettingsPage.vue'),
          },
        ],
      },
      {
        path: 'settings',
        component: () => import('pages/SettingsPage.vue'),
      },
    ],
  },
];

export default routes;
