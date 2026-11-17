package de.bambuseleitung.days21;

import android.content.Context;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

// Aus der Web-App: Capacitor.Plugins.DaysWidget.update({ data: "<JSON>" }) speichert die Werte und zeichnet das Widget neu.
@CapacitorPlugin(name = "DaysWidget")
public class WidgetPlugin extends Plugin {
    @PluginMethod
    public void update(PluginCall call) {
        Context ctx = getContext();
        ctx.getSharedPreferences(TodayWidget.PREFS, Context.MODE_PRIVATE).edit().putString("data", call.getString("data", "{}")).apply();
        TodayWidget.refreshAll(ctx);
        call.resolve();
    }
}
