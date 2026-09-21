package com.login2.mentorbee;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class YourApplication extends FlutterApplication {

    private static YourApplication instance;
    private FlutterEngine flutterEngine;

    public static YourApplication getInstance() {
        return instance;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        initializeFlutterEngine();
        registerPlugins();
    }

    private void initializeFlutterEngine() {
        flutterEngine = new FlutterEngine(this);
        // Configure the Flutter engine as needed
    }

    public FlutterEngine getFlutterEngine() {
        return flutterEngine;
    }

    private void registerPlugins() {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
