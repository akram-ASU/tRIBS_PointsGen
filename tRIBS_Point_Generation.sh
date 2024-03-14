#!/bin/bash

# Obtaining the directory of the script
script_dir=$(dirname "$(readlink -f "$0")")

#echo "Script directory: $script_dir"

# Specify the folder containing the input files
input_folder="$script_dir/Arc_Files"

# List input files with the desired extensions in the specified folder
input_files=$(ls "$input_folder"/*.pnt1 "$input_folder"/*.pnt2 "$input_folder"/*.lin1 "$input_folder"/*.lin2 2>/dev/null | xargs -n 1 basename )

# Check if any input files were found
if [ -z "$input_files" ]; then
    echo "No input files found in $input_folder"
    exit 1
fi

# Group input files by prefix
grouped_files=$(echo "$input_files" | sed 's/^\(.*\)\..*$/\1/' | sort | uniq)

# Print the list of grouped input files
echo "Grouped input files:"
echo "$grouped_files"

# Variable to store the last modified .in file
last_modified_file=""

# Loop through each grouped file
for file in $grouped_files
do
    # Specify the input file to modify
    input_file="$script_dir/tRIBS_Option_6.in"

    # Check if the input file exists
    if [ ! -f "$input_file" ]; then
        echo "Input file $input_file not found"
        exit 1
    fi

    # Create a new .in file with modified values
    new_in_file="$script_dir/${file}_modified.in"

    # Replace specific lines in the .in file and save as a new file
    sed "250s/.*/INPUTDATAFILE:    tMesh input file base name for Mesh files\nArc_Files\/$file/" "$input_file" | \
    sed "253s/.*/ARCINFOFILENAME:  tMesh input file base name Arc files\nArc_Files\/$file/" | \
    sed "259s/.*/POINTFILENAME:    tMesh input file name Points files\nPointFiles\/${file%net}.point/" > "$new_in_file"

    echo "Created modified .in file for $file: $new_in_file"
    
    #Run the executable tRIBS_2 with the modified .in file
    ./tRIBS_2 "$new_in_file"
    
    # Delete the temporary .in file
    rm "$new_in_file"
done