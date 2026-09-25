# Original cartoon geese — flat vector, G-rated. Rendered via ImageMagick from SVG.
def goose(x,y,s=1.0,pose="stand",flip=False,hat=None,body="#ffffff"):
    # pose: stand | shrug | point | kick
    t=f'transform="translate({x},{y}) scale({-s if flip else s},{s})"'
    wings=""
    if pose=="shrug":
        wings=('<path d="M-38,-10 C-70,-30 -80,-60 -60,-70 L-52,-62 C-66,-56 -62,-38 -36,-22 Z" fill="{b}" stroke="#333" stroke-width="3"/>'
               '<path d="M38,-10 C70,-30 80,-60 60,-70 L52,-62 C66,-56 62,-38 36,-22 Z" fill="{b}" stroke="#333" stroke-width="3"/>')
    elif pose=="point":
        wings='<path d="M36,-14 C70,-24 100,-30 118,-36 L116,-28 C98,-22 70,-12 40,-2 Z" fill="{b}" stroke="#333" stroke-width="3"/>'
    elif pose=="kick":
        wings='<path d="M-36,-14 C-60,-40 -50,-70 -30,-80 L-24,-72 C-40,-62 -44,-40 -30,-20 Z" fill="{b}" stroke="#333" stroke-width="3"/>'
    else:
        wings='<path d="M-30,0 C-40,-20 -30,-30 -10,-24 L-10,-8 Z" fill="#eaeaea" stroke="#333" stroke-width="3"/>'
    wings=wings.replace("{b}",body)
    legs='<path d="M-14,44 L-14,70 M14,44 L14,70" stroke="#f0a500" stroke-width="6" stroke-linecap="round"/><path d="M-26,72 L-2,72 M2,72 L26,72" stroke="#f0a500" stroke-width="6" stroke-linecap="round"/>'
    if pose=="kick": legs='<path d="M-14,44 L-14,70 M14,44 L60,50" stroke="#f0a500" stroke-width="6" stroke-linecap="round"/><path d="M-26,72 L-2,72 M56,42 L74,58" stroke="#f0a500" stroke-width="6" stroke-linecap="round"/>'
    hatsvg=""
    if hat=="backpack": hatsvg='<rect x="-58" y="-6" width="26" height="34" rx="6" fill="#3b6fb6" stroke="#333" stroke-width="3"/><rect x="-54" y="0" width="18" height="10" rx="3" fill="#8fb3e6"/>'
    if hat=="cape": hatsvg='<path d="M-30,-10 L-70,60 L-10,40 Z" fill="#7a2fa0" stroke="#333" stroke-width="3"/>'
    return f'''<g {t}>{hatsvg}
<ellipse cx="0" cy="10" rx="44" ry="36" fill="{body}" stroke="#333" stroke-width="3"/>
<path d="M-40,20 C-70,10 -80,-10 -60,-20 L-56,-8 C-66,0 -60,10 -38,14 Z" fill="#e6e6e6" stroke="#333" stroke-width="3" opacity="0.6"/>
{wings}{legs}
<path d="M22,-8 C34,-40 40,-70 30,-98" stroke="#333" stroke-width="3" fill="none"/><path d="M22,-8 C34,-40 40,-70 30,-98 C40,-96 46,-70 38,-40 C34,-28 30,-16 34,-6 Z" fill="{body}" stroke="#333" stroke-width="3"/>
<circle cx="34" cy="-108" r="17" fill="{body}" stroke="#333" stroke-width="3"/>
<circle cx="40" cy="-112" r="3" fill="#333"/>
<path d="M50,-108 L74,-102 L50,-96 Z" fill="#f5c400" stroke="#333" stroke-width="3"/>
</g>'''
def kid(x,y,shirt,skin,hair,s=1.0,pose="sit",flip=False):
    t=f'transform="translate({x},{y}) scale({-s if flip else s},{s})"'
    body=f'<rect x="-22" y="0" width="44" height="52" rx="10" fill="{shirt}" stroke="#333" stroke-width="3"/>'
    legs='<path d="M-12,52 L-12,82 M12,52 L12,82" stroke="#39445a" stroke-width="12" stroke-linecap="round"/>' if pose!="sit" else '<path d="M-12,52 L-12,70 L-4,92 M12,52 L12,70 L20,92" stroke="#39445a" stroke-width="12" stroke-linecap="round" fill="none"/>'
    arms='<path d="M-22,10 L-40,40 M22,10 L40,40" stroke="'+skin+'" stroke-width="10" stroke-linecap="round"/>'
    head=f'<circle cx="0" cy="-22" r="22" fill="{skin}" stroke="#333" stroke-width="3"/><path d="M-22,-26 C-20,-50 20,-50 22,-26 Z" fill="{hair}"/>'
    face='<circle cx="-7" cy="-22" r="2.5" fill="#333"/><circle cx="7" cy="-22" r="2.5" fill="#333"/><path d="M-6,-12 Q0,-9 6,-12" stroke="#333" stroke-width="2" fill="none"/>'
    return f'<g {t}>{legs}{arms}{body}{head}{face}</g>'
