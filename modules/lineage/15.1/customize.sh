#!/system/bin/sh

# Set permissions

ui_print "- Setting permissions"
set_perm_recursive "$MODPATH" 0 0 0755 0644
