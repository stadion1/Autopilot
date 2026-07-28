/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: 'images.blocketcdn.se' },
      { protocol: 'https', hostname: 'images.wayke.se' },
      { protocol: 'https', hostname: 'cdn.bytbil.com' },
    ],
  },
  // Increase API timeout for scraping
  experimental: {
    serverActions: { bodySizeLimit: '2mb' },
  },
}

module.exports = nextConfig
