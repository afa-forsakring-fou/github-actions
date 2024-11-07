touch scanResults
scanResults="scanResults"
vulnerabilitySeverityRating=(CRITICAL HIGH MEDIUM LOW)
metaDataTableFormat='table(vulnerability.effectiveSeverity, vulnerability.cvssScore, vulnerability.packageIssue[0].affectedPackage, vulnerability.packageIssue[0].affectedVersion.name, vulnerability.packageIssue[0].fixedVersion.name, vulnerability.shortDescription)'
containerTag="eu.gcr.io/fou-delivery/fou-admin-web:f0d2cdab8077c8b9d33208fc7392f23e2036ffb9"
gcloud artifacts docker images scan --remote --format='value(response.scan)' "$containerTag" >scan_id.txt
gcloud artifacts docker images list-vulnerabilities "$(cat scan_id.txt)" --format="$metaDataTableFormat" >"$scanResults"
echo "Here are the scan results:"

CRITICAL=$(grep -c "${vulnerabilitySeverityRating[0]}" <"$scanResults")
HIGH=$(grep -c "${vulnerabilitySeverityRating[1]}" <"$scanResults")
MEDIUM=$(grep -c "${vulnerabilitySeverityRating[2]}" <"$scanResults")
LOW=$(grep -c "${vulnerabilitySeverityRating[3]}" <"$scanResults")
echo "Found vulnerabilities summary:"
echo "CRITICAL: $CRITICAL"
echo "HIGH: $HIGH"
echo "MEDIUM: $MEDIUM"
echo "LOW: $LOW"

resultsVar=$(<$scanResults)
echo "scanResults<<EOF" >>$GITHUB_ENV
echo "" >>$GITHUB_ENV
echo "Container image scanning found the following vulnerabilities:" >>$GITHUB_ENV
echo "<pre>" >>$GITHUB_ENV

for i in "${resultsVar[@]}"; do
    echo "$i"
    echo "$i" >>$GITHUB_ENV
    # or do whatever with individual element of the array
done

echo "</pre>" >>$GITHUB_ENV
echo "EOF" >>$GITHUB_ENV
