package org.tensorflow.lite.examples.detection;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import static android.content.ContentValues.TAG;

public class intro extends AppCompatActivity {

    WifiApManager wifiApManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_intro);

        wifiApManager = new WifiApManager(this);

        wifiApManager.setWifiApEnabled(null, true);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_USER);

        View imageView = findViewById(R.id.imageView);
        MediaPlayer welcome= MediaPlayer.create(intro.this,R.raw.welcome);
        MediaPlayer swipe= MediaPlayer.create(intro.this,R.raw.swipe);
        welcome.start();
        imageView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event)
            {
                if(event.getAction() == MotionEvent.ACTION_DOWN)
                {
                    Intent i = new Intent(getBaseContext(), firstpage.class);
                    startActivity(i);
                    finish();
                }
                return true;
            }

        });
    }
}
