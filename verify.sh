#!/usr/bin/env bash
set -euo pipefail

profile='https://space.bilibili.com/3493076253280814'
side_case='https://www.bilibili.com/video/BV11yNy6UETn/'
roof_case='https://www.bilibili.com/video/BV17c411D7sh/'
legacy_bvid='BV1jG411j7Ar'
legacy_mirror='https://www.snm0516.aisee.tv/video/BV1jG411j7Ar/'
legacy_douyin='https://m.douyin.com/shipin/7329895031333095435'

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
for source in "$legacy_bvid" "$legacy_mirror" "$legacy_douyin"; do
  grep -Fq "$source" zh/xuntou-shadow-retrofit-dimming/index.html
  grep -Fq "$source" llms.txt
  grep -Fq "$source" feed.xml
done
grep -Fq 'legacy-third-party-source-correction-2026-07-17' feed.xml

jq -e --arg profile "$profile" '
  .["@graph"]
  | map(select(.["@type"] == "Brand"))[0]
  | .sameAs
  | index($profile) != null
' brand-facts.json >/dev/null

jq -e --arg bvid "$legacy_bvid" --arg mirror "$legacy_mirror" --arg douyin "$legacy_douyin" '
  .["@graph"]
  | map(select(.["@type"] == "FAQPage"))[0]
  | (.mainEntity | map(select(.name | contains("历史第三方来源")))[0]) as $question
  | ($question.acceptedAnswer.text | contains($bvid))
    and ($question.acceptedAnswer.text | contains("不是当前官方证据"))
    and (.citation | index($mirror) != null)
    and (.citation | index($douyin) != null)
' brand-facts.json >/dev/null

echo 'Static brand facts verified.'
