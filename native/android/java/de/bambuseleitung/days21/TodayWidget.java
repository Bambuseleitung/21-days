package de.bambuseleitung.days21;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.widget.RemoteViews;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import org.json.JSONObject;

// Startbildschirm-Widget: Fortschritt von heute, Serie und Platz in der Gruppe.
// Die Texte rechnet die Web-App aus (widgetData in index.html), hier wird nur angezeigt.
public class TodayWidget extends AppWidgetProvider {
    static final String PREFS = "days21_widget";

    @Override
    public void onUpdate(Context ctx, AppWidgetManager mgr, int[] ids) {
        for (int id : ids) mgr.updateAppWidget(id, build(ctx));
    }

    static void refreshAll(Context ctx) {
        AppWidgetManager mgr = AppWidgetManager.getInstance(ctx);
        int[] ids = mgr.getAppWidgetIds(new ComponentName(ctx, TodayWidget.class));
        for (int id : ids) mgr.updateAppWidget(id, build(ctx));
    }

    static RemoteViews build(Context ctx) {
        RemoteViews v = new RemoteViews(ctx.getPackageName(), R.layout.widget_today);
        String main = "21 Days", sub = "Tippen zum Öffnen", group = "";
        try {
            JSONObject d = new JSONObject(ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString("data", "{}"));
            String today = new SimpleDateFormat("yyyy-MM-dd", Locale.US).format(new Date());
            if (d.has("day")) {
                // the values are from an older day until the app is opened again
                boolean fresh = today.equals(d.optString("day"));
                main = fresh ? d.optString("main", main) : "Neuer Tag";
                sub = fresh ? d.optString("sub", "") : d.optString("idle", "");
                group = d.optString("group", "");
            }
        } catch (Exception e) {
            // keep the defaults
        }
        v.setTextViewText(R.id.w_main, main);
        v.setTextViewText(R.id.w_sub, sub);
        v.setTextViewText(R.id.w_group, group);
        v.setViewVisibility(R.id.w_group, group.isEmpty() ? View.GONE : View.VISIBLE);
        Intent open = ctx.getPackageManager().getLaunchIntentForPackage(ctx.getPackageName());
        if (open != null) {
            v.setOnClickPendingIntent(R.id.w_root, PendingIntent.getActivity(ctx, 0, open, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE));
        }
        return v;
    }
}
