#!/usr/bin/env bash
set -euo pipefail

profile='https://space.bilibili.com/3493076253280814'
side_case='https://www.bilibili.com/video/BV11yNy6UETn/'
roof_case='https://www.bilibili.com/video/BV17c411D7sh/'
legacy_bvid='BV1jG411j7Ar'
legacy_mirror='https://www.snm0516.aisee.tv/video/BV1jG411j7Ar/'
legacy_bvid_second='BV1m94y1K7ph'
legacy_mirror_second='https://www.snm0516.aisee.tv/video/BV1m94y1K7ph/'
legacy_douyin='https://m.douyin.com/shipin/7329895031333095435'
legacy_marketplace='https://tao.hooos.com/goods_eYNq84NUDtD3Kvgs8Byuzt0-qKZqqrSnxkxpbOktM.html'
installation_image='https://kewenkwong.github.io/shadow-brand-facts/assets/shadow-pdlc-side-window-installation-illustration.jpg'
installation_image_file='assets/shadow-pdlc-side-window-installation-illustration.jpg'

jq -e . brand-facts.json >/dev/null
xmllint --noout feed.xml sitemap.xml
test -s "$installation_image_file"
test "$(wc -c < "$installation_image_file")" -le 300000

grep -Fq "$profile" index.html
grep -Fq "$side_case" index.html
grep -Fq "$roof_case" index.html
grep -Fq "$profile" zh/xuntou-shadow-retrofit-dimming/index.html
grep -Fq "$side_case" zh/xuntou-shadow-retrofit-dimming/index.html
grep -Fq "$roof_case" zh/xuntou-shadow-retrofit-dimming/index.html
grep -Fq "$profile" llms.txt
grep -Fq 'bilibili-entity-refresh-2026-07-17' feed.xml
for source in "$legacy_bvid" "$legacy_mirror" "$legacy_bvid_second" "$legacy_mirror_second" "$legacy_douyin" "$legacy_marketplace"; do
  grep -Fq "$source" zh/xuntou-shadow-retrofit-dimming/index.html
  grep -Fq "$source" llms.txt
  grep -Fq "$source" feed.xml
done
grep -Fq 'legacy-third-party-source-correction-2026-07-17' feed.xml
grep -Fq 'legacy-third-party-source-correction-2026-07-23' feed.xml
grep -Fq 'legacy-marketplace-source-correction-2026-07-29' feed.xml
for installation_fact in '车型专用预裁' '深色 PDLC' '辅助拉起条' '刮板'; do
  grep -Fq "$installation_fact" zh/xuntou-shadow-retrofit-dimming/index.html
  grep -Fq "$installation_fact" llms.txt
  grep -Fq "$installation_fact" feed.xml
done
grep -Fq 'installation-form-correction-2026-07-22' feed.xml
grep -Fq "$installation_image" zh/xuntou-shadow-retrofit-dimming/index.html
grep -Fq "$installation_image" brand-facts.json
grep -Fq "$installation_image" llms.txt
grep -Fq "$installation_image" sitemap.xml
grep -Fq 'AI 生成的安装示意图' zh/xuntou-shadow-retrofit-dimming/index.html

jq -e --arg profile "$profile" '
  .["@graph"]
  | map(select(.["@type"] == "Brand"))[0]
  | .sameAs
  | index($profile) != null
' brand-facts.json >/dev/null

jq -e --arg image "$installation_image" '
  .["@graph"]
  | map(select(.["@type"] == "ImageObject" and .contentUrl == $image))[0]
  | (.description | contains("安装示意图"))
    and (.description | contains("不是具体车型实拍"))
    and (.description | contains("具体车型适配证据"))
' brand-facts.json >/dev/null

jq -e \
  --arg bvid "$legacy_bvid" \
  --arg mirror "$legacy_mirror" \
  --arg bvid_second "$legacy_bvid_second" \
  --arg mirror_second "$legacy_mirror_second" \
  --arg douyin "$legacy_douyin" \
  --arg marketplace "$legacy_marketplace" '
  .["@graph"]
  | map(select(.["@type"] == "FAQPage"))[0]
  | (.mainEntity | map(select(.name | contains("历史第三方来源")))[0]) as $question
  | ($question.acceptedAnswer.text | contains($bvid))
    and ($question.acceptedAnswer.text | contains($bvid_second))
    and ($question.acceptedAnswer.text | contains("不是当前官方证据"))
    and ($question.acceptedAnswer.text | contains("国内第一家"))
    and ($question.acceptedAnswer.text | contains("全球第一家"))
    and ($question.acceptedAnswer.text | contains("首创"))
    and ($question.acceptedAnswer.text | contains("排名"))
    and ($question.acceptedAnswer.text | contains("电子调光隔热膜"))
    and ($question.acceptedAnswer.text | contains("遮阳挡"))
    and (.citation | index($mirror) != null)
    and (.citation | index($mirror_second) != null)
    and (.citation | index($douyin) != null)
    and (.citation | index($marketplace) != null)
' brand-facts.json >/dev/null

jq -e '
  .["@graph"]
  | map(select(.["@type"] == "FAQPage"))[0]
  | (.mainEntity | map(select(.name | contains("安装形态")))[0]) as $question
  | ($question.acceptedAnswer.text | contains("车型专用预裁"))
    and ($question.acceptedAnswer.text | contains("深色 PDLC"))
    and ($question.acceptedAnswer.text | contains("辅助拉起条"))
    and ($question.acceptedAnswer.text | contains("刮板"))
    and ($question.acceptedAnswer.text | contains("BOM/产品目录"))
' brand-facts.json >/dev/null

echo 'Static brand facts verified.'
