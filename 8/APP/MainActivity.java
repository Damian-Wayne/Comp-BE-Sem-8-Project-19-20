package com.example.pls;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;


import com.pusher.pushnotifications.PushNotifications;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity{


    public Button logindoc;
    public Button loginpat;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        PushNotifications.start(getApplicationContext(), "b4bac2d1-a26b-4a81-a7e4-9d54696497e3");
        PushNotifications.addDeviceInterest("hello");



        logindoc= (Button) findViewById(R.id.logindoc);
        logindoc.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                logind();
            }
        });
        loginpat= (Button) findViewById(R.id.loginpat);
        loginpat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                login();
            }
        });

    }








    public void login() {
        Intent intent = new Intent(this, login.class);
        startActivity(intent);
    }

    public void logind() {
        Intent intent = new Intent(this, logind.class);
        startActivity(intent);
    }

}

