package org.tensorflow.lite.examples.detection;

import android.content.Intent;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.CountDownTimer;

import androidx.appcompat.app.AppCompatActivity;

public class third extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_third);

        MediaPlayer person= MediaPlayer.create(third.this,R.raw.person);
        MediaPlayer bench= MediaPlayer.create(third.this,R.raw.bench);
        MediaPlayer bus= MediaPlayer.create(third.this,R.raw.bus);
        MediaPlayer cat= MediaPlayer.create(third.this,R.raw.cat);
        MediaPlayer chair= MediaPlayer.create(third.this,R.raw.chair);
        MediaPlayer couch= MediaPlayer.create(third.this,R.raw.couch);
        MediaPlayer dog= MediaPlayer.create(third.this,R.raw.dog);
        MediaPlayer plant= MediaPlayer.create(third.this,R.raw.plant);
        MediaPlayer stop= MediaPlayer.create(third.this,R.raw.stop);
        MediaPlayer traffic= MediaPlayer.create(third.this,R.raw.traffic);
        MediaPlayer vehicle= MediaPlayer.create(third.this,R.raw.vehicle);

        Bundle extras = getIntent().getExtras();
        String name = extras.getString("name");
        String percent = extras.getString("percent");

        switch (name){
            case "person":
                person.start();
                break;

            case "bench":
                bench.start();
                break;

            case "bus":
                bus.start();
                break;

            case "cat":
                cat.start();
                break;

            case "chair":
                chair.start();
                break;

            case "couch":
                couch.start();
                break;

            case "dog":
                dog.start();
                break;

            case "potted":
                plant.start();
                break;

            case "stop":
                stop.start();
                break;

            case "traffic":
                traffic.start();
                break;

            case "vehicle":
                vehicle.start();
                break;
        }

        new CountDownTimer(2000, 1000) {
            public void onFinish() {
                // When timer is finished
                // Execute your code here
                Intent i = new Intent(getBaseContext(), firstpage.class);
                startActivity(i);
                finish();
            }

            public void onTick(long millisUntilFinished) {
                // millisUntilFinished    The amount of time until finished.
            }
        }.start();
    }
}
