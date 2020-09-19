package com.example.pls;


import android.os.Bundle;



import android.view.View;
import android.widget.Button;import android.widget.EditText;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class monitord extends AppCompatActivity {

    EditText editText,  message;
    Button fetch;
    Button msg;
    DatabaseReference rootRef,demoRef,demoRefmsg ;
    TextView demoValue, send;

    @Override
    protected void onCreate(Bundle savedInstanceState) {        super.onCreate(savedInstanceState);        setContentView(R.layout.activity_monitord);

        editText = (EditText)findViewById(R.id.etValue);
        send = (TextView) findViewById(R.id.emValue);
        message = (EditText)findViewById(R.id.emesValue);
        demoValue = (TextView) findViewById(R.id.tvValue);


        fetch = (Button) findViewById(R.id.fetch);
        msg = (Button) findViewById(R.id.message);
//database reference pointing to root of database
        rootRef = FirebaseDatabase.getInstance().getReference();
        demoRefmsg = rootRef.child("doc");
//database reference pointing to demo node
        demoRef = rootRef.child("sensor/value2");
        msg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                String value = message.getText().toString();

                //push creates a unique id in database
                demoRefmsg.push().setValue(value);
            }
        });

        fetch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                demoRef.child("/").addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        String value1 = dataSnapshot.child("/").getValue().toString();
                        demoValue.setText(value1);
                    }

                    @Override
                    public void onCancelled(DatabaseError databaseError) {
                    }
                });
            }
        });
    }
}


