import { defineRouter } from '#q-app/wrappers';
import {
  createMemoryHistory,
  createRouter,
  createWebHashHistory,
  createWebHistory,
} from 'vue-router';
import routes from './routes';
import { LocalStorage, Notify } from 'quasar';

/*
 * If not building with SSR mode, you can
 * directly export the Router instantiation;
 *
 * The function below can be async too; either use
 * async/await or return a Promise which resolves
 * with the Router instance.
 */

export default defineRouter(function (/* { store, ssrContext } */) {
  const createHistory = process.env.SERVER
    ? createMemoryHistory
    : process.env.VUE_ROUTER_MODE === 'history'
      ? createWebHistory
      : createWebHashHistory;

  const Router = createRouter({
    scrollBehavior: () => ({ left: 0, top: 0 }),
    routes,

    // Leave this as is and make changes in quasar.conf.js instead!
    // quasar.conf.js -> build -> vueRouterMode
    // quasar.conf.js -> build -> publicPath
    history: createHistory(process.env.VUE_ROUTER_BASE),
  });

  // Navigation guard to check for API token
  Router.beforeEach((to, from, next) => {
    // Check if navigating to a DNS page
    if (to.path.startsWith('/dns')) {
      const settings = LocalStorage.getItem<{
        cloudflareApiToken?: string;
      }>('dash_settings');
      const hasApiToken = settings?.cloudflareApiToken && settings.cloudflareApiToken.length >= 40;

      if (!hasApiToken) {
        // Using a hardcoded message because i18n is not easily available here
        Notify.create({
          message: 'An API token is required to access the DNS section.',
          color: 'negative',
          position: 'top',
        });
        // Redirect to settings page if no token
        next('/settings');
        return;
      }
    }

    // Continue with navigation
    next();
  });

  return Router;
});
