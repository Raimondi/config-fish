function get_wallpaper_from_space
  set -l id
  if test -z "$argv"
    set id 3
  else
    set id (math argv[1] + 2)
  end
  #sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "SELECT data.value FROM preferences INNER JOIN data on preferences.key=16 and preferences.picture_id=$id and preferences.data_id=data.ROWID"
  sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "SELECT data.value FROM preferences INNER JOIN data on preferences.key=16 and preferences.picture_id=$id"
end
