import Foundation
import Capacitor
import AlarmKit
import SwiftUI

// Aus der Web-App (nur iPhone, ab iOS 26):
//   Capacitor.Plugins.DaysAlarm.set({ id, hour, minute, days: [0..6] (Mo=0 … So=6), label })  -> { id }
//   Capacitor.Plugins.DaysAlarm.cancel({ id })
// Ein echter Wecker über AlarmKit: klingelt wie die Uhr-App, auch im Lautlos-Modus und im Fokus.

@available(iOS 26.0, *)
struct DaysAlarmMeta: AlarmMetadata {}

@objc(DaysAlarmPlugin)
public class DaysAlarmPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "DaysAlarmPlugin"
    public let jsName = "DaysAlarm"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "set", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "cancel", returnType: CAPPluginReturnPromise)
    ]

    @objc func set(_ call: CAPPluginCall) {
        guard #available(iOS 26.0, *) else { call.reject("Der Wecker braucht iOS 26 oder neuer", "unsupported"); return }
        let hour = call.getInt("hour") ?? 7
        let minute = call.getInt("minute") ?? 0
        let days = call.getArray("days", Int.self) ?? []
        let label = call.getString("label") ?? "21 Days"
        let oldId = UUID(uuidString: call.getString("id") ?? "")
        Task {
            do {
                let manager = AlarmManager.shared
                if manager.authorizationState != .authorized {
                    let state = try await manager.requestAuthorization()
                    guard state == .authorized else { call.reject("Keine Erlaubnis für Wecker", "denied"); return }
                }
                if let old = oldId { try? manager.cancel(id: old) }
                let map: [Locale.Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
                let weekdays = days.filter { $0 >= 0 && $0 < 7 }.map { map[$0] }
                let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
                let schedule = Alarm.Schedule.relative(Alarm.Schedule.Relative(time: time, repeats: weekdays.isEmpty ? .never : .weekly(weekdays)))
                let alert = AlarmPresentation.Alert(title: LocalizedStringResource("\(label)"), secondaryButton: nil, secondaryButtonBehavior: nil)
                let attributes = AlarmAttributes<DaysAlarmMeta>(presentation: AlarmPresentation(alert: alert), metadata: nil, tintColor: .orange)
                let config = AlarmManager.AlarmConfiguration<DaysAlarmMeta>(countdownDuration: nil, schedule: schedule, attributes: attributes, sound: .default)
                let id = UUID()
                _ = try await manager.schedule(id: id, configuration: config)
                call.resolve(["id": id.uuidString])
            } catch {
                call.reject(error.localizedDescription, "failed")
            }
        }
    }

    @objc func cancel(_ call: CAPPluginCall) {
        if #available(iOS 26.0, *), let id = UUID(uuidString: call.getString("id") ?? "") {
            try? AlarmManager.shared.cancel(id: id)
        }
        call.resolve()
    }
}
