import { useState } from 'react';
import { 
  useAccount, 
  useConnect, 
  useDisconnect, 
  useBalance, 
  useWriteContract, 
  useWaitForTransactionReceipt,
  WagmiProvider,
  createConfig,
  http
} from 'wagmi';
import { arbitrumSepolia } from 'wagmi/chains';
import { injected } from 'wagmi/connectors';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { parseEther, formatEther } from 'viem';
import { 
  Wallet, 
  ArrowRightLeft, 
  ShieldCheck, 
  Vote, 
  Coins, 
  RefreshCcw,
  LayoutDashboard,
  ExternalLink
} from 'lucide-react';

import GameAMMABI from './constants/GameAMM.json';
import RentalVaultABI from './constants/RentalVault.json';

import './index.css';

// --- CONFIGURATION ---

const queryClient = new QueryClient();

const config = createConfig({
  chains: [arbitrumSepolia],
  connectors: [injected()],
  transports: {
    [arbitrumSepolia.id]: http(),
  },
});

// Placeholders for Arbitrum Sepolia addresses
const CONTRACTS = {
  GameToken: "0x0000000000000000000000000000000000000000",
  GameAMM: "0x0000000000000000000000000000000000000000",
  RentalVault: "0x0000000000000000000000000000000000000000",
  GameGovernor: "0x0000000000000000000000000000000000000000",
  GameItem: "0x0000000000000000000000000000000000000000",
};

// --- COMPONENTS ---

function ConnectWallet() {
  const { address, isConnected } = useAccount();
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();

  if (isConnected) {
    return (
      <div className="wallet-info">
        <span className="address-chip">
          <Wallet size={14} />
          {address?.slice(0, 6)}...{address?.slice(-4)}
        </span>
        <button onClick={() => disconnect()} className="btn btn-sm btn-outline">
          Disconnect
        </button>
      </div>
    );
  }

  return (
    <div className="wallet-actions">
      {connectors.map((connector) => (
        <button
          key={connector.uid}
          onClick={() => connect({ connector })}
          className="btn btn-primary btn-sm"
        >
          Connect Wallet
        </button>
      ))}
    </div>
  );
}

function SwapTab() {
  const [amountIn, setAmountIn] = useState('');
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const handleSwap = () => {
    if (!amountIn) return;
    writeContract({
      address: CONTRACTS.GameAMM,
      abi: GameAMMABI,
      functionName: 'swap',
      args: [CONTRACTS.GameToken, parseEther(amountIn), 0],
    });
  };

  return (
    <div className="card tab-content">
      <h2><ArrowRightLeft className="icon" /> AMM Swap</h2>
      <p className="subtitle">Swap your Game Tokens for resources</p>
      
      <div className="input-group">
        <label>You Pay</label>
        <div className="input-with-symbol">
          <input 
            type="number" 
            placeholder="0.0" 
            value={amountIn}
            onChange={(e) => setAmountIn(e.target.value)}
          />
          <span className="symbol">GAME</span>
        </div>
      </div>

      <div className="swap-divider">
        <RefreshCcw size={16} />
      </div>

      <div className="input-group">
        <label>You Receive (Estimated)</label>
        <div className="input-with-symbol disabled">
          <input type="text" value="0.0" readOnly />
          <span className="symbol">WOOD</span>
        </div>
      </div>

      <button 
        className="btn btn-primary btn-lg full-width" 
        onClick={handleSwap}
        disabled={isPending || isConfirming || !amountIn}
      >
        {isPending || isConfirming ? 'Processing...' : 'Swap Tokens'}
      </button>

      {isSuccess && <div className="status-success">Swap successful!</div>}
    </div>
  );
}

function VaultTab() {
  const { address } = useAccount();
  const [amount, setAmount] = useState('');
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const handleDeposit = () => {
    if (!amount || !address) return;
    writeContract({
      address: CONTRACTS.RentalVault,
      abi: RentalVaultABI,
      functionName: 'deposit',
      args: [parseEther(amount), address],
    });
  };

  return (
    <div className="card tab-content">
      <h2><ShieldCheck className="icon" /> Rental Vault</h2>
      <p className="subtitle">Stake your tokens to earn yield & items</p>
      
      <div className="stats-grid">
        <div className="stat-card">
          <label>APY</label>
          <div className="stat-value text-success">10.0%</div>
        </div>
        <div className="stat-card">
          <label>TVL</label>
          <div className="stat-value">1,240 GAME</div>
        </div>
      </div>

      <div className="input-group">
        <label>Amount to Stake</label>
        <input 
          type="number" 
          placeholder="0.0" 
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
        />
      </div>

      <button 
        className="btn btn-success btn-lg full-width" 
        onClick={handleDeposit}
        disabled={isPending || isConfirming || !amount}
      >
        {isPending || isConfirming ? 'Staking...' : 'Stake Tokens'}
      </button>
      
      {isSuccess && <div className="status-success">Staking successful!</div>}
    </div>
  );
}

