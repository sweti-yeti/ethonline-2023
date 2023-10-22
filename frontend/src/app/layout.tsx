import '@rainbow-me/rainbowkit/styles.css'
import { Providers } from './providers'
import './globals.css';

export const metadata = {
  title: 'wagmi',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <div className={'min-h-screen flex flex-col'}>
          <Providers>{children}</Providers>
        </div>
      </body>
    </html>
  )
}
