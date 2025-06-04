#!/bin/bash

# Move to project folder
cd "$(dirname "$0")/.."

# Generate mocks for tests using Mockolo

modules=(
  "CommonsLib"
  "ConfigLib"
  "LibdigidocLib"
  "UtilsLib"
)

extensions=(
  "FileImportShareExtension"
)

# Handle modules
echo "\n\nGenerating mocks for modules"
for module in "${modules[@]}"; do
  src_dir="Modules/${module}/Sources"
  output_dir="Modules/${module}/Tests/${module}Tests/Mocks/Generated"
  output_file="${output_dir}/${module}+Mocks.swift"

  mkdir -p "$output_dir"
  echo "\n\nGenerating mocks for $module...\n"

  # Set custom imports based on module
  case "$module" in
    "LibdigidocLib")
      custom_imports=("LibdigidocLibSwift")
      testable_imports="LibdigidocLibSwift"
      ;;
    "ConfigLib")
      custom_imports=("ConfigLib")
      testable_imports="ConfigLib"
      ;;
    "UtilsLib")
      custom_imports=("UtilsLib" "CommonsLib")
      testable_imports="UtilsLib"
      ;;
    *)
      custom_imports=()
      testable_imports=""
      ;;
  esac

  # Run mockolo with or without custom imports
  if [ ${#custom_imports[@]} -gt 0 ]; then
    mockolo -s "$src_dir" -d "$output_file" --enable-args-history \
      --custom-imports "${custom_imports[@]}" \
      --testable-imports "${testable_imports[@]}" \
      --logging-level 1
  else
    mockolo -s "$src_dir" -d "$output_file" --enable-args-history \
      --logging-level 1
  fi
done

# Handle Extensions
echo "\n\nGenerating mocks for extensions"
for extension in "${extensions[@]}"; do
  src_dir="Extensions/${extension}"
  output_dir="Extensions/${extension}Tests/Mocks/Generated"
  output_file="${output_dir}/${extension}+Mocks.swift"

  mkdir -p "$output_dir"
  echo "\n\nGenerating mocks for $extension...\n"
  mockolo -s "$src_dir" -d "$output_file" --enable-args-history
done

# Handle RIADigiDoc module
echo "\n\nGenerating mocks for RIADigiDoc module"
main_module_name="RIADigiDoc"
main_src_dir="${main_module_name}"
main_output_dir="${main_module_name}Tests/Mocks/Generated"
main_output_file="${main_output_dir}/${main_module_name}+Mocks.swift"

mkdir -p "$main_output_dir"
echo "\n\nGenerating mocks for $main_module_name...\n"
mockolo -s "$main_src_dir" -d "$main_output_file" --enable-args-history

echo "\n\nDone\n\n"