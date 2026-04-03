<div align="center">
   <h1>ZapHalo</h1>
   <p><strong>Open Source WhatsApp API Integration and Business Solutions</strong></p>
</div>
</div>

**ZapHalo** is a powerful WhatsApp API-integrated application designed for businesses and individuals to streamline messaging workflows. With a single phone number, users can integrate ZapHalo across multiple platforms (e.g., websites, apps), receive and manage messages via WhatsApp webhooks, leverage chatbot automation, and send bulk messages to millions of recipients efficiently. Inspired by platforms like Wati.io, ZapHalo offers an end-to-end solution for multi-channel messaging and customer engagement.

<div align="center">
   <img src="./packages/frontend/public/dashboardScreenShot.png" alt="ZapHalo — WhatsApp API Integration" width="900" />
   <p><em>Screenshot: ZapHalo dashboard</em></p>
</div>

## Features
- **Multi-Platform Integration**: Embed your WhatsApp number on websites, apps, or other platforms with a simple link or widget.
- **Webhook Message Handling**: Capture incoming WhatsApp messages in real-time using webhooks and display them within the app.
- **Chatbot Functionality**: Automate responses with a no-code chatbot builder for FAQs, customer support, and lead generation.
- **Bulk Messaging**: Send personalized messages to millions of contacts from a single number, perfect for marketing campaigns or notifications.
- **Real-Time Messaging**: Leverage WebSocket (Socket.IO) for instant two-way communication.
- **Authentication**: Secure access with JWT-based authentication via GraphQL Auth Guard.
- **Persistent Storage**: Store messages and chat data in PostgreSQL and local storage for seamless session management.
- **Scalable Communication**: Handle large-scale messaging without compromising performance.

## Tech Stack
- **Backend**: NestJS, TypeORM, PostgreSQL, Socket.IO
- **Frontend**: React, Apollo Client, Socket.IO Client
- **WhatsApp Integration**: WhatsApp Business API, Webhooks
- **Authentication**: JWT, GqlAuthGuard
- **Storage**: LocalStorage (client-side), PostgreSQL (server-side)

## Prerequisites
Before installing, ensure you have the following installed:
- **Node.js**: v24.x or higher
- **Yarn**: v4.x (Enabled via Corepack)
- **PostgreSQL**: v15.x or higher
- **Git**: For cloning the repository
- **WhatsApp Business API Account**: Approved account from Meta or a WhatsApp Business Solution Provider (BSP)

---

## Installation Process

### 1. Clone the Repository
```bash
git clone https://github.com/hserr4/zaphalo.git
cd zaphalo
```

### 2. Set Up Environment Variables
Create `.env` files in both the backend and frontend directories.

#### Backend (e.g., `packages/server/.env`)
```bash
cp packages/server/.env.example packages/server/.env
```

#### Frontend (e.g., `packages/frontend/.env`)
```bash
cp packages/frontend/.env.example packages/frontend/.env
```

### 3. Install Dependencies
This project uses **Yarn Modern (v4)**. Enable it via Corepack:
```bash
corepack enable
yarn install
```

### 4. Set Up the Database
1. **Run Migrations**:
   - In a new terminal:
   ```bash
   yarn nx run server:build
   yarn nx database:migrate:run server
   ```

### 5. Start the Backend
```bash
yarn nx start server
```
- The server will run on `http://localhost:3000` (GraphQL at `/graphql`, Webhook at `/webhook`).

### 6. Start the Frontend
```bash
yarn nx start frontend
```
- The React app will run on `http://localhost:5173`.

---

## Docker & Coolify Deployment

This project is optimized for deployment on **Coolify/OCI**.

### Quick Deploy
1. Point your domain (e.g., `api.avynt.com.br`) to your server IP.
2. Link your GitHub repository in the Coolify dashboard.
3. The included `Dockerfile` will automatically:
   - Configure Node 24 and Yarn 4.5.1.
   - Run NX builds for both server and frontend.
   - Set up the database migrations on startup.

---

## Usage
1. **Integrate WhatsApp Number**:
   - Share your WhatsApp number (e.g., via a link like `https://wa.me/your_whatsapp_number`) on websites or apps.
2. **Receive Messages**:
   - Incoming messages are captured via the webhook and displayed in the ZapHalo app.
3. **Bulk Messaging**:
   - Upload a CSV of phone numbers and send a single message to millions of recipients.
4. **Real-Time Interaction**:
   - Use the app to reply to messages instantly via WebSocket.

---