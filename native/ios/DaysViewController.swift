import UIKit
import Capacitor

// Meldet die app-eigenen Plugins an. Der Workflow setzt diese Klasse im Main.storyboard statt CAPBridgeViewController.
class DaysViewController: CAPBridgeViewController {
    override open func capacitorDidLoad() {
        bridge?.registerPluginInstance(DaysAlarmPlugin())
    }
}
