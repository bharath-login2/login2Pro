// package com.login2.mentorbee;
package com.example.login2;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MyStartupReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction() != null && intent.getAction().equals(Intent.ACTION_BOOT_COMPLETED)) {
            invokeFlutterFunction();
        }
    }

    private void invokeFlutterFunction() {
        try {
            FlutterEngine flutterEngine = YourApplication.getInstance().getFlutterEngine();
            MethodChannel methodChannel = new MethodChannel(
                    flutterEngine.getDartExecutor().getBinaryMessenger(),
                    "onreBootInitFunctionChannel"
            );
            methodChannel.invokeMethod("setAsBackgroundService", null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
