
import GithubCorner from 'react-github-corner';
import { createTheme, ThemeProvider } from '@mui/material/styles';

import Mixer from "./containers/mixer";
import Footer from "./components/footer";
import constants from './constants';
import packageJson from '../package.json';
import "./App.css";

const theme = createTheme(constants.THEME);

const App = () => {
  return (
    <ThemeProvider theme={theme}>
      <div className="App">
        <main>
          <h1>Cross-platform application demonstration</h1>
          <Mixer />
          <Footer />
          <small>v{packageJson.version}</small>
        </main>
        <GithubCorner href="https://github.com/splice/superpowered-universal-app" />
      </div>
    </ThemeProvider>
  );
};

export default App;
