#!/bin/bash -e

mounted_dir=/opt/server
# SPT 4 layout stores profiles under SPT/user/profiles
profiles_dir=$mounted_dir/SPT/user/profiles
# Legacy SPT 3 path fallback
legacy_profiles_dir=$mounted_dir/user/profiles
timestamp=$(date +%Y%m%dT%H%M)
backup_dir=$mounted_dir/backups/profiles/$timestamp

is_server_dir_mounted() {
    local target
    target=$(findmnt -n -o TARGET --target "$mounted_dir" 2>/dev/null || true)
    [[ -n "$target" && "$target" != "/" ]]
}

if ! is_server_dir_mounted; then
    echo "Failed to run profile backup! Server directory not mounted!" >> /proc/1/fd/1
    exit 1
fi

if [[ -d "$profiles_dir" ]]; then
    source_profiles="$profiles_dir"
elif [[ -d "$legacy_profiles_dir" ]]; then
    source_profiles="$legacy_profiles_dir"
else
    echo "Failed to run profile backup! Profiles directory not found at $profiles_dir" >> /proc/1/fd/1
    exit 1
fi

echo "Backing up profiles from $source_profiles. Destination is $backup_dir" >> /proc/1/fd/1
mkdir -p "$backup_dir"
cp -r "$source_profiles" "$backup_dir"
echo "Backup complete." >> /proc/1/fd/1
