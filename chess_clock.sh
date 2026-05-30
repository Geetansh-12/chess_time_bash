#!/usr/bin/env bash
t1=0; t2=0; act=1; mov=0; m1=0; m2=0; u1=0; u2=0
run=0; qui=0; win=0; tst=0; tot=0
printf "Starting minutes [5]: "; read -r min
min=${min:-5}; [[ "$min" =~ ^[0-9]+$ ]] && [[ "$min" -gt 0 ]] || min=5
tot=$((min*60)); t1=$tot; t2=$tot; act=1; tst=$SECONDS
