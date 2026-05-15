import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'

// Polyfill BigInt serialization in JSON (essential for Wagmi/Viem states with large numbers)
if (typeof BigInt !== 'undefined' && !BigInt.prototype.toJSON) {
  BigInt.prototype.toJSON = function () {
    return this.toString();
  };
}

import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
