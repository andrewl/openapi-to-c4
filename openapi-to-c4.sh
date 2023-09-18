#!/bin/bash

# Check if no parameters are provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <URL1> <URL2> ..."
  exit 1
fi

# An array to store all the component ids, so we don't end up duplicating them
componentIds=()

# Function to check if we already have the component
doesComponentExist() {
    local id="$1"
    for componentId in "${componentIds[@]}"; do
        if [ "$id" == "$componentId" ]; then
            return 1 # Field exists in the array
        fi
    done
    return 0 # Field not found in the array
}

# Function to handle OpenAPI specs
handle_openapi() {

  # Generate a unique temporary filename
  temp_file="$temp_dir/$(basename "$url")"

  # Download the file using curl (you can use wget if preferred)
  curl -s -o "$temp_file" $1

  # Check if the download was successful
  if [ $? -ne 0 ]; then
    echo "Error downloading: $url"
  fi

  # Extract the title of API and create a container boundary
  jq -r '.info.title as $title | "  System_Boundary(" + (.info.title | gsub("[^a-zA-Z0-9]+"; "_") | ascii_downcase) + ", \"" + $title + "\") {"' $temp_file

  # Extract each endpoint and add them as components within the container
  jq -r '.paths | to_entries[] | .key as $path | .value | to_entries[] | "    Component(" + ($path | gsub("[^a-zA-Z0-9]+"; "_") | ascii_downcase) + "_" + .key + ", \"" + .key + " " + $path + "\", \"" + .value.description + "\")"' $temp_file

  # Extract the component ids and append to the componentIds array
  output=$(jq -r '.paths | to_entries[] | .key as $path | .value | to_entries[] | ($path | gsub("[^a-zA-Z0-9]+"; "_") | ascii_downcase) + "_" + .key' "$temp_file")
  IFS=$'\n' read -d '' -r -a array <<< "$output"

  for element in "${array[@]}"; do
    componentIds+=("$element")
  done

  # Close the container boundary
  echo "}"
}

# Function to handle other URLs - consider these to be csv files containing relationships
handle_rels() {

  # If we don't already have the component, then add it
  # Process each line in the file and check if the field exists in the array
  while IFS= read -r line; do
    newComponentId=$(echo "$line" | cut -d "," -f 1) 

    doesComponentExist "$newComponentId"
    exists=$?

    if [ "$exists" -eq 0 ]; then
        echo "$newComponentId" | sed -e 's/[^a-zA-Z0-9,]/_/g' | sort | uniq | sed 's/\(.*\)/Component(\1,"\1")/g'
    fi
  done < $1

  #cut -d "," -f 1 $1 | sed -e 's/[^a-zA-Z0-9,]/_/g' | sort | uniq | sed 's/\(.*\)/Component(\1,"\1")/g'
  cat $1 | sed -e 's/\r//g' | sed -e 's/[^a-zA-Z0-9,]/_/g' |  sed 's/\([^,]*\),\([^,]*\)/Rel(\1,\2,"calls")/g'
}

cat <<EOF
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Component.puml

HIDE_STEREOTYPE()
LAYOUT_TOP_DOWN()

title $TITLE

Enterprise_Boundary(enterprise, "$ENTERPRISE") {
EOF

# Create a temporary directory
temp_dir=$(mktemp -d)

# Iterate over the script's parameters. Assume anything starting with https is an OpenAPI spec
# anything not starting with https is a csv of relationships between components
for url in "$@"; do
  if [[ $url == https://* ]]; then
    handle_openapi "$url"
  else
    handle_rels "$url"
  fi
done

# Clean up: Remove the temporary directory and its contents
rm -r "$temp_dir"


echo "}"
echo "@enduml"

