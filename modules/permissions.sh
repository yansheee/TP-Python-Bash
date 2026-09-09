#!/bin/bash

passwd=$(stat -c '%a %U:%G' /etc/passwd)

shadow=$(stat -c '%a %U:%G' /etc/shadow)

group=$(stat -c '%a %U:%G' /etc/group)

world_writable=$(find /etc -type f -perm -002 2>/dev/null)

declare -A permissions

permissions["passwd"]="$passwd"
permissions["shadow"]="$shadow"
permissions["group"]="$group"
permissions["world_writable"]="$world_writable"

echo "${permissions[@]}"