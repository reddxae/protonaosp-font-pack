#!/system/bin/sh

adapt_static_cjk() {
  awk -f "$MODPATH/static-cjk.awk" "$1" > "$1.tmp" || return 1
  mv "$1.tmp" "$1"
}

read_font_uint() {
  font_uint=0
  font_bytes=$(od -An -tu1 -j "$2" -N "$3" "$1" 2>/dev/null) || return 1
  set -- $font_bytes
  for font_byte do
    font_uint=$((font_uint * 256 + font_byte))
  done
  printf '%s\n' "$font_uint"
}

# Inspect the first face's table directory, rather than relying on ROM/build names
font_has_fvar() {
  [ -f "$1" ] || return 1
  font_magic=$(read_font_uint "$1" 0 4) || return 1
  font_face_offset=0
  if [ "$font_magic" = 1953784678 ]; then
    # 'ttcf': the first face's absolute offset follows the TTC header.
    font_face_offset=$(read_font_uint "$1" 12 4) || return 1
  fi
  font_table_count=$(read_font_uint "$1" "$((font_face_offset + 4))" 2) || return 1
  [ "$font_table_count" -gt 0 ] && [ "$font_table_count" -le 512 ] || return 1
  od -An -tu1 -j "$((font_face_offset + 12))" -N "$((font_table_count * 16))" "$1" 2>/dev/null |
    awk '
      { for (i = 1; i <= NF; i++) {
          bytes[position % 16] = $i;
          if (position % 16 == 3 && bytes[0] == 102 && bytes[1] == 118 &&
              bytes[2] == 97 && bytes[3] == 114) found = 1;
          position++;
      }}
      END { exit !found; }
    '
}
