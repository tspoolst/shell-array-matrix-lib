#!/bin/bash
#[of]:case "$1" in
case "$1" in
  -k)
    ksh "$0" -s
    exit
    ;;
  -b)
    bash "$0" -s
    exit
    ;;
  -d)
    dash "$0" -s
    exit
    ;;
  -s)
    ;;
  *)
    exit
    ;;
esac
#[cf]
. ./matrix-library.sh

#[of]:arrayTest () {
arrayTest () {
  aset a_1 9
  
  aset a_0 1 2 3 4 5
  aset a_0[6] "6 6"
  
  set | grep -P '^a(=|_)'
  echo
#[c]  aunset a_0
#[c]  echo
  asize b a_0
  echo $b
  echo
  akeys - a_0
  for i in $(akeys - a_0);do echo "${i}";done
  aset a_0[2] "3 4"
#[c]  set | grep -P '^a(=|_)'
  aget - a_0[2]
  aget - a_0
#[c]  exit
  eval "for i in $(aget - a_0);do echo \"\${i}\";done"
  echo
  aget - a_1
  
  aget m a_1
  echo "${m}"

  echo
  aset a 1
  isarray a && echo yes || echo no
  isarray b && echo yes || echo no

#[c]  aset aa 2 5
#[c]  isarray aa && echo yes
#[c]  set | grep ^aa
#[c]  exit
  
  aunset aa
  aset aa 6 5 '4 "4' 3 "2 '2" 1
  
  areset aa $(($(asize - aa)))
  while astep b aa -1;do echo "${b}";done
  echo
#[c]  while astep b aa;do acurrent b aa;echo "${b}";done
  while astep b aa;do acurrent - aa;done
#[c]  
  echo
  areset aa 1
  acurrent - aa && echo yes || echo no
  echo
  set | grep ^aa

#[of]:  key sorting test
i=0
while [ $i -lt 100 ] ; do
  aset a[${i}] v$i
  : $((i=i+1))
done

asize - a
akeys - a
aget - a
#[cf]

  exit
}
#[cf]
#[of]:matrixTest() {
matrixTest() {
#[c]  set -xv
  mset aa 1 _ 1 2 3 4
#[c]  exit
  mset bb 2 0 _ 1 2 3 4
  mset bb 2 1 _ 5 6 7 8
  mset cc 4 0 0 0 _ a b c d
  mset cc 4 0 1 2 _ e f g h
  mset cc 4 0 2 1 _ i j k l
  mset cc 4 0 3 3 _ m n o p
  
  set | grep -P '^(aa|bb|cc|tt)(\[|=|_)'
#[c]  exit
  
#[c]  set -xv
#[c]  mget - aa 3
#[c]  mget tt cc 0 2 1
  mget tt cc 0 2 1 2
  echo "--${tt}--"
#[c]  exit
  
#[c]  set -xv
#[c]  aunset aa
#[c]  mset aa 1 0 a
#[c]  mset aa 1 _ a b c d e
#[c]  mset aa 2 0 _ a b c d e f
#[c]  mset aa 2 1 _ a b c d e f g h
  mset aa 4 0 0 0 _ a b c d e
  mset aa 4 0 0 1 _ a b c d
  mset aa 4 1 0 0 _ a b c
  mset aa 4 2 0 0 _ a b c d e f
  
#[c]    set | grep -P '^(aa|bb|cc|tt)(\[|=|_)'
  
  msize - aa 0 0 0
  msize - aa 0 0 1
  msize - aa 0 0
  msize - aa 0
  msize - aa


#[c]5
#[c]4
#[c]2
#[c]1
#[c]3


  mset aa 4 3 2 1 _ 1 2 3 '4 "4' "5' 5" 
  set | grep ^aa
  mget bb aa 3 2 1
  set | grep ^bb
  echo "${bb}"
  eval set -- "${bb}"
  echo "$# -- $@"
#[c]  set -xv
  mstep - aa 3 2 1
  mstep - aa 3 2 1
  mstep - aa 3 2 1
  mstep - aa 3 2 1
#[c]  set -xv
  mcurrent - aa 3 2 1
  
  mreset aa 3 2 1 2
  mcurrent - aa 3 2 1
  
  echo
  mreset aa 3 2 1
  while mstep - aa 3 2 1;do :;done
  echo
  mreset aa 3 2 1 $(msize - aa 3 2 1)
  while mstep - aa 3 2 1 -1;do :;done
  
  
  exit
  
#[c]  aunset aa
#[c]  aset aa 6 5 4 3 2 1
  set | grep ^aa
#[c]  
#[c]  mstep - aa
#[c]  mstep - aa
#[c]  mstep - aa
  
#[c]  while mstep - aa ; do :; done



  exit
}
#[cf]

#[c]arrayTest
#[c]matrixTest


