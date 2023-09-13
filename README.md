# OpenAPI to C4 Diagram Converter

This bash script is designed to convert OpenAPI specifications into C4 diagrams, making it easier to visualize and document your APIs and their relationships within your organization. It also provides the option to include custom relationships between components by passing in CSV files. The script utilizes `jq`, `sed`, and `curl` for processing the OpenAPI data and generating PlantUML code.

## Prerequisites

Before using this script, make sure you have the following prerequisites installed on your system:

- **jq**: A lightweight and flexible command-line JSON processor. If you've not used it before (and you should!) then you can install it from [here](https://stedolan.github.io/jq/).
- **curl**: A command-line tool for downloading data from URLs. You've very likely got it installed already, but if not you can install it from [here](https://curl.se/download.html).
- **sed**: A stream editor for filtering and transforming text. It's usually pre-installed on Unix-like systems.
- **plantuml**: A diagram creation tool. You might not have this in your toolbox, but once you get it you'll find it indispensible. You can install it from [here](https://plantuml.com/).

## Usage

1. Set the following environment variables:

   - `TITLE`: The title of the diagram.
   - `ENTERPRISE`: The name of your enterprise or organization.

2. Run the script, passing in the URLs of any OpenAPI docs and local CSV files as arguments. The script will automatically detect OpenAPI docs based on the URL scheme (HTTPS). Any other files provided will be assumed to contain local relationships between components.

   Example:
   ```bash
   TITLE="My API Diagram" ENTERPRISE="MyCompany" ./openapi-to-c4.sh https://api.example.com/openapi.json relationships.csv > my-diagram.puml
   ```

3. The script will generate a PlantUML diagram with the C4 diagram representation. It'll dump this to stdout - to save as a file just send it to a file of your choice as per the above example. You can then run this PlantUML file through PlantUML to create a PNG image of your C4 diagram.

## How it Works

The script uses curl to fetch the OpenAPI specs from the provided URLs and then utilizes jq to parse and process the data.
It identifies API endpoints and represents each endpoint as a component within a container that represents the API itself.
If CSV files containing custom relationships are provided, the script incorporates these relationships into the diagram.

## Example

Here's an example of how to use this script to generate a C4 diagram:

   ```bash
   TITLE="My API Diagram" ENTERPRISE="MyCompany" ./convert.sh https://api.example.com/openapi.json relationships.csv
   ```

## Custom Relationships (CSV Format)

You can specify custom relationships between components by providing a CSV file. The CSV file format should be as follows:

   ```csv
   source_component,target_endpoint
   ```

source_component: The name of the source component.
target_endpoint: The id of the target endpoint

## Output

The output of the script is a PlantUML file (e.g., output.puml) that represents the C4 diagram. You can use the PlantUML tool to render it into a PNG image.

Some large diagrams don't render too well to png files (the default output of PlantUML). A workaround is to render to svg, and then use the tool of your choice to convert to png. eg

   ```bash
   plantuml -tsvg my-diagram.puml
   ```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

This script was inspired by the C4 model for visualizing software architecture, created by Simon Brown.
Special thanks to the authors and maintainers of jq, sed, and curl for their fantastic tools.
