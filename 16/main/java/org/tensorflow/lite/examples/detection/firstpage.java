package org.tensorflow.lite.examples.detection;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class firstpage extends AppCompatActivity {

    private Button btn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_firstpage);
        WebView wv1=(WebView)findViewById(R.id.webView);
        final TextView textView=(TextView)findViewById(R.id.contentView);

        String url = "http://192.168.43.12/"; //192.168.43.12
        wv1.loadUrl(url);

        wv1.setFindListener(new WebView.FindListener() {

            @Override
            public void onFindResultReceived(int activeMatchOrdinal, int numberOfMatches, boolean isDoneCounting) {
                // Toast.makeText(getApplicationContext(), "Matches: " + numberOfMatches, Toast.LENGTH_LONG).show();
                if(numberOfMatches==1){
                    Intent i = new Intent(getBaseContext(), DetectorActivity.class);
                    startActivity(i);
                    finish();
                }
            }
        });
        Runnable myRunnable = new Runnable() {
            @Override
            public void run() {
                while (1==1) {
                    try {
                        Thread.sleep(3000); // Waits for 3 second (1000 milliseconds)

                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    Log.i("Identified Objects: ", "done");
                    textView.post(new Runnable() {
                        @Override
                        public void run() {
                            wv1.reload();
                            // wv1.findAll("l");
                            //textView.setText(String.valueOf(x));
                            wv1.findAllAsync("l");
                        }
                    });
                }
            };
        };

        Thread myThread = new Thread(myRunnable);
        myThread.start();

    }

}
