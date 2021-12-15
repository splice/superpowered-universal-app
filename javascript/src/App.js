import { useState } from "react";
import GithubCorner from 'react-github-corner';
import Mixer from "./containers/mixer.js";
import Text from "./components/text.js";
import packageJson from '../package.json';
import "./App.css";


const App = () => {
  return (
    <div className="App">
      <main>
        <h1>Cross-platform application demonstration</h1>
        <Mixer />
        <Text />
        <small>v{packageJson.version}</small>
      </main>
      <GithubCorner href="https://github.com/splice/superpowered-universal-app" />
    </div>
  );
};

export default App;
