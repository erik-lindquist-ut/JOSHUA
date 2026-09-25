// Renders LTY posts into #app. Graphic-novel slides use an SVG ink + posterize + duotone filter.
(function () {
  const { POSTS, IMAGES, joshuaSays, captionFor, imageUrl } = window.LTY;
  const INK = [0.06, 0.06, 0.07], CREAM = [0.957, 0.937, 0.902];
  const ACCENTS = { gold: '#E3B04B', teal: '#12E0C0', violet: '#7C5CFF', lime: '#C6F432', ice: '#6FD6FF', coral: '#FF5E57' };
  const rgb = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);

  const filters = Object.entries(ACCENTS).map(([k, hex]) => {
    const a = rgb(hex);
    const tbl = (c) => [INK[c], (INK[c] + a[c]) / 2, a[c], (a[c] + CREAM[c]) / 2, CREAM[c]].map((v) => v.toFixed(3)).join(' ');
    return `<filter id="gn-${k}" color-interpolation-filters="sRGB" x="0" y="0" width="100%" height="100%">
      <feColorMatrix type="saturate" values="0" result="g"/>
      <feComponentTransfer in="g" result="post">
        <feFuncR type="discrete" tableValues="0 .22 .45 .7 1"/><feFuncG type="discrete" tableValues="0 .22 .45 .7 1"/><feFuncB type="discrete" tableValues="0 .22 .45 .7 1"/>
      </feComponentTransfer>
      <feComponentTransfer in="post" result="duo">
        <feFuncR type="table" tableValues="${tbl(0)}"/><feFuncG type="table" tableValues="${tbl(1)}"/><feFuncB type="table" tableValues="${tbl(2)}"/>
      </feComponentTransfer>
      <feConvolveMatrix in="g" order="3" preserveAlpha="true" kernelMatrix="-1 -1 -1 -1 8 -1 -1 -1 -1" result="edge"/>
      <feComponentTransfer in="edge" result="ink">
        <feFuncR type="linear" slope="-7" intercept="1.05"/><feFuncG type="linear" slope="-7" intercept="1.05"/><feFuncB type="linear" slope="-7" intercept="1.05"/>
      </feComponentTransfer>
      <feBlend in="duo" in2="ink" mode="multiply"/>
    </filter>`;
  }).join('');

  const esc = (s) => s.replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

  function overlays(k) {
    const im = IMAGES[k];
    let h = '';
    for (const [x, y, w, hh] of im.blur || []) {
      const fade = x === 0 && w === 100 ? 'fade-d' : x === 0 ? 'fade-r' : 'fade-l';
      h += `<div class="blur ${fade}" style="left:${x}%;top:${y}%;width:${w}%;height:${hh}%"></div>`;
    }
    if (im.plate) h += `<span class="plate" style="left:${im.plate[0]}%;top:${im.plate[1]}%">EDL 1</span>`;
    return h;
  }

  function slide(p, s, i, n) {
    const im = IMAGES[s.img];
    const num = `<span class="n">${i + 1}/${n}</span>`;
    if (s.style === 'photo') {
      return `<div class="s photo">${num}
        <div class="ph${im.tall ? ' tall' : ''}"><img src="${imageUrl(s.img)}" alt="">${overlays(s.img)}</div>
        <div class="tx"><div class="eb" style="color:${ACCENTS[p.accent]}">${esc(s.eb)}</div><h2>${esc(s.head)}</h2><p>${esc(s.body)}</p>
        <div class="cr">Photo: ${esc(im.by)}, ${im.lic}</div></div></div>`;
    }
    return `<div class="s novel" style="--acc:${ACCENTS[p.accent]}">${num}
      <div class="title">${esc(s.head)}</div>
      <div class="panel"><div class="ph"><img src="${imageUrl(s.img)}" alt="" style="filter:url(#gn-${p.accent})">${overlays(s.img)}<div class="dots"></div></div></div>
      <div class="says"><b>Joshua says${p.helix ? ' · Strand B' : ''}</b>${esc(joshuaSays(s.js).replace(/^Joshua says: /, ''))}</div>
      <div class="cr">Art from photo: ${esc(im.by)}, ${im.lic}</div></div>`;
  }

  const app = document.getElementById('app');
  app.innerHTML = `<svg width="0" height="0" style="position:absolute">${filters}</svg>` +
    `<header><div class="brand">Last Ten Yards</div><h1>${POSTS.length} posts</h1><p>Swipe each post. Copy its caption underneath.</p></header>` +
    POSTS.map((p, pi) => `<article>
      <div class="ptitle"><span>Post ${pi + 1}</span>${esc(p.title)}</div>
      <div class="deck">${p.slides.map((s, i) => slide(p, s, i, p.slides.length)).join('')}</div>
      <details><summary>Caption</summary><pre>${esc(captionFor(p))}</pre>
      <button onclick="navigator.clipboard.writeText(this.previousElementSibling.textContent);this.textContent='Copied'">Copy caption</button></details>
    </article>`).join('');
})();
