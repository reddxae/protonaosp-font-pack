# Convert only Noto Sans CJK entries; retain every other font family unchanged.
function emit_font(    converted) {
    if (index(font_xml, "NotoSansCJK-Regular.ttc")) {
        # The legacy static font has a single regular instance
        if (font_xml !~ /weight="400"/) {
            font_xml = ""
            return
        }
        converted = font_xml
        gsub(/[[:blank:]]+supportedAxes="[^"]*"/, "", converted)
        gsub(/[[:blank:]]*<axis[^>]*tag="wght"[^>]*\/>[[:blank:]]*\n/, "", converted)
        gsub(/NotoSansCJKJP-Regular/, "NotoSansCJKjp-Regular", converted)
        printf "%s", converted
    } else {
        printf "%s", font_xml
    }
    font_xml = ""
}

{
    if (in_font) {
        font_xml = font_xml $0 "\n"
    } else if ($0 ~ /^[[:blank:]]*<font([[:blank:]]|>)/) {
        in_font = 1
        font_xml = $0 "\n"
    } else {
        print
    }
    if (in_font && index($0, "</font>")) {
        emit_font()
        in_font = 0
    }
}

END {
    if (in_font) {
        print "Incomplete font element" > "/dev/stderr"
        exit 1
    }
}
