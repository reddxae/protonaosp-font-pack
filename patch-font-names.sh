#!/usr/bin/env bash

ttx *.ttf

function replace_name() {
  cur_name=$1
  tgt_name=$2
  shift
  shift
  echo "$cur_name -> $tgt_name"
  sed -i "s/\(<FullName value=.\)$cur_name /\1$tgt_name /" "$@"
  sed -i "s/\(<FamilyName value=.\)$cur_name/\1$tgt_name/" "$@"
  sed -i "s/^      $cur_name$/      $tgt_name/" "$@"
  sed -i "s/^      $cur_name \([^UiP].*\)$/      $tgt_name \1/" "$@"
}

replace_name "Inter Variable" "Roboto" Roboto-*.ttx
replace_name "Source Serif 4 Display" "Noto Serif" NotoSerif-*.ttx
replace_name "Fira Code" "Cutive Mono" CutiveMono.ttx
replace_name "Fira Code" "Droid Sans Mono" DroidSansMono.ttx

rm *.ttf
ttx *.ttx
rm *.ttx
