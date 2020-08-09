#!/bin/bash

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
EXPORT_DIR="$SOURCE_DIR/export"
WORK_DIR="/dev/shm/adblock-generator"
STATS_DIR="$SOURCE_DIR/stats"

LISTS="$SOURCE_DIR/lists.txt"
REGEX="$SOURCE_DIR/regex.txt"
CUSTOM_BLACKLIST="$SOURCE_DIR/custom_blacklist.txt"
CUSTOM_WHITELIST="$SOURCE_DIR/custom_whitelist.txt"

TMP_LIST="$WORK_DIR/blocklist.tmp"
TMP_LIST2="$WORK_DIR/blocklist.tmp2"
FNL_LIST="$EXPORT_DIR/blocklist.txt"
FNL_LIST_ZERO="$EXPORT_DIR/blocklist_all_zero.txt"

# STATS
CHANGELOG="$STATS_DIR/changelog.txt"
ADDED_DOMAINS="$STATS_DIR/added.txt"
REMOVED_DOMAINS="$STATS_DIR/removed.txt"
GROUPED_BY_DOMAIN="$STATS_DIR/top_50_blocked_tld.txt"

# Create Dirs
mkdir -p "$STATS_DIR" "$EXPORT_DIR" "$WORK_DIR"

# Download all block lists into one single file
echo -e "All block lists are currently being downloaded ..."
while read -r url; do curl -s "$url" >>"$TMP_LIST"; done <"$LISTS"
cat "$CUSTOM_BLACKLIST" >> "$TMP_LIST"

echo -e "Removing everything starting with punctation ..."
sed -i '/^[[:punct:]]/ d' "$TMP_LIST"

echo -e "Removing IP adresses ..."
sed -i -e 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}//g' "$TMP_LIST"

echo -e "Removing spaces and setting everything lower case ..."
cat "$TMP_LIST" | tr -d ' ' | tr -d '\t' | sed '/^[[:space:]]*$/d' | tr '[:upper:]' '[:lower:]' >"$TMP_LIST2" && mv -f "$TMP_LIST2" "$TMP_LIST"

echo -e "Sorting and removing duplicates ..."
grep -oe '^.*\S' "$TMP_LIST" | sort | uniq >"$TMP_LIST2" && mv -f "$TMP_LIST2" "$TMP_LIST"

echo -e "Validating domains and subdomains ..."
pcregrep -o '^([a-z0-9][a-z0-9-_]*\.)*[a-z0-9]*[a-z0-9-_]*[[a-z0-9]+$' "$TMP_LIST" >"$TMP_LIST2" && mv -f "$TMP_LIST2" "$TMP_LIST"

echo -e "Regex filters are applied ..."
while read -r r; do sed -i -E "${r}d" "$TMP_LIST"; done <"$REGEX"


echo -e "Entries of the whitelist are kept ..."
comm -23 <(sort "$TMP_LIST") <(sort "$CUSTOM_WHITELIST")  >"$TMP_LIST2" && mv -f "$TMP_LIST2" "$TMP_LIST"

echo -e "Stats: Top 50 blocked domains ..."
cat "$TMP_LIST" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -50 >"$GROUPED_BY_DOMAIN"

echo -e "Stats: Changelog ..."
echo "$(date +"%Y-%m-%d %H:%M:%S")    $(wc -l <"$TMP_LIST") Domains" >>"$CHANGELOG"
echo "$(tail -10 "$CHANGELOG")" >"$CHANGELOG"

comm -13 <(sort "$TMP_LIST") <(sort "$FNL_LIST") >"$REMOVED_DOMAINS"
comm -23 <(sort "$TMP_LIST") <(sort "$FNL_LIST") >"$ADDED_DOMAINS"
echo -e "Stats: \e[32m$(wc -l <"$ADDED_DOMAINS") \e[39madded domains ..."
echo -e "Stats: \e[31m$(wc -l <"$REMOVED_DOMAINS") \e[39mremoved domains ..."

echo -e "The generation is complete: \e[95m$(wc -l <"$TMP_LIST") domains are in the blocklist!"
sed -e 's/^/0.0.0.0\ /' "$TMP_LIST" >"$FNL_LIST_ZERO"
mv -f "$TMP_LIST" "$FNL_LIST"
