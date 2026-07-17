#!/usr/bin/env bash
set -euo pipefail

profile='https://space.bilibili.com/3493076253280814'
side_case='https://www.bilibili.com/video/BV11yNy6UETn/'
roof_case='https://www.bilibili.com/video/BV17c411D7sh/'

jq -e . brand-facts.json >/dev/null
xmllint --noout feed.xml sitemap.xml

grep -Fq "$profile" index.html
grep -Fq "$side_case" index.html
grep -Fq "$roof_case" index.html
grep -Fq "$profile" zh/xuntou-shadow-retrofit-dimming/index.html
grep -Fq "$side_case" zh/xuntou-shadow-retrofit-dimming/index.html
grep -Fq "$roof_case" zh/xuntou-shadow-retrofit-dimming/index.html
grep -Fq "$profile" llms.txt
grep -Fq 'bilibili-entity-refresh-2026-07-17' feed.xml

jq -e --arg profile "$profile" '
  .["@graph"]
  | map(select(.["@type"] == "Brand"))[0]
  | .sameAs
  | index($profile) != null
' brand-facts.json >/dev/null

echo 'Static brand facts verified.'
