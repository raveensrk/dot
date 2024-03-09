#!/bin/bash

# set -x

all_lines="/tmp/all_lines_$$.txt"
all_lines_copy="/tmp/all_lines_copy_$$.txt"
all_lines_without_the_match="/tmp/all_lines_without_the_match_$$.txt"
duplicates="/tmp/duplicates_$$.txt"

rg -L -n --no-heading -. . --ignore-file "$HOME/.scripts/.ignore" > "$all_lines"

cat "$all_lines" > "$all_lines_copy"

head "$all_lines"

while read -r line <&3; do
    file1_file_name=$(echo "$line" | awk -F : '{print $1}')
    file1_line_no=$(echo "$line" | awk -F : '{print $2}')
    file1_line=$(echo "$line" | awk -F : '{print $3}')
    echo -e "${YELLOW}-----${NC}" 
    echo -e "${YELLOW}FILE1${NC}" 
    echo -e "${YELLOW}-----${NC}" 
    echo "$file1_line"
    echo "$file1_line_no"
    echo "$file1_file_name"

    grep -w -v "$line" "$all_lines_copy" | tee "$all_lines_without_the_match"

    # echo -e "${YELLOW}All lines without match...${NC}" 
    # head "$all_lines_without_the_match"
    # exit

    grep -w "$file1_line" "$all_lines_without_the_match" | tee "$duplicates"

    while read -r line2 <&4; do
        file2_file_name=$(echo "$line2" | awk -F : '{print $1}')
        file2_line_no=$(echo "$line2" | awk -F : '{print $2}')
        file2_line=$(echo "$line2" | awk -F : '{print $3}')
        echo -e "${YELLOW}-----${NC}" 
        echo -e "${YELLOW}FILE2${NC}" 
        echo -e "${YELLOW}-----${NC}" 
        echo "$file2_line"
        echo "$file2_line_no"
        echo "$file2_file_name"

        vim -O "$file1_file_name" +"$file1_line_no" "$file2_file_name" +"$file2_line_no" -c ":wincmd l | $file2_line_no | wincmd h | $file1_line_no"
        break 2
    done 4< "$duplicates"

done 3< "$all_lines"

# uniq --all-repeated "$all_lines"

rm -f "$all_lines"
rm -f "$all_lines_copy"
rm -f "$all_lines_without_the_match"
rm -f "$duplicates"

