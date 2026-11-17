package de.bambuseleitung.days21;

import android.os.Bundle;
import com.getcapacitor.BridgeActivity;

// Ersetzt die von "cap add android" erzeugte Datei: meldet das eigene Widget-Plugin an.
public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        registerPlugin(WidgetPlugin.class);
        super.onCreate(savedInstanceState);
    }
}
