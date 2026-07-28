# ── Bilanalys Scraper Service ─────────────────────────────────────────────────
FROM node:20-bookworm-slim

RUN apt-get update && apt-get install -y \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    wget \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json ./
RUN npm install

RUN npx playwright install --with-deps chromium

COPY *.ts ./
COPY tsconfig.json ./
RUN npx tsc
RUN npm prune --production

EXPOSE 3001
CMD ["node", "dist/server.js"]


