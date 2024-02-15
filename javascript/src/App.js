
import GithubCorner from 'react-github-corner';
import { createTheme, ThemeProvider } from '@mui/material/styles';

import Mixer from "./containers/mixer";
import Footer from "./components/footer";
import constants from './constants';
import packageJson from '../package.json';
import "./App.css";
import { Credits } from './components/styled';

const theme = createTheme(constants.THEME);

const App = () => {
  return (
    <ThemeProvider theme={theme}>
      <div className="App">
        <main>
          <h1>Cross-platform application demonstration</h1>
          <Mixer />
          <small>v{packageJson.version}</small>
          <Footer />
          <Credits>
            <p><b>Music credits</b></p>
            <div><small>ＭＩＬＬＥＮＮＩＡＬＳ by cdk (c) copyright 2018 Licensed under a Creative Commons Attribution (3.0) license. <a href="https://dig.ccmixter.org/files/cdk/57150">https://dig.ccmixter.org/files/cdk/57150</a> </small></div>
            <div><small>I Have Often Told You Stories (guitar instrumental) by Ivan Chew (c) copyright 2013 Licensed under a Creative Commons Attribution (3.0) license. <a href="https://dig.ccmixter.org/files/ramblinglibrarian/41284">https://dig.ccmixter.org/files/ramblinglibrarian/41284</a></small></div>
          </Credits>
        </main>
        <GithubCorner href="https://github.com/splice/superpowered-universal-app" />
      </div>
    </ThemeProvider>
  );
};

export default App;
