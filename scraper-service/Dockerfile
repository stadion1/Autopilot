# ── Bilanalys Scraper Service ─────────────────────────────────────────────────
# Kör på Railway. Installerar Chromium för Playwright.
# Node 20 på Debian Bookworm — stabil bas för Playwright.

FROM node:20-bookworm-slim

# Systemberoenden för Chromium
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    fonts-noto-color-emoji \
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
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Säg åt Playwright att använda systemets Chromium
# istället för att ladda ned en egen kopia
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/bin
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV CHROMIUM_PATH=/usr/bin/chromium

WORKDIR /app

# Kopiera package.json och installera beroenden
COPY package.json ./
RUN npm install

# Kopiera källkod
COPY *.ts ./
COPY tsconfig.json ./

# Kompilera TypeScript
RUN npx tsc
RUN npm prune --production

# Railway sätter PORT automatiskt
EXPOSE 3001

# Kör som icke-root för säkerhet
RUN groupadd -r scraper && useradd -r -g scraper scraper
USER scraper

CMD ["node", "dist/server.js"]