function GovernanceTab() {
  return (
    <div className="card tab-content">
      <h2><Vote className="icon" /> DAO Governance</h2>
      <p className="subtitle">Vote on protocol parameters and items</p>
      
      <div className="proposal-list">
        <div className="proposal-item">
          <div className="proposal-info">
            <span className="badge badge-active">Active</span>
            <h3>Update Crafting Costs</h3>
            <p>Reduce sword crafting cost by 15%</p>
          </div>
          <div className="proposal-actions">
            <button className="btn btn-sm">Vote For</button>
            <button className="btn btn-sm btn-outline">Against</button>
          </div>
        </div>

        <div className="proposal-item">
          <div className="proposal-info">
            <span className="badge badge-queued">Queued</span>
            <h3>Add New Item: Mithril Plate</h3>
            <p>Introduce Tier 4 armor recipes</p>
          </div>
          <div className="proposal-actions">
            <button className="btn btn-sm" disabled>Voting Ended</button>
          </div>
        </div>
      </div>
    </div>
  );
}

function Dashboard() {
  const { address } = useAccount();
  const { data: gameBalance } = useBalance({
    address,
    token: CONTRACTS.GameToken !== "0x0000000000000000000000000000000000000000" ? CONTRACTS.GameToken : undefined,
  });

  return (
    <div className="dashboard">
      <div className="stats-row">
        <div className="card stat-card-main">
          <div className="stat-label"><Coins size={16} /> My GAME Balance</div>
          <div className="stat-valueLarge">{gameBalance ? parseFloat(formatEther(gameBalance.value)).toFixed(2) : "0.00"}</div>
        </div>
        <div className="card stat-card-main">
          <div className="stat-label"><LayoutDashboard size={16} /> NFTs Owned</div>
          <div className="stat-valueLarge">12</div>
        </div>
      </div>
    </div>
  );
}

function AppContent() {
  const [activeTab, setActiveTab] = useState('swap');
  const { isConnected } = useAccount();

  if (!isConnected) {
    return (
      <div className="welcome-screen">
        <div className="hero-card">
          <h1>GameFi Protocol</h1>
          <p>The economy of the future of gaming. Trade, Stake, and Govern.</p>
          <ConnectWallet />
        </div>
      </div>
    );
  }

  return (
    <div className="app-layout">
      <header className="navbar">
        <div className="logo">
          <ShieldCheck color="#6366f1" size={32} fill="#6366f122" />
          <span>GameFi Protocol</span>
        </div>
        <ConnectWallet />
      </header>

      <main className="container">
        <Dashboard />

        <div className="tabs-nav">
          <button 
            className={`tab-btn ${activeTab === 'swap' ? 'active' : ''}`}
            onClick={() => setActiveTab('swap')}
          >
            <ArrowRightLeft size={18} /> Swap
          </button>
          <button 
            className={`tab-btn ${activeTab === 'vault' ? 'active' : ''}`}
            onClick={() => setActiveTab('vault')}
          >
            <ShieldCheck size={18} /> Vault
          </button>
          <button 
            className={`tab-btn ${activeTab === 'gov' ? 'active' : ''}`}
            onClick={() => setActiveTab('gov')}
          >
            <Vote size={18} /> Governance
          </button>
        </div>

        <div className="tab-container">
          {activeTab === 'swap' && <SwapTab />}
          {activeTab === 'vault' && <VaultTab />}
          {activeTab === 'gov' && <GovernanceTab />}
        </div>
      </main>

      <footer className="footer">
        <p>Built with ❤️ for Arbitrum Sepolia Capstone</p>
        <a href="#" className="footer-link">
          Arbiscan <ExternalLink size={12} />
        </a>
      </footer>
    </div>
  );
}

export default function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <AppContent />
      </QueryClientProvider>
    </WagmiProvider>
  );
}
