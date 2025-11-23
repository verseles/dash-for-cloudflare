# Dash for Cloudflare

<p align="center">
  <img src="screenshots/1.png" width="260" alt="Screenshot 1">
  <img src="screenshots/2.png" width="260" alt="Screenshot 2">
  <img src="screenshots/3.png" width="260" alt="Screenshot 3">
</p>

<p align="center">
  <strong>A native dashboard for Cloudflare</strong>
</p>

<p align="center">
  <a href="https://github.com/verseles/dash-for-cloudflare/issues">
    <img src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square" alt="Contributions Welcome">
  </a>
  <img src="https://img.shields.io/badge/Quasar-v2-blue.svg?style=flat-square" alt="Quasar 2">
  <img src="https://img.shields.io/badge/Vue-v3-brightgreen.svg?style=flat-square" alt="Vue 3">
  <img src="https://img.shields.io/badge/TypeScript-v5-brightgreen.svg?style=flat-square" alt="TypeScript 5">
  <img src="https://img.shields.io/badge/Node.js-v24-brightgreen.svg?style=flat-square" alt="Node.js 24">
</p>

**Dash for Cloudflare** provides a clean, fast, and mobile-first interface for managing your Cloudflare account. Built as a Progressive Web App (PWA), it offers a native-like experience on any device, allowing you to manage your DNS settings on the go.

---

## ✨ Features

- **Complete DNS Management:** Full support for creating, reading, updating, and deleting DNS records.
- **Client-Side Security:** Your Cloudflare API token is stored exclusively on your device's local storage, never leaving your browser.
- **Multi-language Support:** Available in English and Portuguese, with the ability to switch languages on the fly.
- **Progressive Web App (PWA):** Installable on any device (desktop or mobile) for a native-like experience, including offline access capabilities.
- **Responsive Design:** A clean and intuitive interface that adapts to any screen size.
- **Light & Dark Mode:** Automatically adapts to your system's theme, or you can set it manually.
- **DNS Analytics:** Visualize DNS query data with interactive charts and maps.

## ⚠️ Disclaimer

Cloudflare and the Cloudflare logo are trademarks of Cloudflare, Inc. This project is an independent effort and is not affiliated with, endorsed by, or in any way officially connected with Cloudflare, Inc.

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- Node.js (version 24.x or newer recommended) and npm

### Installation & Development

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/verseles/dash-for-cloudflare.git
    cd dash-for-cloudflare
    ```

2.  **Install dependencies:**

    ```bash
    npm install
    ```

3.  **Start the development server:**
    The app will be available at `https://localhost:9000`.
    ```bash
    quasar dev
    ```

## 🛠️ Available Scripts

In the project directory, you can run:

- `quasar dev` or `npm run dev`
  Starts the app in development mode with hot-code reloading.

- `npm run lint`
  Lints and fixes files based on the ESLint configuration.

- `npm run format`
  Formats all project files using Prettier.

- `quasar build` or `npm run build`
  Builds the app for production.

- `quasar build -m pwa` or `npm run build-pwa`
  Builds the app as a Progressive Web App.

## 🧪 Testing

This project has a comprehensive testing setup with **Vitest** for unit/component tests and **Playwright** for E2E tests.

### Quick Commands

- `npm test` - Run unit tests once
- `npm run test:watch` - Run unit tests in watch mode
- `npm run test:unit:coverage` - Run tests with coverage report
- `npm run test:e2e` - Run E2E tests (all browsers)
- `npm run test:e2e:chromium` - Run E2E tests (Chromium only)

### Test Structure

```
├── src/**/__tests__/     # Unit tests (co-located with source)
├── e2e/                  # E2E tests with Playwright
│   ├── *.spec.ts         # Test files
│   └── page-objects/     # Page Object Models
└── test/vitest/          # Additional Vitest tests
```

For detailed testing documentation, see [TESTING.md](./TESTING.md).

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a feature to add or a bug to fix, please feel free to open a Pull Request.

## 💻 Tech Stack

- **Framework:** [Quasar Framework](https://quasar.dev)
- **UI Library:** [Vue 3](https://vuejs.org/) (with Composition API)
- **State Management:** [Pinia](https://pinia.vuejs.org/)
- **Language:** [TypeScript](https://www.typescriptlang.org/)
- **Charting:** [ECharts](https://echarts.apache.org/)
- **Build Tool:** [Vite](https://vitejs.dev/)
