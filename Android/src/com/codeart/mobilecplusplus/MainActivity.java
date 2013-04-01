package com.codeart.mobilecplusplus;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

public class MainActivity extends Activity implements View.OnClickListener {
    /**
     * Called when the activity is first created.
     */
    Button sendBtn;
    EditText toSend;
    EditText chatLog;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        startWSComms();
        sendMessage("{ \"body\":\"testAndroid\"}");
        sendBtn = (Button)findViewById(R.id.send);
        sendBtn.setOnClickListener(this);
        toSend = (EditText)findViewById(R.id.sendMessage);
        chatLog = (EditText)findViewById(R.id.editText);
        Thread t = new Thread(new Runnable() {
            @Override
            public void run() {
                while(true){
                    final String ret = getNewChat();
                    if(!ret.equals("0")) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Log.e("mobilecpp", ret);
                                chatLog.append(ret);
                            }
                        });
                    }
                }
            }
        });
        t.start();
    }

    static {
        System.loadLibrary("mobilecpp");
    }



    public static native void startWSComms();
    public static native void sendMessage(String message);
    public static native String getNewChat();

    @Override
    public void onClick(View v) {
        if(toSend.getText().length() > 0) {
            sendMessage("{\"body\":\"" +toSend.getText().toString()+"\"}");
            toSend.setText("");
        }

        //To change body of implemented methods use File | Settings | File Templates.
    }

    public void displayMessage(String msg) {
        try{
            JSONObject jmsg = new JSONObject(msg);
            chatLog.append(jmsg.optString("body"));
        } catch (Exception ex) {
            chatLog.append(ex.toString());
        }

    }
}
