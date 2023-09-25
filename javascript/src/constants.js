// If building and running locally, you'll need to remove '/superpowered-universal-app' from the paths below

const constants = {
    SP_LICENSE_KEY: "ExampleLicenseKey-WillExpire-OnNextUpdate",
    ABSOLUTE_LIBRARY_URL: `${window.location.origin}/superpowered-universal-app/lib/Superpowered.js`,
    ABSOLUTE_PROCESSOR_URL: `${window.location.origin}/superpowered-universal-app/processorScripts/mixerProcessorScript.js`,
    RELATIVE_BACKGROUND_URL: 'images/wave.png',
    THEME: {
        palette: {
            primary: {
                main: '#1253FF',
            }
      }
    }
};

export default constants
