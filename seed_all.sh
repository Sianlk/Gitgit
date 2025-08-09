#!/usr/bin/env bash
set -euo pipefail

SITE_URL="https://sianlk.github.io/gitgit"
mkdir -p properties

mkprop () {
  local slug="$1" title="$2" street="$3" town="$4" postcode="$5" rent="$6" sale="$7" desc="$8"
  local dir="properties/$slug"; mkdir -p "$dir"
  cat > "$dir/index.html" <<HTML
<!doctype html><meta charset="utf-8">
<title>$title — $street, $town $postcode</title>
<h1>$title</h1>
<p><strong>Address:</strong> $street, $town $postcode</p>
<p><strong>Rent (min):</strong> £$rent</p>
<p><strong>Sale (min):</strong> £$sale</p>
<p>$desc</p>
<script type="application/ld+json">
{ "@context": "https://schema.org",
  "@type": "Residence",
  "name": "$title",
  "address": { "@type":"PostalAddress",
    "streetAddress":"$street",
    "addressLocality":"$town",
    "postalCode":"$postcode",
    "addressCountry":"GB"
  },
  "offers": [
    { "@type":"Offer","priceCurrency":"GBP","price":"$sale","availability":"https://schema.org/InStock","url":"$SITE_URL/$dir/" },
    { "@type":"Offer","priceCurrency":"GBP","price":"$rent","availability":"https://schema.org/InStock","url":"$SITE_URL/$dir/" }
  ],
  "description": "$desc"
}
</script>
HTML
}

# 58 Chester Road (re-add)
mkprop '58-chester-road-hounslow-tw4-6hx' \
       '3-bed semi (AST £2,600/m)' \
       '58 Chester Road' \
       'Hounslow' \
       'TW4 6HX' \
       '2600' \
       '625000' \
       'Lawful rear dormer + porch, 6m single-storey ext approvals (P/2020/0155, PA/2020/1649). Near tube A30/A4/A312/M4.'

# 18 Humber Lane (new)
mkprop '18-humber-lane-newton-abbot-tq12-3dj' \
       '5-bed detached with garage (built 2002)' \
       '18 Humber Lane' \
       'Newton Abbot' \
       'TQ12 3DJ' \
       '2400' \
       '600000' \
       'Newly modified; great front & back yard; nearby comparable has double-storey side extension.'

# Homepage
cat > index.html <<HTML
<!doctype html><meta charset="utf-8"><title>Gitgit</title>
<h1>Gitgit</h1>
<ul>
  <li><a href="properties/58-chester-road-hounslow-tw4-6hx/">58 Chester Road, Hounslow TW4 6HX</a></li>
  <li><a href="properties/18-humber-lane-newton-abbot-tq12-3dj/">18 Humber Lane, Newton Abbot TQ12 3DJ</a></li>
</ul>
HTML

# robots + sitemap
cat > robots.txt <<ROB
User-agent: *
Allow: /
Sitemap: $SITE_URL/sitemap.xml
ROB

cat > sitemap.xml <<XML
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>$SITE_URL/</loc></url>
  <url><loc>$SITE_URL/properties/58-chester-road-hounslow-tw4-6hx/</loc></url>
  <url><loc>$SITE_URL/properties/18-humber-lane-newton-abbot-tq12-3dj/</loc></url>
</urlset>
XML

git add -A
git commit -m "seed: add 58 Chester Rd + 18 Humber Lane; homepage/robots/sitemap" || true
git push -u origin main
echo "Done. Pages will redeploy in ~1–3 minutes: $SITE_URL"
