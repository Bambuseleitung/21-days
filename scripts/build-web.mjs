// Kopiert die Weboberfläche nach www/, das Capacitor in die Android- und iOS-App packt.
import { cpSync, mkdirSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const out = join(root, "www");
rmSync(out, { recursive: true, force: true });
mkdirSync(out, { recursive: true });
// sw.js bleibt draußen: In der App liegen alle Dateien ohnehin im Paket.
for (const f of ["index.html", "config.js", "manifest.webmanifest", "icons", "fonts", "vendor"]) cpSync(join(root, f), join(out, f), { recursive: true });
console.log("www/ ist fertig");
