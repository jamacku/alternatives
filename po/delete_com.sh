#!/bin/bash

## Delete blocks in *.po files for source code, that is no longer present

for file in *.po*;
do
  awk '/^.*(#: ..\/chkconfig.c:|#: ..\/ntsysv.c:|#: ..\/leveldb.c:).*$/{while(getline && $0 != ""){}}1' "${file}" > "${file}".tmp
  cat -s "${file}".tmp > "${file}"
  rm "${file}".tmp
done
