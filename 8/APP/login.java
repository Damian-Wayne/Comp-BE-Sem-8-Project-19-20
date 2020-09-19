package com.example.pls;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;




import androidx.appcompat.app.AppCompatActivity;

public class login extends AppCompatActivity{

    public EditText username;
    public EditText password;
    public Button login;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        username = (EditText) findViewById(R.id.usernameET);
        password = (EditText) findViewById(R.id.passwordET);
        login = (Button) findViewById(R.id.loginBtn);
        login.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                details();
            }
        });


    }








    public void details() {
        Intent intent = new Intent(this, details.class);
        startActivity(intent);
    }

}

