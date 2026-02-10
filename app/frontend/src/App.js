import { useEffect, useState } from 'react';

function App() {
  const [counter, setCounter] = useState(0);

  const loadCounter = async () => {
    const res = await fetch('/api/counter');
    const data = await res.json();
    setCounter(data.counter);
  };

  const increment = async () => {
    const res = await fetch('/api/counter/increment', {
      method: 'POST',
    });
    const data = await res.json();
    setCounter(data.counter);
  };

  useEffect(() => {
    loadCounter();
  }, []);

  return (
    <div style={{ padding: '40px', fontFamily: 'Arial' }}>
      <h1>Microservices Demo</h1>
      <p>Counter value: {counter}</p>
      <button onClick={increment}>Increment</button>
    </div>
  );
}

export default App;
