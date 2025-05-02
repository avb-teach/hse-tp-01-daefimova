#!/bin/bash

if [ $# -lt 2 ]; then
    exit 1
fi

input_dir="$1"
output_dir="$2"
maxd=""

shift 2

if [ "$1" = "--max_depth" ] && [[ "$2" =~ ^[0-9]+$ ]]; then
    maxd="$2"
fi

mkdir -p "$output_dir"

process_file() {
    local src="$1"
    local new_rel_path="$2"
    local name="$3"
    
    local base="${name%.*}"
    local ext=""
    [ "$name" != "$base" ] && ext=".${name##*.}"
    
    local dest_dir="$output_dir"
    if [ -n "$new_rel_path" ]; then
        dest_dir="$output_dir/$new_rel_path"
        mkdir -p "$dest_dir"
    fi
    
    local counter=1
    local dest_name="$name"
    local target_file="$dest_dir/$dest_name"
    
    while [ -e "$target_file" ]; do
        dest_name="${base}${counter}${ext}"
        target_file="$dest_dir/$dest_name"
        ((counter++))
    done
    
    cp "$src" "$target_file"
}

if [ -n "$maxd" ]; then
    find "$input_dir" -type f | while read f; do
        rel_path="${f#$input_dir/}"
        rel_path=$(dirname "$rel_path")
        
        IFS='/' read -ra parts <<< "$rel_path"
        keep_components=$((maxd - 1))
        
        if [ ${#parts[@]} -gt $keep_components ]; then
            new_rel_path=$(IFS='/'; echo "${parts[*]: -$keep_components}")
        else
            new_rel_path="$rel_path"
        fi
        
        process_file "$f" "$new_rel_path" "$(basename "$f")"
    done
else
    find "$input_dir" -type f | while read f; do
        process_file "$f" "" "$(basename "$f")"
    done
fi