#!/usr/bin/env bash
t1=0; t2=0; act=1; mov=0; m1=0; m2=0; u1=0; u2=0
run=0; qui=0; win=0; tst=0; tot=0
printf "Starting minutes [5]: "; read -r min
min=${min:-5}; [[ "$min" =~ ^[0-9]+$ ]] && [[ "$min" -gt 0 ]] || min=5
tot=$((min*60)); t1=$tot; t2=$tot; act=1; mov=0; tst=$SECONDS
run=1
while [[ "$run" -eq 1 ]]; do
  el=$((SECONDS-tst)); r1=$t1; r2=$t2
  if [[ "$act" -eq 1 ]]; then r1=$((t1-el)); else r2=$((t2-el)); fi
  [[ "$r1" -lt 0 ]] && r1=0; [[ "$r2" -lt 0 ]] && r2=0
  printf "\033[2J\033[H"
  [[ "$act" -eq 1 ]] && printf "\033[32m" || printf "\033[2m"
  printf "Player 1: %02d:%02d\n\033[0m" $((r1/60)) $((r1%60))
  [[ "$act" -eq 2 ]] && printf "\033[32m" || printf "\033[2m"
  printf "Player 2: %02d:%02d\n\033[0mMove: %d\n" $((r2/60)) $((r2%60)) $((mov+1))
  read -t 1 -r inp
done
