#!/bin/bash

# Check code files for formatting compliance using Artistic Style
# http://astyle.sourceforge.net/

readonly optionsFilePath="$1"
readonly namePatterns="$2"
readonly targetPaths="$3"
readonly excludePaths="$4"

# Validate inputs
if [[ "$optionsFilePath" != "none" && ! -f "$optionsFilePath" ]]; then
  echo "::error::Options file path: $optionsFilePath doesn't exist"
  exit 1
fi

while IFS='' read -r targetPath && [[ -n "$targetPath" ]]; do
  if ! [[ -d "$targetPath" ]]; then
    echo "::error::Target path: $targetPath doesn't exist"
    exit 1
  fi
done <<<"$(echo "$targetPaths" | yq eval '.[]' -)"

while IFS='' read -r excludePath && [[ -n "$excludePath" ]]; do
  if ! [[ -d "$excludePath" ]]; then
    echo "::error::Exclude path: $excludePath doesn't exist"
    exit 1
  fi
done <<<"$(echo "$excludePaths" | yq eval '.[]' -)"

# Assemble the find options for the file name patterns
while IFS='' read -r namePattern && [[ -n "$namePattern" ]]; do
  namePatternOptions="$namePatternOptions -name ""'""$namePattern""'"" -or"
done <<<"$(echo "$namePatterns" | yq eval '.[]' -)"
# Handle the trailing -or
namePatternOptions="$namePatternOptions -false"

# Assemble the find options for the excluded paths
while IFS='' read -r excludePath && [[ -n "$excludePath" ]]; do
  excludeOptions="$excludeOptions -path $excludePath -prune -or"
done <<<"$(echo "$excludePaths" | yq eval '.[]' -)"

# Set default exit status
exitStatus=0

while IFS='' read -r targetPath && [[ -n "$targetPath" ]]; do
  while read -r filename; do
    # Check if it's a file (find matches on pruned folders)
    if [[ -f "$filename" ]]; then
      echo "::group::Checking $filename"
      if ! diff --strip-trailing-cr "$filename" <(astyle --options="$optionsFilePath" --dry-run <"$filename"); then
        echo "::endgroup::"
        echo "::error::Non-compliant code formatting in $filename"
        # Make the function fail
        exitStatus=1
      else
        echo "::endgroup::"
      fi
    fi
  done <<<"$(eval "find $targetPath $excludeOptions \( $namePatternOptions -and -type f \)")"
done <<<"$(echo "$targetPaths" | yq eval '.[]' -)"

exit "$exitStatus"
