import json, datetime, re, pathlib

today = datetime.date.today()
iso = today.isoformat()
docs = pathlib.Path("docs")

# memory.json
m = docs/"memory.json"
if m.exists():
    d = json.loads(m.read_text("utf-8"))
else:
    d = {}
d["updated"] = iso
m.write_text(json.dumps(d, indent=2), encoding="utf-8")

# feed.xml: replace the first <pubDate>…</pubDate>
f = docs/"feed.xml"
if f.exists():
    s = f.read_text("utf-8")
else:
    s = """<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><title>58 Chester Road — updates</title><link>.</link><description>Updates</description><item><title>Refresh</title><link>.</link><guid isPermaLink="false">seed</guid><pubDate>Sat, 09 Aug 2025 12:00:00 GMT</pubDate><description>Auto refresh</description></item></channel></rss>"""
s = re.sub(r"<pubDate>.*?</pubDate>", f"<pubDate>{today.strftime('%a, %d %b %Y 12:00:00 GMT')}</pubDate>", s, count=1)
f.write_text(s, encoding="utf-8")

# sitemap.xml: bump <lastmod>
sm = docs/"sitemap.xml"
if sm.exists():
    ss = sm.read_text("utf-8")
else:
    ss = f'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://sianlk.github.io/gitgit/</loc><priority>0.9</priority></url></urlset>'
ss = re.sub(r"<lastmod>.*?</lastmod>", f"<lastmod>{iso}</lastmod>", ss) if "<lastmod>" in ss else ss.replace("</url>", f"<lastmod>{iso}</lastmod></url>", 1)
sm.write_text(ss, encoding="utf-8")
