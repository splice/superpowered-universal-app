package com.superpowered.universalpapp;

import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.appcompat.app.AppCompatActivity;

import android.content.DialogInterface;
import android.content.res.AssetFileDescriptor;
import android.os.Bundle;
import android.os.Handler;
import android.media.AudioManager;
import android.content.Context;
import android.content.pm.PackageManager;
import androidx.annotation.NonNull;

import android.text.method.LinkMovementMethod;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;
import android.Manifest;
import com.superpowered.boilerplate.R;

import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends AppCompatActivity {

    final Handler myHandler = new Handler();

    ProgressBar channel0ProgressBar;
    SeekBar channel0GainSeekBar;
    SeekBar channel0FilterSeekBar;
    Button channel0RollButton1;
    Button channel0RollButton2;
    Button channel0RollButton3;
    Button channel0RollButton4;
    Button channel0LowerPitchButton;
    Button channel0RaisePitchButton;
    TextView channel0PitchTextView;

    ProgressBar channel1ProgressBar;
    SeekBar channel1GainSeekBar;
    SeekBar channel1FilterSeekBar;
    Button channel1RollButton1;
    Button channel1RollButton2;
    Button channel1RollButton3;
    Button channel1RollButton4;
    Button channel1LowerPitchButton;
    Button channel1RaisePitchButton;
    TextView channel1PitchTextView;

    SeekBar tempoSeekBar;
    SeekBar crossfadeSeekBar;
    ProgressBar masterProgressBar;
    Button playButton;

    ImageView infoButton;

    float channel0Roll = 0;
    float channel1Roll = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        getSupportActionBar().hide();

        // Checking permissions.
        String[] permissions = {
                Manifest.permission.MODIFY_AUDIO_SETTINGS
        };
        for (String s:permissions) {
            if (ContextCompat.checkSelfPermission(this, s) != PackageManager.PERMISSION_GRANTED) {
                // Some permissions are not granted, ask the user.
                ActivityCompat.requestPermissions(this, permissions, 0);
                return;
            }
        }

        // Got all permissions, initialize.
        initialize();

        playButton = (Button) findViewById(R.id.playButton);
        playButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                MixerTogglePlay();
            }
        });

        tempoSeekBar = (SeekBar) findViewById(R.id.tempoSeekBar);
        tempoSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                float newValue = i + 80;
                MixerSetTempo(newValue);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        crossfadeSeekBar = (SeekBar) findViewById(R.id.crossfadeSeekBar);
        crossfadeSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                float newValue = (float)i / (float)100.0;
                MixerSetCrossFaderPosition(newValue);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        channel0ProgressBar = (ProgressBar) findViewById(R.id.channel0ProgressBar);
        channel1ProgressBar = (ProgressBar) findViewById(R.id.channel1ProgressBar);
        masterProgressBar = (ProgressBar) findViewById(R.id.masterProgressBar);

        channel0GainSeekBar = (SeekBar) findViewById(R.id.channel0GainSeekBar);
        channel0GainSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                float newValue = (float)i / (float)100.0;
                MixerSetVolumeForChannel(0, newValue);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        channel1GainSeekBar = (SeekBar) findViewById(R.id.channel1GainSeekBar);
        channel1GainSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                float newValue = (float)i / (float)100.0;
                MixerSetVolumeForChannel(1, newValue);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        channel0FilterSeekBar = (SeekBar) findViewById(R.id.channel0FilterSeekBar);
        channel0FilterSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                float newValue = (float)i / (float)100.0;
                MixerSetFilterFrequencyPositionForChannel(0, newValue);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        channel1FilterSeekBar = (SeekBar) findViewById(R.id.channel1FilterSeekBar);
        channel1FilterSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                float newValue = (float)i / (float)100.0;
                MixerSetFilterFrequencyPositionForChannel(1, newValue);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        channel0RollButton1 = (Button) findViewById(R.id.channel0RollButton1);
        channel0RollButton2 = (Button) findViewById(R.id.channel0RollButton2);
        channel0RollButton3 = (Button) findViewById(R.id.channel0RollButton3);
        channel0RollButton4 = (Button) findViewById(R.id.channel0RollButton4);

        channel0RollButton1.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                updateChannel0RollButtons(0.25f);
            }
        });
        channel0RollButton2.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                updateChannel0RollButtons(0.5f);
            }
        });
        channel0RollButton3.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                updateChannel0RollButtons(1f);
            }
        });
        channel0RollButton4.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                updateChannel0RollButtons(2f);
            }
        });

        channel1RollButton1 = (Button) findViewById(R.id.channel1RollButton1);
        channel1RollButton2 = (Button) findViewById(R.id.channel1RollButton2);
        channel1RollButton3 = (Button) findViewById(R.id.channel1RollButton3);
        channel1RollButton4 = (Button) findViewById(R.id.channel1RollButton4);

        channel1RollButton1.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                updateChannel1RollButtons(0.25f);
            }
        });
        channel1RollButton2.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                updateChannel1RollButtons(0.5f);
            }
        });
        channel1RollButton3.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                updateChannel1RollButtons(1f);
            }
        });
        channel1RollButton4.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                updateChannel1RollButtons(2f);
            }
        });

        channel0LowerPitchButton = (Button) findViewById(R.id.channel0LowerPitchButton);
        channel0RaisePitchButton = (Button) findViewById(R.id.channel0RaisePitchButton);
        channel0PitchTextView = (TextView) findViewById(R.id.channel0PitchTextView);

        channel0LowerPitchButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                int pitch = MixerGetPitchShiftForChannel(0);
                MixerSetPitchShiftForChannel(0, pitch - 1);
                pitch = MixerGetPitchShiftForChannel(0);
                channel0PitchTextView.setText("" + pitch);
            }
        });
        channel0RaisePitchButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                int pitch = MixerGetPitchShiftForChannel(0);
                MixerSetPitchShiftForChannel(0, pitch + 1);
                pitch = MixerGetPitchShiftForChannel(0);
                channel0PitchTextView.setText("" + pitch);
            }
        });

        channel1LowerPitchButton = (Button) findViewById(R.id.channel1LowerPitchButton);
        channel1RaisePitchButton = (Button) findViewById(R.id.channel1RaisePitchButton);
        channel1PitchTextView = (TextView) findViewById(R.id.channel1PitchTextView);

        channel1LowerPitchButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                int pitch = MixerGetPitchShiftForChannel(1);
                MixerSetPitchShiftForChannel(1, pitch - 1);
                pitch = MixerGetPitchShiftForChannel(1);
                channel1PitchTextView.setText("" + pitch);
            }
        });
        channel1RaisePitchButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                int pitch = MixerGetPitchShiftForChannel(1);
                MixerSetPitchShiftForChannel(1, pitch + 1);
                pitch = MixerGetPitchShiftForChannel(1);
                channel1PitchTextView.setText("" + pitch);
            }
        });

        infoButton =  (ImageView) findViewById(R.id.info_button);
        infoButton.setOnClickListener(view -> {
            showCreditsDialog();
        });


        Timer myTimer = new Timer();
        myTimer.schedule(new TimerTask() {
            @Override
            public void run() {UpdateGUI();}
        }, 0, 100);
    }

    private void showCreditsDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Song Credits");

        // Use a scrollable TextView in the dialog for long messages
        ScrollView scrollView = new ScrollView(this);
        TextView textView = new TextView(this);
        textView.setPadding(32, 32, 32, 32); // Add padding for aesthetic spacing
        textView.setText("I Have Often Told You Stories (guitar instrumental) by Ivan Chew (c) copyright 2013 Licensed under a Creative Commons Attribution (3.0) license. https://dig.ccmixter.org/files/ramblinglibrarian/41284 \n\n" +
                "ＭＩＬＬＥＮＮＩＡＬＳ by cdk (c) copyright 2018 Licensed under a Creative Commons Attribution (3.0) license. https://dig.ccmixter.org/files/cdk/57150 ");
        textView.setMovementMethod(LinkMovementMethod.getInstance()); // Make links clickable
        scrollView.addView(textView);

        builder.setView(scrollView);

        builder.setPositiveButton("Close", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                dialogInterface.dismiss();
            }
        });

        AlertDialog dialog = builder.create();
        dialog.show();
    }

    private void UpdateGUI() {
        myHandler.post(myRunnable);
    }

    private void updateChannel0RollButtons(float newValue) {
        channel0Roll = (channel0Roll == newValue) ? 0 : newValue;

        channel0RollButton1.setAlpha(channel0Roll == 0.25f ? 0.25f : 1.0f);
        channel0RollButton2.setAlpha(channel0Roll == 0.5f ? 0.25f : 1.0f);
        channel0RollButton3.setAlpha(channel0Roll == 1f ? 0.25f : 1.0f);
        channel0RollButton4.setAlpha(channel0Roll == 2f ? 0.25f : 1.0f);

        if (channel0Roll == 0) {
            MixerSetRollDisabledForChannel(0);
        } else {
            MixerSetRollEnabledForChannel(0, channel0Roll);
        }
    }

    private void updateChannel1RollButtons(float newValue) {
        channel1Roll = (channel1Roll == newValue) ? 0 : newValue;

        channel1RollButton1.setAlpha(channel1Roll == 0.25f ? 0.25f : 1.0f);
        channel1RollButton2.setAlpha(channel1Roll == 0.5f ? 0.25f : 1.0f);
        channel1RollButton3.setAlpha(channel1Roll == 1f ? 0.25f : 1.0f);
        channel1RollButton4.setAlpha(channel1Roll == 2f ? 0.25f : 1.0f);

        if (channel1Roll == 0) {
            MixerSetRollDisabledForChannel(1);
        } else {
            MixerSetRollEnabledForChannel(1, channel1Roll);
        }
    }

    final Runnable myRunnable = new Runnable() {
        public void run() {
            masterProgressBar.setProgress((int)(MixerGetPeak() * 100.0));
            channel0ProgressBar.setProgress((int)(MixerGetPeakForChannel(0) * 100.0));
            channel1ProgressBar.setProgress((int)(MixerGetPeakForChannel(1) * 100.0));
        }
    };

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        // Called when the user answers to the permission dialogs.
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if ((requestCode != 0) || (grantResults.length < 1) || (grantResults.length != permissions.length))
            return;
        boolean hasAllPermissions = true;

        for (int grantResult : grantResults)
            if (grantResult != PackageManager.PERMISSION_GRANTED) {
                hasAllPermissions = false;
                Toast.makeText(getApplicationContext(), "Please allow all permissions for the app.", Toast.LENGTH_LONG).show();
            }

        if (hasAllPermissions) initialize();
    }

    private void initialize() {
        AssetFileDescriptor fd0 = getResources().openRawResourceFd(R.raw.ramblinglibrarian);
        AssetFileDescriptor fd1 = getResources().openRawResourceFd(R.raw.cdk);
        int fileAoffset = (int)fd0.getStartOffset();
        int fileAlength = (int)fd0.getLength();
        int fileBoffset = (int)fd1.getStartOffset();
        int fileBlength = (int)fd1.getLength();
        try {
            fd0.getParcelFileDescriptor().close();
            fd1.getParcelFileDescriptor().close();
        } catch (IOException e) {
            android.util.Log.d("", "Close error.");
        }

        // Get the device's sample rate and buffer size to enable
        // low-latency Android audio output, if available.
        String samplerateString = null, buffersizeString = null;
        AudioManager audioManager = (AudioManager) this.getSystemService(Context.AUDIO_SERVICE);
        if (audioManager != null) {
            samplerateString = audioManager.getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE);
            buffersizeString = audioManager.getProperty(AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER);
        }
        if (samplerateString == null) samplerateString = "48000";
        if (buffersizeString == null) buffersizeString = "480";
        int samplerate = Integer.parseInt(samplerateString);
        int buffersize = Integer.parseInt(buffersizeString);

        // Files under res/raw are not zipped, just copied into the APK.
        // Get the offset and length to know where our files are located.
        String apkPath = getPackageResourcePath();

        // Initialize the players and effects, and start the audio engine.
        System.loadLibrary("SuperpoweredUniversalApp");
        // If the application crashes, please disable Instant Run under Build, Execution, Deployment in preferences.
        SuperpoweredUniversalApp(
                samplerate,     // sampling rate
                buffersize,     // buffer size
                apkPath,        // path to .apk package,
                fileAoffset,
                fileAlength,
                fileBoffset,
                fileBlength
        );

    }

    // Functions implemented in the native library.
    private native void SuperpoweredUniversalApp(int samplerate, int buffersize, String apkPath, int fileAoffset, int fileAlength, int fileBoffset, int fileBlength);

    private native void MixerTogglePlay();
    private native float MixerGetPeak();
    private native float MixerGetPeakForChannel(int channel);
    private native void MixerSetCrossFaderPosition(float newValue);
    private native void MixerSetTempo(float newValue);
    private native void MixerSetFilterFrequencyPositionForChannel(int channel, float newValue);
    private native void MixerSetVolumeForChannel(int channel, float newValue);
    private native void MixerSetRollEnabledForChannel(int channel, float newValue);
    private native void MixerSetRollDisabledForChannel(int channel);
    private native void MixerSetPitchShiftForChannel(int channel, int newValue);
    private native int MixerGetPitchShiftForChannel(int channel);

}
