import { useState } from 'react';
import './App.css';

function App() {
  const [count, setCount] = useState(0);

  return (
    <div className="App">
      <header className="App-header">
        <h1>ChuZone - DevOps POC</h1>
        <p>Version 1.0.0</p>
        <div className="counter">
          <button onClick={() => setCount(count - 1)}>-</button>
          <span data-testid="counter-value">{count}</span>
          <button onClick={() => setCount(count + 1)}>+</button>
        </div>
        <p className="info">Application déployée via CI/CD avec Kubernetes et Argo CD</p>
      </header>
    </div>
  );
}

export default App;
