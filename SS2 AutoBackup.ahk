; You can combine this script with 7z for saving tons of disk space, examples in my GitHub (https://github.com/elModo7)
version := "0.1"
#NoEnv
#Include <aboutScreen>
#Include <WatchFolder>
#SingleInstance Force
#Persistent
SetBatchLines, -1
fileQueue := []
configFile := "config.ini"
createConfigIfNotExist(configFile)
IniRead, watchedFolder, %configFile%, configuration, watchedFolder, E:\steamlibrary\steamapps\common\SS2\save_0
IniRead, backupDelay, %configFile%, configuration, backupDelay, 3000
backupsFolder := A_ScriptDir "\backups"
subTree := 0 ; Non recursive
watch := calculateWatchIdentifier(0, 1, 0, 0, 1, 0, 0, 0) ; Write & Creation -> (Files, Folders, Attr, Size, Write, Access, Creation, Security)

; Tray
Menu, Tray, NoStandard
Menu, Tray, Tip, SS2 auto-backup tool v%version%
Menu, Tray, Add, Open backups folder, openBackupsFolder
Menu, Tray, Add, Open Save folder, openSaveFolder
Menu, Tray, Add, Edit config, openEditConfig
Menu, Tray, Add, About, showAbout
Menu, Tray, Add,
Menu, Tray, Add, Exit, closeScript

If !WatchFolder(watchedFolder, "watchFolderEvent", subTree, watch) {
   MsgBox, 0, Error, Call of WatchFolder() failed!
   Return
}
return

watchFolderEvent(Folder, Changes) {
   global fileQueue, backupDelay
   Static Actions := ["1 (added)", "2 (removed)", "3 (modified)", "4 (renamed)"]
   For Each, Change In Changes
   {
      ; WARNING! Make sure you don't monitor the same folder we are saving the log files!
      if (!hasVal(fileQueue, Change.Name)) ; Prevent duplicates
         fileQueue.push(Change.Name)
   }
   SetTimer, processQueue, % backupDelay ; Wait x ms since the last file was changed (multiple files can change at once in a folder, we need a cooldown)
}

processQueue() {
   SetTimer, processQueue, Off
   global fileQueue, backupsFolder, watchedFolder
   for fileKey, fileQ in fileQueue
   {
      SplitPath, % fileQ, fileQFileName,, fileQFileExtension, fileQFileNameNoExt
      newFolderPath := backupsFolder "\" A_YYYY A_MM A_DD A_Hour A_Min A_Sec A_Msec "_save_0"
      FileCreateDir, % newFolderPath
      FileCopyDir, % watchedFolder, % newFolderPath, 1
      fileQueue := "" ; This is really bad code adapted from a queue system I had on another script, may change from queue to delayedTask in a future update
      fileQueue := []
      break
   }
}

showFileQueue(fileQueue) {
   fileQueueTxt := ""
   for fileKey, fileQ in fileQueue
      fileQueueTxt .= fileQ "`n"
   ToolTip % fileQueueTxt
}

showAbout() {
	global version
	showAboutScreen("System Shock 2 auto-backup tool v" version, "A tool to quickly auto-backup your SS2 saved games. Meant to avoid multiplayer save data corruption and desyncs by keeping a save history.")
}

openBackupsFolder:
   Run, % backupsFolder
return

openSaveFolder:
   Run, % watchedFolder
return

openEditConfig:
   Run, % configFile
return

aboutGuiEscape:
aboutGuiClose:
	AboutGuiClose()
return

createConfigIfNotExist(configFile) {
   if (!FileExist(configFile)) {
      confTxt :=
      (
      "[configuration]
watchedFolder=E:\steamlibrary\steamapps\common\SS2\save_0
backupDelay=3000"
      )
      FileAppend, %confTxt%, %configFile%
   }
}

closeScript:
   ExitApp