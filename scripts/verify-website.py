#!/usr/bin/env python3
"""Check the served website's metadata/routes, never infer search rankings."""
import argparse
import json
import struct
from html.parser import HTMLParser
from urllib.request import Request, urlopen
from xml.etree import ElementTree

PATHS = ("/", "/how-it-works", "/download", "/privacy", "/support", "/changelog")
ORIGIN = "https://meet-still.app"


class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.meta = {}
        self.canonical = None
        self.h1 = 0

    def handle_starttag(self, tag, attrs):
        data = dict(attrs)
        if tag == "h1":
            self.h1 += 1
        if tag == "meta":
            self.meta[data.get("name") or data.get("property")] = data.get("content")
        if tag == "link" and data.get("rel") == "canonical":
            self.canonical = data.get("href")


def fetch(url):
    with urlopen(Request(url, headers={"User-Agent": "StillWebsiteVerification/1.0"}), timeout=30) as response:
        assert response.status == 200, (url, response.status)
        return response.read(), response.headers


def verify(base, indexable):
    descriptions = []
    results = []
    for path in PATHS:
        body, headers = fetch(base.rstrip("/") + path)
        page = Page()
        page.feed(body.decode())
        assert page.h1 == 1, (path, "H1 count", page.h1)
        assert page.canonical and page.canonical.rstrip("/") == (ORIGIN + path).rstrip("/"), (path, "canonical", page.canonical)
        assert page.meta.get("description"), (path, "missing description")
        assert page.meta.get("og:title") and page.meta.get("og:description"), (path, "share metadata")
        assert page.meta.get("og:url", "").rstrip("/") == (ORIGIN + path).rstrip("/"), (path, "OG URL")
        assert page.meta.get("twitter:card") == "summary_large_image", (path, "Twitter card")
        robots = page.meta.get("robots", "")
        header = headers.get("X-Robots-Tag", "")
        assert ("noindex" not in robots) == indexable, (path, "robots meta", robots)
        assert ("noindex" not in header) == indexable, (path, "robots header", header)
        descriptions.append(page.meta["description"])
        results.append({"path": path, "canonical": page.canonical, "h1": page.h1, "robots": robots})
    assert len(set(descriptions)) == len(PATHS), "Descriptions must be unique"
    sitemap, _ = fetch(base.rstrip("/") + "/sitemap.xml")
    tree = ElementTree.fromstring(sitemap)
    locations = {item.text for item in tree.iter("{http://www.sitemaps.org/schemas/sitemap/0.9}loc")}
    assert locations == {ORIGIN + path for path in PATHS}, "Sitemap route mismatch"
    robots, _ = fetch(base.rstrip("/") + "/robots.txt")
    assert (f"Sitemap: {ORIGIN}/sitemap.xml".encode() in robots) == indexable
    image, headers = fetch(base.rstrip("/") + "/opengraph-image")
    assert image.startswith(b"\x89PNG\r\n\x1a\n"), "Share image must be a PNG"
    assert struct.unpack(">II", image[16:24]) == (1200, 630), "Share image dimensions"
    print(json.dumps({"passed": True, "base": base, "indexable": indexable, "routes": results,
                      "sitemapRoutes": len(locations), "shareImage": "1200x630 PNG"}, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("base")
    parser.add_argument("--indexable", action="store_true")
    args = parser.parse_args()
    verify(args.base, args.indexable)
