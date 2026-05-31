#!/usr/bin/env bash
t1=0; t2=0; act=1; mov=0; m1=0; m2=0; u1=0; u2=0
run=0; qui=0; win=0; tst=0; tot=0
sum() {
  printf "\033[2J\033[H"
  printf "Total moves: %d\nP1 used: %02d:%02d\nP2 used: %02d:%02d\n" "$mov" $((u1/60)) $((u1%60)) $((u2/60)) $((u2%60))
  [[ "$m1" -gt 0 ]] && printf "P1 avg: %s\n" "$(echo "scale=1;$u1/$m1"|bc)"
  [[ "$m2" -gt 0 ]] && printf "P2 avg: %s\n" "$(echo "scale=1;$u2/$m2"|bc)"
  [[ "$qui" -eq 1 ]] && printf "Game ended early\n" && return
  [[ "$win" -eq 1 ]] && printf "Winner: Player 1\n"
  [[ "$win" -eq 2 ]] && printf "Winner: Player 2\n"
}
end() {
  sec=$((SECONDS-tst))
  if [[ "$act" -eq 1 ]]; then u1=$((u1+sec)); else u2=$((u2+sec)); fi
  qui=1; run=0
}
trap end INT
printf "Starting minutes [5]: "; read -r min
min=${min:-5}; [[ "$min" =~ ^[0-9]+$ ]] && [[ "$min" -gt 0 ]] || min=5
tot=$((min*60)); t1=$tot; t2=$tot; act=1; mov=0; m1=0; m2=0
u1=0; u2=0; run=1; qui=0; win=0; tst=$SECONDS
while [[ "$run" -eq 1 ]]; do
  el=$((SECONDS-tst)); r1=$t1; r2=$t2
  if [[ "$act" -eq 1 ]]; then r1=$((t1-el)); else r2=$((t2-el)); fi
  [[ "$r1" -lt 0 ]] && r1=0; [[ "$r2" -lt 0 ]] && r2=0
  [[ "$act" -eq 1 && "$t1" -le "$el" ]] && win=2 && run=0
  [[ "$act" -eq 2 && "$t2" -le "$el" ]] && win=1 && run=0
  printf "\033[2J\033[H"
  [[ "$act" -eq 1 ]] && printf "\033[32m" || printf "\033[2m"
  printf "Player 1: %02d:%02d\n\033[0m" $((r1/60)) $((r1%60))
  [[ "$act" -eq 2 ]] && printf "\033[32m" || printf "\033[2m"
  printf "Player 2: %02d:%02d\n\033[0mMove: %d\nPress ENTER to end your turn, q+ENTER to quit\n" $((r2/60)) $((r2%60)) $((mov+1))
  if [[ "$run" -eq 0 ]]; then
    if [[ "$act" -eq 1 ]]; then u1=$((u1+el)); m1=$((m1+1)); t1=0
    else u2=$((u2+el)); m2=$((m2+1)); t2=0; fi
    mov=$((mov+1)); break; fi
  read -t 1 -r inp; rc=$?
  [[ "$run" -eq 0 ]] && break
  if [[ "$rc" -eq 0 ]]; then
    sec=$((SECONDS-tst))
    if [[ "$inp" == "q" ]]; then
      if [[ "$act" -eq 1 ]]; then u1=$((u1+sec)); else u2=$((u2+sec)); fi
      qui=1; run=0
    else
      mov=$((mov+1))
      if [[ "$act" -eq 1 ]]; then t1=$((t1-sec)); u1=$((u1+sec)); m1=$((m1+1)); act=2
      else t2=$((t2-sec)); u2=$((u2+sec)); m2=$((m2+1)); act=1; fi
      tst=$SECONDS; fi; fi; done
sum
