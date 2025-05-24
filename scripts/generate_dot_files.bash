#!/bin/bash

# List of configuration files to check
config_files=(".bash_profile" ".bashrc" ".common_profile" ".common_rc" ".zprofile" ".zshrc" )
config_files_fullpath=()
for file in "${config_files[@]}"; do
   full_filename=$(readlink -f "$file")
   config_files_fullpath+=("$full_filename")
done

# Output file for the dot graph
output_file="config_dependencies.dot"

# Start the dot file
echo "digraph G {" > "$output_file"

# Loop over each file and check for sourced files
for file in "${config_files[@]}"; do
   if [ -f "$file" ]; then
      echo "Processing $file..."

      # Search for 'source' or '.' commands in each config file
      grep -E '^\s*(source|\.|eval)\s' "$file" | while read -r line; do
         # Extract the filename being sourced (simplified)
         source_file=$(echo "$line" | sed -E 's/^\s*(source|\.|eval)\s+(.+)$/\2/')
         source_file=$(echo "$source_file" | tr -d '"')  # remove quotes if present
         source_file="${source_file#. }" # remove any `. `
         source_file="${source_file/\$HOME/$HOME}" # evaluate $HOME
         source_file=$(readlink -f "$source_file")
         source_file_short="${source_file#*/.config/}"

         # If the source file is in the list, create an edge
         if [[ " ${config_files_fullpath[@]} " =~ " $source_file " ]]; then
            echo "    \"$file\" -> \"$source_file_short\";" >> "$output_file"
         fi
      done
   fi
done

# Close the dot file
echo "}" >> "$output_file"

echo "Graph generated in $output_file"
