#!/system/bin/sh

font_sdk=$(getprop ro.build.version.sdk)
font_build_id=$(getprop ro.build.id)
case "$font_sdk" in
  37) ;;
  36)
    case "$font_build_id" in
      BP1*|BP2*|BP3*)
        abort "- Use the ProtonAOSP Font Pack module for your Android QPR version."
        ;;
    esac
    ;;
  *) abort "- This module supports Android 16 QPR2 and Android 17! Aborting." ;;
esac

# Preserve the stock font files for fallback
preserve_stock_font() {
  font_original=$1
  font_saved=$2
  font_previous="/data/adb/modules/protonaosp-font-pack/system/fonts/$font_saved"
  font_source="/system/fonts/$font_original"
  # Reuse stock fonts saved by the previous module
  if [ -f "$font_previous" ]; then
    font_source=$font_previous
  else
    font_magisk_path=$(magisk --path 2>/dev/null)
    if [ -n "$font_magisk_path" ] &&
       [ -f "$font_magisk_path/.magisk/mirror/system/fonts/$font_original" ]; then
      font_source="$font_magisk_path/.magisk/mirror/system/fonts/$font_original"
    fi
  fi
  # Check whether the font file is available
  [ -f "$font_source" ] || abort "- $font_original is missing from system assets! Aborting."
  cp -f "$font_source" "$MODPATH/system/fonts/$font_saved" ||
    abort "- Failed to preserve $font_original for fallback! Aborting."
}

preserve_stock_font Roboto-Regular.ttf RobotoFallback-VF.ttf
preserve_stock_font NotoSerif-Regular.ttf NotoSerifFallback-Regular.ttf
preserve_stock_font NotoSerif-Italic.ttf NotoSerifFallback-Italic.ttf
preserve_stock_font NotoSerif-Bold.ttf NotoSerifFallback-Bold.ttf
preserve_stock_font NotoSerif-BoldItalic.ttf NotoSerifFallback-BoldItalic.ttf
preserve_stock_font DroidSansMono.ttf DroidSansMonoFallback.ttf
preserve_stock_font CutiveMono.ttf CutiveMonoFallback.ttf

# Select the Pixel typography table for this Android version.
# QPR2 and Android 17 share default weights, but Android 17 adds bold slots.
if [ "$font_sdk" -eq 37 ]; then
  sed -i \
    -e 's/to="roboto-ui-400"/to="roboto-ui-400-700-1000"/g' \
    -e 's/to="roboto-ui-500"/to="roboto-ui-500-800-1000"/g' \
    -e 's/to="roboto-ui-600"/to="roboto-ui-600-900-1000"/g' \
    -e 's/to="roboto-ui-500-700"/to="roboto-ui-500-700-800-1000"/g' \
    "$MODPATH/system/product/etc/fonts_customization.xml" ||
    abort "- Failed to select the Android 17 font profiles! Aborting."
fi

# Set permissions
ui_print "- Setting permissions"
set_perm_recursive "$MODPATH" 0 0 0755 0644
