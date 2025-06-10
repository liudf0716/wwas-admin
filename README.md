# WWAS Admin

WWAS Admin (`wwas-admin`) is a web-based administration interface for the WWAS (Wireless Web Authentication System) platform. WWAS is a captive portal and authentication service designed to work with [apfree-wifidog](https://github.com/liudf0716/apfree-wifidog) and similar Wi-Fi dog / captive portal solutions.

This project provides the frontend for configuring and managing the WWAS backend. It allows administrators to manage users, devices, authentication methods, and customize the portal page. `wwas-admin` is built using the Vue.js framework.

## Table of Contents

- [Key Features](#key-features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Development Setup](#development-setup)
  - [Deployment](#deployment)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)
- [Final Notes](#final-notes)

## Key Features

*   **User Management:** Manage user accounts, including adding new users and freezing existing ones. Supports importing and exporting user device information.
*   **Device Management:** View and manage lists of user-associated devices and their details.
*   **Authentication Monitoring:** Track and view details of users who have authenticated through the platform.
*   **Flexible Authentication Methods:**
    *   Configure WeChat authentication.
    *   Set up SMS-based authentication (supports Aliyun and Netease SMS services).
    *   Enable one-click authentication for quick access.
    *   Support for traditional username/password authentication.
*   **Customizable Portal Page:** Customize the appearance and content of the captive portal page presented to users.

## Getting Started

### Prerequisites

*   **Node.js:** It's recommended to use the latest LTS (Long Term Support) version. You can download it from [nodejs.org](https://nodejs.org/).
*   **npm:** npm (Node Package Manager) is included with Node.js.

### Development Setup

Follow these steps to set up `wwas-admin` for development purposes:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/liudf0716/wwas-admin.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd wwas-admin
    ```
3.  **Install dependencies:**
    ```bash
    npm install
    ```
    This command installs all the necessary project dependencies defined in **`package.json`**.
4.  **Start the development server:**
    ```bash
    npm run dev
    ```
    This will start a local development server, usually accessible at `http://localhost:8080` (the port might vary, check your console output). The application will automatically reload if you change any of the source files.

### Deployment

To deploy `wwas-admin` for use with a `wwas` backend, follow these instructions. These steps assume you are deploying the `wwas-admin` frontend to be served by the `wwas` backend.

1.  **Clone the repository (if not already done):**
    ```bash
    git clone https://github.com/liudf0716/wwas-admin.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd wwas-admin
    ```
3.  **Install dependencies (if not already done):**
    ```bash
    npm install
    ```
4.  **Configure the backend API server address:**
    Open the **`config/index.js`** file. Locate the `build` object, and within it, modify the `webServer` property to point to your `wwas` backend API.
    For example:
    ```javascript
    // Inside config/index.js
    module.exports = {
        build: {
            // ... other build configurations
            webServer: 'http://yourip:8001', // Replace yourip:8001 with your actual WWAS backend URL
            // ... other build configurations
        },
        // ... dev configurations
    };
    ```
    This URL will be used by the application when it's built for production.

5.  **Build the project:**
    ```bash
    npm run build
    ```
    This command compiles and minifies the project assets into a **`dist`** folder in the project root.
6.  **Deploy to WWAS backend:**
    Copy the *contents* of the generated **`dist`** folder into the `public` directory of your `wwas` backend project.
    ```bash
    # Example: if wwas project is a sibling directory
    cp -r dist/* ../wwas/public/
    # Adjust the path according to your wwas project location.
    ```
    The `wwas` backend should then serve the `wwas-admin` interface.

## Screenshots

### Login Page
![Login Page for wwas-admin](https://github.com/liudf0716/wwas-admin/assets/1182593/43f2cc31-481b-4ee6-a1f9-26702aec7b2f)
*The main login interface for wwas-admin.*

### Device Management
![Device Management Interface](https://github.com/liudf0716/wwas-admin/blob/master/device.png?raw=true)
*View and manage connected devices.*

### Import Routers
![Dialog for importing router configurations](https://github.com/liudf0716/wwas-admin/assets/1182593/29fe9f7b-295f-4331-afa7-e2818ec1db41)
*Dialog for importing router configurations.*

![Further details for router import](https://github.com/liudf0716/wwas-admin/assets/1182593/1713bc42-2342-4b9b-84d5-51706f9a957c)
*Further details for router import.*

### WeChat Authentication Configuration
![Settings page for WeChat authentication](https://github.com/liudf0716/wwas-admin/assets/1182593/5270faa1-03d6-47f9-9fba-8acaf169e3a1)
*Settings page for WeChat authentication.*

### SMS Authentication Configuration
![Settings page for SMS-based authentication](https://github.com/liudf0716/wwas-admin/assets/1182593/ecf7c160-9b48-4425-aa9f-48726575a283)
*Settings page for SMS-based authentication.*

### One-Click Free Authentication Configuration
![Configuration for one-click free authentication](https://github.com/liudf0716/wwas-admin/assets/1182593/b6542bc9-ae79-4a2c-897f-1a34df71549c)
*Configuration for enabling one-click 免认证 (free authentication).*

### User Password Authentication Configuration
![Settings for username/password based authentication](https://github.com/liudf0716/wwas-admin/assets/1182593/2653fc32-04a2-4e84-a68f-4ce7026ff503)
*Settings for username/password based authentication.*

### Other Authentication Configurations
![Additional authentication related settings](https://github.com/liudf0716/wwas-admin/assets/1182593/c705997a-7064-4102-8c84-d882e397177d)
*Additional authentication related settings.*

## Contributing

Contributions are welcome and greatly appreciated! If you have suggestions for improving `wwas-admin`, please feel free to contribute.

Here are a few ways you can help:

*   **Report Bugs:** If you find a bug, please open an issue on the [GitHub Issues page](https://github.com/liudf0716/wwas-admin/issues). Describe the bug in detail, including steps to reproduce it.
*   **Suggest Enhancements:** If you have ideas for new features or improvements to existing ones, you can also open an issue to discuss your ideas.
*   **Submit Pull Requests:** For bug fixes or feature implementations:
    1.  Fork the repository.
    2.  Create a new branch for your changes (e.g., `git checkout -b feature/your-feature-name` or `bugfix/issue-number`).
    3.  Make your changes and commit them with clear, descriptive messages.
    4.  Push your changes to your forked repository.
    5.  Open a pull request to the main `wwas-admin` repository. Please provide a clear description of the changes in your PR.

When contributing code, please try to follow the existing code style. For major changes, it's always a good idea to open an issue first to discuss your proposed changes.

Thank you for your interest in improving `wwas-admin`!

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for full license text.

## Final Notes

*   If you find this project helpful, please consider giving it a ⭐ **Star** on GitHub!
*   If you encounter any issues or have suggestions, please open an issue via [GitHub Issues](https://github.com/liudf0716/wwas-admin/issues/new).
*   If you've found a bug and have a solution, or want to contribute enhancements, pull requests are welcome!
*   Project discussion groups (QQ): `331230369`, `424031785`.
