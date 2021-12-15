import React, { useState, useEffect, useRef } from "react";
import {
  SuperpoweredGlue,
  SuperpoweredWebAudio,
} from "../lib/superpowered/SuperpoweredWebAudio.js";

import styled from "styled-components";
import Channel from "./channel";
import Crossfader from "../components/crossfader";
import Slider from "../components/slider.js";
import MainMeter from "../components/mainMeter.js";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";

const MixerContainer = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  max-width: 500px;
  margin: 0 10px 20px 10px;
  padding: 10px;
  border: 1px solid #1253FF;
  border-radius: 15px;
  background: url(/superpowered-universal-app/images/wave.png);
  background-size: cover;
  background-repeat: no-repeat;
  background-position: center center;
  box-shadow: 10px 10px #e7e5e5;
`;

const ChannelBank = styled.div`
  display: flex;
  justify-content: center;
  margin-bottom: 10px;
`;

const Logo = styled.img`
margin: 10px 0;
`;

const aPeaks = {
  stereo: 0,
};
const bPeaks = {
  stereo: 0,
};
const masterPeaks = {
  stereo: 0,
};

const Mixer = () => {
  const webaudioManager = useRef();
  const processorNode = useRef();
  const [assetsLoaded, setAssetsLoaded] = useState(false);
  const [playing, setPlaying] = useState(false);

  useEffect(() => {
    loadSP();
  }, []);

  const loadSP = async () => {
    const superpowered = await SuperpoweredGlue.fetch(
      "/superpowered-universal-app/superpowered/superpowered.wasm"
    );
    superpowered.Initialize({
      licenseKey: "ExampleLicenseKey-WillExpire-OnNextUpdate",
      enableAudioAnalysis: true,
      enableFFTAndFrequencyDomain: true,
      enableAudioTimeStretching: true,
      enableAudioEffects: true,
      enableAudioPlayerAndDecoder: true,
      enableCryptographics: false,
      enableNetworking: false,
    });
    webaudioManager.current = new SuperpoweredWebAudio(48000, superpowered);

    processorNode.current = await webaudioManager.current.createAudioNodeAsync(
      "/superpowered-universal-app/processorScripts/mixerProcessorScript.js",
      "MixerProcessor",
      onMessageProcessorAudioScope
    );
    processorNode.current.connect(
      webaudioManager.current.audioContext.destination
    );
    processorNode.current.onprocessorerror = (e) => {
      console.error(e);
    };

    loadAssets();
    startMeterRenderingDataRequestInterval();
  };

  const startMeterRenderingDataRequestInterval = () => {
    setInterval(() => {
      processorNode.current.sendMessageToAudioScope({
        type: "command",
        payload: {
          id: "requestPeaks",
        },
      });
    }, 50);
  };

  const onMessageProcessorAudioScope = (message) => {
    // console.log(message);
    if (message.type === "peakData") {
      masterPeaks.stereo = message.peaks.master;
      aPeaks.stereo = message.peaks.a;
      bPeaks.stereo = message.peaks.b;
    }
    if (message.event === "assetsLoaded") {
      setAssetsLoaded(true);
    }
  };

  const loadAssets = () => {
    processorNode.current.sendMessageToAudioScope({
      type: "command",
      payload: {
        id: "loadPlayerAssets",
        assets: [
          {
            url: "/superpowered-universal-app/audio/lycka.mp3",
            originalBPM: 126,
            firstBeatMs: 353,
          },
          {
            url: "/superpowered-universal-app/audio/nuyorica.m4a",
            originalBPM: 123,
            firstBeatMs: 40,
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
    webaudioManager.current.audioContext.resume();
    processorNode.current.sendMessageToAudioScope({
      type: "command",
      payload: {
        id: playing? "stopPlayback" : "startPlayback",
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
    <MixerContainer>
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
              label: "80",
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
          defaultValue={126}
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
