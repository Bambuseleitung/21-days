package de.bambuseleitung.days21;

import android.app.AppOpsManager;
import android.app.usage.UsageEvents;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Process;
import android.provider.AlarmClock;
import android.provider.Settings;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;

// Aus der Web-App:
//   Capacitor.Plugins.DaysWidget.update({ data: "<JSON>" })  speichert die Werte und zeichnet das Widget neu.
//   Capacitor.Plugins.DaysWidget.setAlarm({ hour, minute, days: [1..7] (So=1 … Sa=7), label })
//     stellt einen echten Wecker in der Uhr-App (Gewohnheit "Früh aufstehen"). Braucht die Berechtigung SET_ALARM im Manifest.
@CapacitorPlugin(name = "DaysWidget")
public class WidgetPlugin extends Plugin {
    @PluginMethod
    public void update(PluginCall call) {
        Context ctx = getContext();
        ctx.getSharedPreferences(TodayWidget.PREFS, Context.MODE_PRIVATE).edit().putString("data", call.getString("data", "{}")).apply();
        TodayWidget.refreshAll(ctx);
        call.resolve();
    }

    // Bildschirmzeit von heute in Minuten (Vordergrund-Zeit aller Apps seit Mitternacht).
    // Braucht den Nutzungszugriff, den der Nutzer einmal in den Einstellungen erlaubt (openUsageSettings).
    @PluginMethod
    public void usage(PluginCall call) {
        Context ctx = getContext();
        AppOpsManager ops = (AppOpsManager) ctx.getSystemService(Context.APP_OPS_SERVICE);
        int mode = Build.VERSION.SDK_INT >= 29
            ? ops.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), ctx.getPackageName())
            : ops.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), ctx.getPackageName());
        JSObject r = new JSObject();
        if (mode != AppOpsManager.MODE_ALLOWED) { r.put("granted", false); call.resolve(r); return; }
        UsageStatsManager um = (UsageStatsManager) ctx.getSystemService(Context.USAGE_STATS_SERVICE);
        Calendar c = Calendar.getInstance();
        c.set(Calendar.HOUR_OF_DAY, 0); c.set(Calendar.MINUTE, 0); c.set(Calendar.SECOND, 0); c.set(Calendar.MILLISECOND, 0);
        long start = c.getTimeInMillis(), end = System.currentTimeMillis(), total = 0;
        String home = null;
        Intent hi = new Intent(Intent.ACTION_MAIN); hi.addCategory(Intent.CATEGORY_HOME);
        if (ctx.getPackageManager().resolveActivity(hi, 0) != null) home = ctx.getPackageManager().resolveActivity(hi, 0).activityInfo.packageName;
        UsageEvents ev = um.queryEvents(start, end);
        UsageEvents.Event e = new UsageEvents.Event();
        HashMap<String, Long> open = new HashMap<>();
        while (ev.hasNextEvent()) {
            ev.getNextEvent(e);
            String p = e.getPackageName();
            if (p == null || p.equals(home)) continue; // the home screen does not count, like in Digital Wellbeing
            if (e.getEventType() == UsageEvents.Event.MOVE_TO_FOREGROUND) open.put(p, e.getTimeStamp());
            else if (e.getEventType() == UsageEvents.Event.MOVE_TO_BACKGROUND) { Long s = open.remove(p); if (s != null) total += e.getTimeStamp() - s; }
        }
        for (Long s : open.values()) total += end - s;
        r.put("granted", true);
        r.put("minutes", Math.round(total / 60000.0));
        call.resolve(r);
    }

    @PluginMethod
    public void openUsageSettings(PluginCall call) {
        Intent i = new Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        try { getContext().startActivity(i); call.resolve(); } catch (Exception ex) { call.reject("Einstellungen nicht gefunden", "no_settings"); }
    }

    @PluginMethod
    public void setAlarm(PluginCall call) {
        Intent i = new Intent(AlarmClock.ACTION_SET_ALARM);
        i.putExtra(AlarmClock.EXTRA_HOUR, call.getInt("hour", 7).intValue());
        i.putExtra(AlarmClock.EXTRA_MINUTES, call.getInt("minute", 0).intValue());
        i.putExtra(AlarmClock.EXTRA_MESSAGE, call.getString("label", "21 Days"));
        i.putExtra(AlarmClock.EXTRA_VIBRATE, true);
        JSArray days = call.getArray("days");
        if (days != null && days.length() > 0) {
            ArrayList<Integer> d = new ArrayList<>();
            for (int k = 0; k < days.length(); k++) {
                int v = days.optInt(k, 0);
                if (v >= 1 && v <= 7 && !d.contains(v)) d.add(v);
            }
            if (!d.isEmpty()) i.putIntegerArrayListExtra(AlarmClock.EXTRA_DAYS, d);
        }
        i.putExtra(AlarmClock.EXTRA_SKIP_UI, false); // Uhr-App zeigt den Wecker zur Bestätigung
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        try {
            getContext().startActivity(i);
            call.resolve();
        } catch (Exception e) {
            call.reject("Keine Uhr-App gefunden", "no_clock_app");
        }
    }
}
