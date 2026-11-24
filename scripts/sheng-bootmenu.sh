#!/bin/bash
# Generate the U-Boot menu from the Extlinux configuration Guix installed.
set -euo pipefail
repair=false
if [[ ${1:-} == --repair ]]; then
    repair=true
    shift
fi
root=${1:-/}
config=${root%/}/boot/extlinux/extlinux.conf
menu=${root%/}/boot/sheng-bootmenu.env
tmp=$(mktemp "$menu.XXXXXX")
config_tmp=
trap 'rm -f -- "$tmp"; if [[ -n $config_tmp ]]; then rm -f -- "$config_tmp"; fi' EXIT

LC_ALL=C awk '
$1 == "DEFAULT" { default_label = $2 }
$1 == "LABEL" {
    label = $2
    if (label !~ /^[[:alnum:]_-]+$/ || seen[label]++) exit 1
    labels[++count] = label
}
$1 == "MENU" && $2 == "LABEL" && label != "" {
    sub(/^[[:space:]]*MENU[[:space:]]+LABEL[[:space:]]+/, "")
    gsub(/[^ -~]|=/, " ")
    titles[label] = $0
}
END {
    if (!seen[default_label]) exit 1
    title = titles[default_label]
    if (title == "") title = "Boot Guix"
    printf "bootmenu_0=%s=setenv pxe_label_override; run bootlinux\n", title
    index_in_menu = 1
    for (i = 1; i <= count; i++) {
        label = labels[i]
        if (label == default_label) continue
        title = titles[label]
        if (title == "") title = label
        printf "bootmenu_%d=%s=setenv pxe_label_override %s; run bootlinux\n",
            index_in_menu++, title, label
    }
    printf "bootmenu_%d=Reboot to fastboot (bootloader)=run rebootfastboot\n", index_in_menu
}
' "$config" > "$tmp"
chmod 0644 "$tmp"
if "$repair"; then
    config_tmp=$(mktemp "$config.XXXXXX")
    awk '
        BEGIN { print "PROMPT 0" }
        toupper($1) != "PROMPT" { print }
    ' "$config" > "$config_tmp"
    chmod --reference="$config" "$config_tmp"
fi
mv -f -- "$tmp" "$menu"
if "$repair"; then
    mv -f -- "$config_tmp" "$config"
fi
