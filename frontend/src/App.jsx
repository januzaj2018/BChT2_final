import { useState } from 'react';
import { BrowserProvider, Contract } from 'ethers';
import BoxABI from './Box.json';
import './index.css';

function App() {
  const [currentValue, setCurrentValue] = useState('...');
  const [newValue, setNewValue] = useState('');
  const [contractAddress, setContractAddress] = useState('');
  const [account, setAccount] = useState(null);
  const [status, setStatus] = useState({ type: '', message: '' });
  const [isLoading, setIsLoading] = useState(false);

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setAccount(accounts[0]);
        setStatus({ type: 'success', message: 'Wallet connected successfully!' });
      } catch (error) {
        console.error(error);
        setStatus({ type: 'error', message: 'Failed to connect wallet.' });
      }
    } else {
      setStatus({ type: 'error', message: 'Please install MetaMask or another Web3 wallet!' });
    }
  };

  const getContract = async () => {
    if (!window.ethereum) throw new Error("No crypto wallet found.");
    if (!contractAddress) throw new Error("Please enter contract address.");
    
    const provider = new BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    return new Contract(contractAddress, BoxABI, signer);
  };

  const retrieveValue = async () => {
    try {
      setIsLoading(true);
      setStatus({ type: '', message: 'Retrieving value...' });
      const contract = await getContract();
      const val = await contract.retrieve();
      setCurrentValue(val.toString());
      setStatus({ type: 'success', message: 'Value retrieved!' });
    } catch (err) {
      console.error(err);
      setStatus({ type: 'error', message: err.reason || err.message || 'Failed to retrieve value.' });
    } finally {
      setIsLoading(false);
    }
  };

  const storeValue = async (e) => {
    e.preventDefault();
    if (!newValue) return;
    
    try {
      setIsLoading(true);
      setStatus({ type: '', message: 'Confirm transaction in wallet...' });
      const contract = await getContract();
      const tx = await contract.store(newValue);
      setStatus({ type: '', message: 'Transaction pending...' });
      await tx.wait();
      setCurrentValue(newValue);
      setNewValue('');
      setStatus({ type: 'success', message: 'Value stored successfully!' });
    } catch (err) {
      console.error(err);
      setStatus({ type: 'error', message: err.reason || err.message || 'Failed to store value.' });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="app-container">
      <div className="card">
        <div className="header">
          <h1>Box Contract</h1>
          <p>Store and retrieve values on the blockchain</p>
        </div>

        {!account ? (
          <button className="btn" onClick={connectWallet}>
            Connect Wallet
          </button>
        ) : (
          <>
            <div className="value-display">
              <div className="label">Current Value</div>
              <div className="value">{currentValue}</div>
            </div>

            <div className="input-group">
              <input 
                type="text" 
                className="input-field" 
                placeholder="Contract Address (0x...)" 
                value={contractAddress}
                onChange={(e) => setContractAddress(e.target.value)}
              />
            </div>

            <div style={{ display: 'flex', gap: '12px' }}>
              <button 
                className="btn btn-secondary" 
                onClick={retrieveValue}
                disabled={isLoading || !contractAddress}
              >
                {isLoading ? 'Loading...' : 'Refresh'}
              </button>
            </div>

            <form onSubmit={storeValue} className="input-group" style={{ marginTop: '12px' }}>
              <input 
                type="number" 
                className="input-field" 
                placeholder="New Value to Store" 
                value={newValue}
                onChange={(e) => setNewValue(e.target.value)}
              />
              <button 
                type="submit" 
                className="btn" 
                disabled={isLoading || !newValue || !contractAddress}
              >
                {isLoading ? 'Processing...' : 'Store Value'}
              </button>
            </form>

            {status.message && (
              <div className={`status-message status-${status.type}`}>
                {status.message}
              </div>
            )}

            <div style={{ textAlign: 'center' }}>
              <span className="address-badge">
                Connected: {account.substring(0, 6)}...{account.substring(account.length - 4)}
              </span>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

export default App;
