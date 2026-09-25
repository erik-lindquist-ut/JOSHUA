#!/usr/bin/env python3
"""Session-close audit: every root touched today must have a log entry today; every zone index and zone log must mention today if its zone was touched; every .md needs a current .pdf twin."""
import os, datetime, sys
V=os.path.dirname(os.path.dirname(os.path.abspath(__file__))); today=datetime.date.today().isoformat(); t0=datetime.datetime.combine(datetime.date.today(),datetime.time()).timestamp()
SKIP=(".git","90_Archive","_build","__pycache__",".obsidian")
def today_in(p):
    try: return today in open(p,encoding="utf-8",errors="ignore").read()
    except: return False
touched=set(); stale=[]; missing=[]
for d,dirs,files in os.walk(V):
    if any(x in d for x in SKIP): continue
    for f in files:
        p=os.path.join(d,f); rel=os.path.relpath(p,V); parts=rel.split(os.sep)
        if f.startswith("."): continue
        if os.path.getmtime(p)>t0 and not f.endswith(".pdf"):
            touched.add(os.sep.join(parts[:2]) if parts[0] in("40_Courses","50_Ribbon") and len(parts)>2 else parts[0])
        if f.endswith(".md") and "drafts" not in d and "_armored" not in d:
            q=p[:-3]+".pdf"
            if not os.path.exists(q): missing.append(rel)
            elif os.path.getmtime(p)>os.path.getmtime(q): stale.append(rel)
bad=[]
for r in sorted(touched):
    for l in ("PROJECT_LOG.md","METHODOLOGY_LOG.md"):
        p=os.path.join(V,r,l)
        if r in ("00_MIND","50_Ribbon","40_Courses"): continue  # vault roots: their logs are the zone logs in 00_MIND
        if not os.path.exists(p) or not today_in(p): bad.append(f"{r}/{l}")
zone={"40_Courses":"S","50_Ribbon":"V","20_Interview":"P","30_Copyright":"P","10_Atlas":"P"}
zones={zone[r.split(os.sep)[0]] for r in touched if r.split(os.sep)[0] in zone}
for z in sorted(zones):
    for f in (f"00_MIND/zones/LOG_Zone_{z}_PROJECT.md",f"00_MIND/zones/MIND_Zone_{z}.md"):
        if not today_in(os.path.join(V,f)): bad.append(f)
# 00_MIND is not exempt from zone logs (scar 2026-09-24): plans/ is Zone V work; any 00_MIND touch needs SELF + register current
mind_touched=[]
for d,dirs,files in os.walk(os.path.join(V,"00_MIND")):
    for f in files:
        p2=os.path.join(d,f)
        if not f.endswith(".pdf") and not f.startswith(".") and os.path.getmtime(p2)>t0: mind_touched.append(os.path.relpath(p2,V))
if mind_touched:
    for f in ("00_MIND/zones/LOG_SELF_PROJECT.md","00_MIND/ACTION_LOG.md"):
        if not today_in(os.path.join(V,f)): bad.append(f)
    if any("/plans/" in x for x in mind_touched):
        for f in ("00_MIND/zones/LOG_Zone_V_PROJECT.md",):
            if not today_in(os.path.join(V,f)): bad.append(f)
print(f"touched roots: {sorted(touched)}"); print(f"logs missing today's entry: {bad or 'none'}"); print(f"stale pdf twins: {len(stale)} · missing: {len(missing)}")
sys.exit(1 if bad or stale else 0)
