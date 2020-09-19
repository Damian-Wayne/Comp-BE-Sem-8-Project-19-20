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

public class monitor extends AppCompatActivity {

    EditText editText;
    Button fetch,msg;
    DatabaseReference rootRef,demoRef,demoRef1;
    TextView demoValue,emvalue,tv1Value;

    @Override
    protected void onCreate(Bundle savedInstanceState) {        super.onCreate(savedInstanceState);        setContentView(R.layout.activity_monitor);

        editText = (EditText)findViewById(R.id.etValue);
        demoValue = (TextView) findViewById(R.id.tvValue);
        tv1Value = (TextView) findViewById(R.id.tv1Value);
        emvalue = (TextView) findViewById(R.id.emValue);


        fetch = (Button) findViewById(R.id.fetch);
        msg = (Button) findViewById(R.id.msg);
//database reference pointing to root of database
        rootRef = FirebaseDatabase.getInstance().getReference();

//database reference pointing to demo node
        demoRef = rootRef.child("sensor/value2");
        demoRef1 = rootRef.child("doc");


        fetch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                demoRef.child("/").addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        String value = dataSnapshot.child("/").getValue().toString();
                        demoValue.setText(value);
                    }

                    @Override
                    public void onCancelled(DatabaseError databaseError) {
                    }
                });
            }
        });
        msg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                demoRef1.child("/").addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        String value1 = dataSnapshot.child("/").getValue().toString();
                        tv1Value.setText(value1);
                    }

                    @Override
                    public void onCancelled(DatabaseError databaseError) {
                    }
                });
            }
        });
    }
}


