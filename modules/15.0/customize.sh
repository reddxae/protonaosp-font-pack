#!/system/bin/sh

font_sdk=$(getprop ro.build.version.sdk)
[ "$font_sdk" = 35 ] || abort "- This module supports Android 15 only! Aborting."

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

. "$MODPATH/font-utils.sh" || abort "- Failed to load Android 15 font helpers! Aborting."

# Check whether the font file is available
font_has_fvar "$MODPATH/system/fonts/RobotoFallback-VF.ttf" ||
  abort "- This Android 15 configuration requires variable stock Roboto! Aborting."

# Adjust CJK entries when no fvar table is present
if ! font_has_fvar /system/fonts/NotoSansCJK-Regular.ttc; then
  adapt_static_cjk "$MODPATH/system/etc/fonts.xml" ||
    abort "- Failed to adapt static CJK entries! Aborting."
  adapt_static_cjk "$MODPATH/system/etc/font_fallback.xml" ||
    abort "- Failed to adapt static CJK entries! Aborting."
  ui_print "- Adapted CJK entries for the installed static font"
fi

# Clean up module directory
rm -f "$MODPATH/static-cjk.awk" "$MODPATH/font-utils.sh"

# Adapt independently versioned Noto font assets to the installed ROM.
# Noto releases can change independently of the Android SDK/QPR version.
# Read the actual SFNT fvar axis instead of assuming one Khmer font release.
font_compat_uint() {
  font_compat_number=0
  font_compat_bytes=$(od -An -tu1 -j "$2" -N "$3" "$1" 2>/dev/null) || return 1
  set -- $font_compat_bytes
  for font_compat_byte do
    font_compat_number=$((font_compat_number * 256 + font_compat_byte))
  done
  printf '%s\n' "$font_compat_number"
}

font_compat_weight_min() {
  [ -f "$1" ] || return 1
  font_compat_count=$(font_compat_uint "$1" 4 2) || return 1
  [ "$font_compat_count" -gt 0 ] && [ "$font_compat_count" -le 512 ] || return 1
  font_compat_fvar=$(od -An -tu1 -j 12 -N "$((font_compat_count * 16))" "$1" |
    awk '{ for (i = 1; i <= NF; i++) {
      b[n % 16] = $i
      if (n % 16 == 15 && b[0] == 102 && b[1] == 118 && b[2] == 97 && b[3] == 114)
        print ((b[8] * 256 + b[9]) * 256 + b[10]) * 256 + b[11]
      n++
    }}')
  [ -n "$font_compat_fvar" ] || return 1
  font_compat_offset=$(font_compat_uint "$1" "$((font_compat_fvar + 4))" 2) || return 1
  font_compat_axes=$(font_compat_uint "$1" "$((font_compat_fvar + 8))" 2) || return 1
  font_compat_size=$(font_compat_uint "$1" "$((font_compat_fvar + 10))" 2) || return 1
  [ "$font_compat_size" -ge 20 ] && [ "$font_compat_axes" -le 64 ] || return 1
  font_compat_index=0
  while [ "$font_compat_index" -lt "$font_compat_axes" ]; do
    font_compat_axis=$((font_compat_fvar + font_compat_offset + font_compat_index * font_compat_size))
    font_compat_tag=$(font_compat_uint "$1" "$font_compat_axis" 4) || return 1
    if [ "$font_compat_tag" = 2003265652 ]; then # 'wght'
      font_compat_min=$(font_compat_uint "$1" "$((font_compat_axis + 4))" 4) || return 1
      printf '%s\n' "$((font_compat_min / 65536))"
      return 0
    fi
    font_compat_index=$((font_compat_index + 1))
  done
  return 1
}

adapt_font_config() {
  font_compat_xml=$1
  font_compat_khmer_min=$(font_compat_weight_min /system/fonts/NotoSansKhmer-VF.ttf)
  case "$font_compat_khmer_min" in
    26|100)
      awk -v khmer_min="$font_compat_khmer_min" '
        BEGIN { split("26 39 58 90 108 128 151 169 190", old, " ") }
        /<font([[:space:]]|>)/ {
          if (match($0, /weight="[0-9]+"/))
            weight = substr($0, RSTART + 8, RLENGTH - 9)
          khmer = 0
        }
        /NotoSansKhmer-VF.ttf/ { khmer = 1 }
        khmer && /<axis tag="wght"/ {
          value = khmer_min == 26 ? old[weight / 100] : weight
          if (value != "") sub(/stylevalue="[^"]*"/, "stylevalue=\"" value "\"")
        }
        { print }
        /<\/font>/ { khmer = 0 }
      ' "$font_compat_xml" > "$font_compat_xml.tmp" || return 1
      mv "$font_compat_xml.tmp" "$font_compat_xml" || return 1
      ;;
  esac
  if [ -f /system/fonts/NotoSerifKhmer-Regular.ttf ]; then
    sed -i 's/NotoSerifKhmer-Regular.otf/NotoSerifKhmer-Regular.ttf/g' "$font_compat_xml" || return 1
  elif [ -f /system/fonts/NotoSerifKhmer-Regular.otf ]; then
    sed -i 's/NotoSerifKhmer-Regular.ttf/NotoSerifKhmer-Regular.otf/g' "$font_compat_xml" || return 1
  fi
}

adapt_font_config "$MODPATH/system/etc/fonts.xml" ||
  abort "- Failed to adapt legacy font configuration! Aborting."
adapt_font_config "$MODPATH/system/etc/font_fallback.xml" ||
  abort "- Failed to adapt system font configuration! Aborting."

# Set permissions
ui_print "- Setting permissions"
set_perm_recursive "$MODPATH" 0 0 0755 0644
