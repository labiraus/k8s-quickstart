import logo from './logo.svg';
import './App.css';
import {useState} from 'react';

function App() {
  const [output, setOutput] = useState()
  const hello = async () => {
    console.log("calling hello");
    const res = await fetch('/hello');
    console.log(res);
    setOutput(res.data);
  }
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
      <button onClick={hello}>click me</button>
      <p>{output}</p>
      </header>
    </div>
  );
}

export default App;
