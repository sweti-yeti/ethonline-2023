import { getDefaultWallets } from '@rainbow-me/rainbowkit'
import { configureChains, createConfig } from 'wagmi'
import { scrollSepolia, mantleTestnet } from 'wagmi/chains'
import { publicProvider } from 'wagmi/providers/public'

const walletConnectProjectId = '62af047c822e5c8a5cd4b5aaed089477'

const { chains, publicClient, webSocketPublicClient } = configureChains(
  [scrollSepolia, mantleTestnet],
  [
    publicProvider(),
  ],
)

const { connectors } = getDefaultWallets({
  appName: 'Wavegear Demo',
  chains,
  projectId: walletConnectProjectId,
})

export const config = createConfig({
  autoConnect: true,
  connectors,
  publicClient,
  webSocketPublicClient,
})

export { chains }