W,H=1400,900
def frame(inner,bg,title):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><rect width="{W}" height="{H}" fill="{bg}"/>{inner}
<rect x="0" y="{H-70}" width="{W}" height="70" fill="#1c1f26"/><text x="30" y="{H-28}" font-family="Helvetica,Arial" font-size="26" fill="#f2e9c9">{title}</text></svg>'''

# Scene 1 — recess kickball
s1=('<rect x="0" y="0" width="1400" height="520" fill="#bfe3ff"/><circle cx="1200" cy="120" r="70" fill="#ffe27a"/>'
 '<rect x="0" y="520" width="1400" height="320" fill="#7fc36a"/><path d="M200,700 L700,540 L1200,700 L700,860 Z" fill="#d9b982" stroke="#b08a4a" stroke-width="6"/>'
 '<rect x="690" y="530" width="20" height="20" fill="#fff" stroke="#333"/><rect x="1190" y="690" width="20" height="20" fill="#fff" stroke="#333"/><rect x="190" y="690" width="20" height="20" fill="#fff" stroke="#333"/>'
 '<rect x="20" y="300" width="14" height="260" fill="#888"/><rect x="34" y="320" width="130" height="24" fill="#c94f4f"/><path d="M164,332 L360,540" stroke="#e6a23c" stroke-width="26" stroke-linecap="round"/>'
 +goose(700,780,1.0,"kick",hat="backpack")+'<circle cx="800" cy="700" r="26" fill="#d9483b" stroke="#333" stroke-width="3"/><path d="M830,690 L900,640" stroke="#333" stroke-width="3" stroke-dasharray="8,8"/>'
 +goose(1000,560,0.8,"shrug",hat="backpack",body="#f7f0e0")+goose(1150,600,0.8,"shrug",hat="backpack",body="#efe6d2")+goose(1260,540,0.8,"shrug",hat="backpack",body="#fbf6ea")
 +goose(300,540,0.7,"stand",flip=True,hat="backpack")
 +kid(520,640,"#4a78c2","#f1c9a5","#3b2a1a",1.0,"stand")+kid(1050,760,"#e0b13a","#8d5a3b","#1c1c1c",1.0,"stand",flip=True)+kid(380,760,"#c94f8f","#d9a679","#5a3a1a",1.0,"stand")
 +'<g transform="translate(560,300)"><rect x="-10" y="0" width="14" height="240" fill="#9aa"/><rect x="60" y="0" width="14" height="240" fill="#9aa"/><rect x="-10" y="0" width="84" height="12" fill="#9aa"/><path d="M0,60 L-90,240" stroke="#3b6fb6" stroke-width="30" stroke-linecap="round"/></g>'
 +goose(500,470,0.6,"stand",flip=True,body="#f3ecdc"))
open("scene1.svg","w").write(frame(s1,"#bfe3ff","Scene 1 · Recess, 10:15 — the ringleader kicks a line drive; the flock shrugs; one slides backward."))

# Scene 2 — Think-Time desk
s2=('<rect width="1400" height="900" fill="#f4efe4"/><rect x="0" y="600" width="1400" height="300" fill="#c9b79a"/>'
 '<rect x="900" y="120" width="380" height="300" fill="#bfe3ff" stroke="#6b5b3e" stroke-width="14"/><path d="M1090,120 L1090,420 M900,270 L1280,270" stroke="#6b5b3e" stroke-width="10"/>'
 '<rect x="80" y="100" width="520" height="80" fill="#2f5c4a"/><text x="110" y="152" font-family="Helvetica,Arial" font-size="40" fill="#f7f2e2">THINK-TIME</text>'
 '<rect x="120" y="200" width="460" height="300" fill="#fff" stroke="#999" stroke-width="3"/><text x="150" y="250" font-family="Helvetica,Arial" font-size="24" fill="#333">What happened</text><text x="150" y="330" font-family="Helvetica,Arial" font-size="24" fill="#333">What I could do next time</text><text x="150" y="410" font-family="Helvetica,Arial" font-size="24" fill="#333">Who I can make it right with</text>'
 '<rect x="300" y="560" width="420" height="30" fill="#8a6a3e"/><rect x="320" y="590" width="20" height="200" fill="#8a6a3e"/><rect x="680" y="590" width="20" height="200" fill="#8a6a3e"/>'
 +kid(510,500,"#c94f8f","#d9a679","#5a3a1a",1.1,"sit")+'<rect x="400" y="540" width="220" height="22" fill="#fff" stroke="#999"/><path d="M420,552 L560,552" stroke="#333" stroke-width="2"/>'
 +goose(1000,400,0.85,"point",body="#ffffff"))
open("scene2.svg","w").write(frame(s2,"#f4efe4","Scene 2 · Think-Time desk, 10:40 — the reflection sheet; a goose at the window points: think."))

# Scene 3 — Principal's office, scenario B, camera behind the principal's head
s3=('<rect width="1400" height="900" fill="#e9e2d2"/><rect x="0" y="0" width="1400" height="420" fill="#d8cfb8"/>'
 '<rect x="980" y="60" width="340" height="280" fill="#bfe3ff" stroke="#6b5b3e" stroke-width="14"/><path d="M1150,60 L1150,340" stroke="#6b5b3e" stroke-width="10"/>'
 +goose(1150,330,0.75,"shrug",body="#ffffff")+
 '<rect x="980" y="60" width="340" height="280" fill="none" stroke="#6b5b3e" stroke-width="14"/>'
 '<rect x="60" y="120" width="240" height="220" fill="#6b5b3e"/><rect x="80" y="140" width="200" height="40" fill="#c94f4f"/><rect x="80" y="190" width="200" height="40" fill="#3b6fb6"/><rect x="80" y="240" width="200" height="40" fill="#e0b13a"/>'
 '<rect x="200" y="420" width="1000" height="60" fill="#7a5a36"/><rect x="220" y="480" width="960" height="120" fill="#5f4527"/>'
 '<rect x="560" y="380" width="90" height="40" fill="#fff" stroke="#999"/><circle cx="760" cy="395" r="22" fill="#d9483b" stroke="#333" stroke-width="3"/>'
 +kid(450,300,"#4a78c2","#f1c9a5","#3b2a1a",1.0,"sit")+kid(700,300,"#e0b13a","#8d5a3b","#1c1c1c",1.0,"sit")+kid(950,300,"#c94f8f","#d9a679","#5a3a1a",1.0,"sit")+
 '<path d="M0,900 C200,600 400,560 700,560 C1000,560 1200,600 1400,900 Z" fill="#2b2b2b"/><ellipse cx="700" cy="600" rx="150" ry="120" fill="#3a2a1e"/><ellipse cx="700" cy="640" rx="150" ry="70" fill="#2b2b2b"/>'
 '<path d="M600,520 C650,470 750,470 800,520" stroke="#3a2a1e" stroke-width="18" fill="none"/>')
open("scene3.svg","w").write(frame(s3,"#e9e2d2","Scene 3 · Principal's office, scenario B — three side by side; at the window, the shrug."))
print("svg ok")
