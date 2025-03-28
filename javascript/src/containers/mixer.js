import React, { useState, useEffect, useRef } from "react";
import AudioEngine from "../AudioEngine";
import Channel from "./channel";
import Crossfader from "../components/crossfader";
import Slider from "../components/slider.js";
import MainMeter from "../components/mainMeter.js";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import constants from '../constants';
import { ChannelBank, Logo, MixerContainer } from "../components/styled";

const aPeaks = {
  stereo: 0,
};
const bPeaks = {
  stereo: 0,
};
const masterPeaks = {
  stereo: 0,
};

const INITIAL_TEMPO = 105;

const Mixer = () => {
  const processorNode = useRef();
  const [assetsLoaded, setAssetsLoaded] = useState(false);
  const [playing, setPlaying] = useState(false);

  useEffect(() => {
    loadSP();
  }, []);

  const loadSP = async () => {
    // Here we start the AudioEngine, which instantiates
    await AudioEngine.loadSuperpoweredLibrary(constants.SP_LICENSE_KEY);

    processorNode.current = await AudioEngine.webaudioManager.createAudioNodeAsync(
      constants.ABSOLUTE_PROCESSOR_URL,
      "MixerProcessor",
      onMessageProcessorAudioScope
    );
    processorNode.current.connect(
      AudioEngine.webaudioManager.audioContext.destination
    );
    processorNode.current.onprocessorerror = (e) => {
      console.error(e);
    };

    loadAssets();
    startMeterRenderingDataRequestInterval();
  };

  const startMeterRenderingDataRequestInterval = () => {
    const requestPeaks = () => 
    {
      processorNode.current.sendMessageToAudioScope({
        type: "command",
        payload: {
          id: "requestPeaks",
        },
      });
      requestAnimationFrame(requestPeaks);
    }
    requestPeaks();
  };

  const onMessageProcessorAudioScope = (message) => {
    if (message.type === "peakData") {
      masterPeaks.stereo = message.peaks.master;
      aPeaks.stereo = message.peaks.a;
      bPeaks.stereo = message.peaks.b;
    }
    if (message.event === "assetsLoaded") {
      setAssetsLoaded(true);
      sendTempoCommand(INITIAL_TEMPO)
    }
  };

  const loadAssets = () => {
    processorNode.current.sendMessageToAudioScope({
      type: "command",
      payload: {
        id: "loadPlayerAssets",
        assets: [
          {
            url: "/superpowered-universal-app/audio/ramblinglibrarian.mp3",
            originalBPM: 120,
            firstBeatMs: 2024,
          },
          {
            url: "/superpowered-universal-app/audio/cdk.mp3",
            originalBPM: 101,
            firstBeatMs: 31,
          },
        ],
      },
    });
  };

  const sendChannelParamChange = (scope, channelIndex, paramName, value) => {
    processorNode.current.sendMessageToAudioScope({
      type: "parameterChange",
      data: {
        scope,
        channelIndex,
        paramName,
        value,
      },
    });
  };

  const sendPlayCommand = () => {
    setPlaying(!playing);
    AudioEngine.resume();
    processorNode.current.sendMessageToAudioScope({
      type: "command",
      payload: {
        id: playing ? "stopPlayback" : "startPlayback"
      },
    });
  };

  const sendTempoCommand = (v) => {
    processorNode.current.sendMessageToAudioScope({
      type: "command",
      payload: {
        id: "setTempo",
        tempo: v,
      },
    });
  };

  return (
    <MixerContainer $backgroundUrl={constants.RELATIVE_BACKGROUND_URL}>
      <Logo src="/superpowered-universal-app/images/superpowered-black.svg" alt="Superpowered logo" />
      <ChannelBank>
        <Channel
          onVolumeChange={(v) =>
            sendChannelParamChange("channel", 0, "channelGain", v)
          }
          onFilterChange={(v) =>
            sendChannelParamChange("channel", 0, "filterFrequency", v)
          }
          onRollChange={(v) => sendChannelParamChange("channel", 0, "roll", v)}
          onPitchChange={(v) =>
            sendChannelParamChange("channel", 0, "pitch", v)
          }
          peaks={aPeaks}
          label="A"
        ></Channel>

        <MainMeter peaks={masterPeaks} />

        <Channel
          onVolumeChange={(v) =>
            sendChannelParamChange("channel", 1, "channelGain", v)
          }
          onFilterChange={(v) =>
            sendChannelParamChange("channel", 1, "filterFrequency", v)
          }
          onRollChange={(v) => sendChannelParamChange("channel", 1, "roll", v)}
          onPitchChange={(v) =>
            sendChannelParamChange("channel", 1, "pitch", v)
          }
          peaks={bPeaks}
          label="B"
          flip={true}
        ></Channel>
      </ChannelBank>
      <Box sx={{ background: 'white', padding: '10px 20px', borderRadius: '15px', width: "80%", marginBottom: "10px" }}>
        <small>TEMPO</small>
        <Slider
          min={80}
          max={150}
          step={1}
          marks={[
            {
              value: 80,
              label: "80",
            },
            {
              value: 90,
              label: "90",
            },
            {
              value: 100,
              label: "100",
            },
            {
              value: 110,
              label: "110",
            },
            {
              value: 120,
              label: "120",
            },
            {
              value: 130,
              label: "130",
            },
            {
              value: 140,
              label: "140",
            },
            {
              value: 150,
              label: "150",
            },
          ]}
          defaultValue={INITIAL_TEMPO}
          onChange={(v) => sendTempoCommand(v)}
        />
      </Box>
      <Box sx={{ background: 'white', padding: '10px 20px', borderRadius: '15px', width: "80%", marginBottom: "10px" }}>
        <small>CROSSFADER</small>
        <Crossfader
          onVolumeChange={(v) =>
            sendChannelParamChange("global", null, "crossFaderPosition", v)
          }
        />
        <Box sx={{ width: "100%", marginTop: "10px", marginBottom: "10px" }}>
        <Button
          variant="contained"
          
          disabled={!assetsLoaded}
          onClick={() => sendPlayCommand()}
          
        >
        {!assetsLoaded ? "Loading.." : "Start/Stop"}
        </Button>
        </Box>
      </Box>
    </MixerContainer>
  );
};

export default Mixer;
