import os, re, json, datetime, pathlib
now = datetime.datetime.utcnow()
docs = pathlib.Path("docs"); docs.mkdir(exist_ok=True)
mem = docs/"memory.json"
data = {}
if mem.exists():
    try: data = json.loads(mem.read_text("utf-8"))
    except: data = {}
text = os.environ.get("SEED_TEXT","").strip()
pairs = dict(re.findall(r'(\w+)=(".*?"|\S+)', text))
def norm(v): return v.strip('"').strip()
if "addr"  in pairs: data["address"] = norm(pairs["addr"])
if "price" in pairs: data["askingPriceGBP"] = int(norm(pairs["price"]).replace(",","").replace("£",""))
if "rent"  in pairs:
    rent = int(norm(pairs["rent"]).replace(",",""))
    data["tenancy"] = {**data.get("tenancy",{}), "rentPcm": rent, "rentPa": rent*12}
if "note"  in pairs: data["note"] = norm(pairs["note"])
data["updated"] = now.date().isoformat()
mem.write_text(json.dumps(data, indent=2), encoding="utf-8")

# minimal feed bump (freshness)
feed = docs/"feed.xml"
pub = now.strftime("%a, %d %b %Y %H:%M:%S GMT")
if feed.exists():
    s = feed.read_text("utf-8")
else:
    s = '<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><title>58 Chester Road — updates</title><link>.</link><description>Updates</description><item><title>Seed</title><link>.</link><guid isPermaLink="false">seed</guid><pubDate>Mon, 01 Jan 2001 00:00:00 GMT</pubDate><description>Init</description></item></channel></rss>'
s = re.sub(r"<pubDate>.*?</pubDate>", f"<pubDate>{pub}</pubDate>", s, count=1)
feed.write_text(s, encoding="utf-8")

# sitemap (exists or create minimal)
sm = docs/"sitemap.xml"
if not sm.exists():
    sm.write_text('<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://sianlk.github.io/gitgit/</loc><priority>0.9</priority></url></urlset>', encoding="utf-8")
