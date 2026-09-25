#!/usr/bin/env python3
"""Fail-forward traversal. Given the terms a tentative choice touches, walk EVERY tree and artifact
and list each file that carries them — vault, outputs, skills — so the surfaced list is complete, not local.
Usage: python3 _build/traverse.py "first contact" "Now Assist" [--root PATH ...]
Reads .md .html .py .json .txt .svg natively; .docx and .pdf via python-docx / pdftotext."""
import sys, os, re, subprocess, zipfile
args=[a for a in sys.argv[1:] if not a.startswith("--")]
roots=[]; i=0
for k,a in enumerate(sys.argv[1:]):
    if a=="--root": roots.append(sys.argv[k+2])
VAULT=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
roots=roots or [VAULT, os.path.expanduser("~/../outputs") if False else "/sessions/dazzling-busy-ritchie/mnt/outputs", "/sessions/dazzling-busy-ritchie/mnt/.claude/skills"]
SKIP={".git",".obsidian","__pycache__","90_Archive"}
TEXT={".md",".html",".py",".json",".txt",".svg",".csv",".xml",".yaml",".yml"}
def text_of(p):
    ext=os.path.splitext(p)[1].lower()
    try:
        if ext in TEXT: return open(p,encoding="utf-8",errors="ignore").read()
        if ext==".docx":
            with zipfile.ZipFile(p) as z: return re.sub(r"<[^>]+>"," ",z.read("word/document.xml").decode("utf-8","ignore"))
        if ext==".pdf": return subprocess.run(["pdftotext",p,"-"],capture_output=True,text=True).stdout
    except Exception: return ""
    return ""
terms=[re.compile(re.escape(t),re.I) for t in args]
hits={}
for root in roots:
    for d,dirs,files in os.walk(root):
        dirs[:]=[x for x in dirs if x not in SKIP and not x.startswith(".")]
        for f in files:
            p=os.path.join(d,f); t=text_of(p)
            if not t: continue
            found=[a for a,rx in zip(args,terms) if rx.search(t)]
            if found: hits[p]=found
for p in sorted(hits): print(f"{p}\n    ↳ {' · '.join(hits[p])}")
print(f"\n{len(hits)} artifact(s) carry the term(s). Every one is in scope for the surfaced list.")
