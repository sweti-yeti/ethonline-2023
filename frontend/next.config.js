/** @type {import('next').NextConfig} */
module.exports = {
  reactStrictMode: true,
  async headers() {
    return [
        {
            source: '/:path*',
            headers: [
                {
                    key: "Cross-Origin-Opener-Policy",
                    value: "same-origin"
                },
                {
                    key: "Cross-Origin-Embedder-Policy",
                    value: "credentialless"
                },
            ]

        }
    ]
  },
  webpack: (config) => {
    config.resolve.fallback = { fs: false, net: false, tls: false }
    return config
  },
}
