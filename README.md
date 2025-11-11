# System Shock 2 Auto-Backup Tool

Small, helper that **watches your System Shock 2 save folder** and, whenever a file is written (you saved the game, or the game auto saved), **copies that entire save directory to a timestamped backup**. Designed to protect against save corruption or accidental desyncs by keeping a rolling history of `save_0` (you can configure which save you want to auto-backup, you can also schedule automatic save backups).

> Tip: You can pair backups with 7-Zip to drastically reduce disk usage (see “Optional: compress backups” below).

---

## ✨ Features

- Watches a folder for file writes (via `WatchFolder` library)
- Debounces rapid changes with a configurable delay, then **copies the full save directory**
- Saves backups to `./backups/YYYYMMDDHHMMSSmmm_save_0`
- Tiny codebase, quick & easily extensible

---

## 🧰 Requirements

- **Windows 7+**
- **AutoHotkey L v1.1** (not if you download executable from Releases)
- Works with any System Shock 2 release

---

## 📦 Installation

1. Place `SS2 AutoBackup.ahk` anywhere (e.g., next to your game).
2. (Optional but recommended) Create a `config.ini` in the same folder as the script—see below.
3. Double-click the script to run it (or compile to EXE with Ahk2Exe if you prefer, you can also download latest version from releases).
4. You’ll see a tray icon; backups will appear under `./backups`.

---

## ⚙️ Configuration

The script reads `config.ini` from the script directory. If it doesn’t exist, sensible defaults are used.

**`config.ini` example:**

```ini
[configuration]
; Folder to watch (default: E:\steamlibrary\steamapps\common\SS2\save_0)
watchedFolder=E:\steamlibrary\steamapps\common\SS2\save_0

; Debounce time in milliseconds before performing a backup (default: 3000)
backupDelay=3000
```

**What happens:**

- On any file **write** inside `watchedFolder`, the script waits `backupDelay` ms.
- It then creates a folder like:
  
  ```
  ./backups/20251111_153045123_save_0
  ```
  
  and copies the **entire** `watchedFolder` into it (recursive).

> ⚠️ Don’t point `watchedFolder` to the backups directory itself.

---

## ▶️ Usage

- Launch the script; keep it running while you play.
- When the game writes to `save_0`, the script:
  1. Queues the change
  2. Waits `backupDelay` (to coalesce bursts)
  3. Copies the whole save folder to a timestamped backup

**Tray menu:**

- **Open Backups Folder**
- **Exit** — quit the script

---

## 🔄 Restoring a backup

1. **Close the game.**
2. Pick a backup under `./backups/YYYYMMDDHHMMSSmmm_save_0`.
3. Copy its contents back to your `watchedFolder` (e.g., `.../SS2/save_0`), overwriting when prompted.

---

## 🧪 How it works (quick tour)

- `WatchFolder()` subscribes to change events (write/modify).
- `watchFolderEvent()` collects changed file names, de-duplicates, and starts a timer.
- `processQueue()` fires after `backupDelay`, creates the timestamped folder, then `FileCopyDir` clones the entire save tree.
- A tiny `ToolTip` helper lists the files that triggered the backup (handy for debugging).
- About window provided by `aboutScreen`.

Default watch flags come from:

```ahk
watch := calculateWatchIdentifier(0, 1, 0, 0, 1, 0, 0, 0) ; Files + Write
; subTree := 0 (non-recursive watcher), but the COPY itself is recursive.
```

---

## 🧹 Housekeeping & limits

- **Non-recursive watcher**: the event hook is non-recursive, but backups copy the whole folder tree. If your game writes only at the root, that’s fine; if it writes deeper, consider switching `subTree` to `1` in the script.
- **One backup per burst**: rapid writes collapse into one backup per debounce window.
- **Disk usage**: full copies can grow; see compression below.

---

## 🗜️ Optional: compress backups (7-Zip)

If you have `7z.exe` in PATH, you can compress each freshly created backup. For example, after `FileCopyDir`:

```ahk
; After creating newFolderPath
RunWait, %ComSpec% /c 7z a -t7z -mx=9 "%newFolderPath%.7z" "%newFolderPath%\*", , Hide
; Optionally delete the uncompressed folder after verifying the archive:
; FileRemoveDir, % newFolderPath, 1
```

You can also add a simple retention policy (e.g., keep last N archives) if desired.

---

## 🪟 Start with Windows (optional)

- Create a shortcut to the script (or compiled EXE).
- Place it in `shell:startup` (Win+R → `shell:startup`) to launch on login.

---

## 🐛 Troubleshooting

- **“Call of WatchFolder() failed!”**  
  Ensure the `WatchFolder` library is installed in an include path AutoHotkey can find.
- **No backups created**  
  Double-check `watchedFolder` in `config.ini` and that the game is writing there.
- **High disk usage**  
  Increase `backupDelay` or enable 7-Zip compression / add retention.

---

## 📜 License

Add a `LICENSE` file (MIT is a good default if you’re unsure). Until then, treat this as “all rights reserved.”

---

## 🙌 Credits

- **WatchFolder** — file system watcher
- **aboutScreen** — minimal About window

---

## 🗺️ Roadmap (nice-to-haves)

- Configurable **backup folder** path
- **Recursive** watch toggle in `config.ini`
- Built-in **compression** & **retention** settings
- Tray shortcuts: **Open backups**, **Open watched folder**, **Open config**

---

## 📁 Repository layout (suggested)

```
SS2-AutoBackup/
├─ SS2 AutoBackup.ahk
├─ config.ini            ; optional, created by you
├─ backups/              ; created at runtime
└─ Lib/                  ; optional local copies of WatchFolder/aboutScreen
```
