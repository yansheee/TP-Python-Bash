import subprocess

passwd = subprocess.getoutput(
    "stat -c '%a %U:%G' /etc/passwd"
)

shadow = subprocess.getoutput(
    "stat -c '%a %U:%G' /etc/shadow"
)

group = subprocess.getoutput(
    "stat -c '%a %U:%G' /etc/group"
)

world_writable = subprocess.getoutput(
    "find /etc -type f -perm -002 2>/dev/null"
)

permissions = {
    "passwd": passwd,
    "shadow": shadow,
    "group": group,
    "world_writable": world_writable,
}

print(permissions)