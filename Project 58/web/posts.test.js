// Specs for the Last Ten Yards post set. Run: node --test
const test = require('node:test');
const assert = require('node:assert/strict');
const { POSTS, IMAGES, BASE_TAGS, joshuaSays, tagsFor, captionFor, imageUrl } = require('./priv/static/assets/posts.js');

const JS_RE = /^Joshua says: Think, with compassion, about .+\. Do it differently — with .+, or with .+\.$/;

test('15 posts: the Kristin post first, then 14 more', () => {
  assert.equal(POSTS.length, 15);
  assert.match(POSTS[0].title, /Kristin/);
});

test('base tags carry the whole Tesla / SpaceX line and the company', () => {
  for (const t of ['#LastTenYards', '#Tesla', '#TeslaEnergy', '#Powerwall', '#Megapack', '#SolarRoof',
    '#Robotaxi', '#Optimus', '#Starlink', '#SpaceX', '#Starship', '#Midvale']) {
    assert.ok(BASE_TAGS.includes(t), t);
  }
});

POSTS.forEach((p, i) => {
  const n = i + 1;

  test(`post ${n}: every base tag is present, #LastTenYards first`, () => {
    const tags = tagsFor(p);
    assert.equal(tags[0], '#LastTenYards');
    for (const t of BASE_TAGS) assert.ok(tags.includes(t), `${t} missing`);
  });

  test(`post ${n}: 30 tags or fewer, no repeats, all well-formed`, () => {
    const tags = tagsFor(p);
    assert.ok(tags.length <= 30, `${tags.length} tags`);
    assert.equal(new Set(tags.map((t) => t.toLowerCase())).size, tags.length);
    for (const t of tags) assert.match(t, /^#[A-Za-z0-9]+$/);
  });

  test(`post ${n}: at least 4 slides`, () => {
    assert.ok(p.slides.length >= 4);
  });

  p.slides.forEach((s, j) => {
    const even = j % 2 === 1; // slides 2, 4, ...
    test(`post ${n} slide ${j + 1}: ${even ? 'graphic novel + Joshua says' : 'photo, no Joshua says'}`, () => {
      assert.equal(s.style, even ? 'novel' : 'photo');
      if (even) assert.match(joshuaSays(s.js), JS_RE);
      else assert.equal(s.js, undefined);
      assert.ok(s.head && s.head.length <= 48, 'headline short');
      assert.ok(IMAGES[s.img], `image ${s.img} known`);
    });
  });

  test(`post ${n}: caption credits every photo it uses`, () => {
    const cap = captionFor(p);
    for (const s of p.slides) assert.ok(cap.includes(IMAGES[s.img].by), IMAGES[s.img].by);
    assert.ok(cap.includes('#LastTenYards'));
  });

  test(`post ${n}: names — Kristin only in post 1, never Andrea`, () => {
    const all = JSON.stringify(p);
    assert.ok(!/Andrea/i.test(all));
    if (n > 1) assert.ok(!/Kristin/.test(all));
  });
});

test('every image is licensed, credited, and served from Wikimedia', () => {
  for (const [k, im] of Object.entries(IMAGES)) {
    assert.match(im.lic, /^(CC0|Public domain|CC BY(-SA)? [0-9.]+)$/, k);
    assert.ok(im.by.length > 1, k);
    assert.match(imageUrl(k), /^https:\/\/upload\.wikimedia\.org\/wikipedia\/commons\//, k);
  }
});

test('every image is used by some slide, and every blur box stays inside the frame', () => {
  const used = new Set(POSTS.flatMap((p) => p.slides.map((s) => s.img)));
  for (const k of Object.keys(IMAGES)) assert.ok(used.has(k), `${k} unused`);
  for (const im of Object.values(IMAGES)) for (const [x, y, w, h] of im.blur || []) assert.ok(x >= 0 && y >= 0 && x + w <= 100 && y + h <= 100);
});

test('Joshua says has one shape', () => {
  assert.equal(
    joshuaSays({ about: 'a', y: 'b', z: 'c' }),
    'Joshua says: Think, with compassion, about a. Do it differently — with b, or with c.'
  );
});

// — 2026-09-24: posts 1–5 untouched; 6–15 punchy, each a double helix (Strand A = the machine, Strand B = the people) —
const crypto = require('node:crypto');
test('posts 1–5 are left exactly as they were', () => {
  const h = crypto.createHash('sha256').update(JSON.stringify(POSTS.slice(0, 5))).digest('hex');
  assert.equal(h, '4f3c6d6df39de0e3a77ffb323285e5ced229e824731a3f56355f26b4e0dd4969');
});
const words = (s) => s.trim().split(/\s+/).length;
POSTS.slice(5).forEach((p, k) => {
  const n = k + 6;
  test(`post ${n}: punchy — headlines ≤ 6 words, lines ≤ 12 words, Joshua says ≤ 26 words`, () => {
    for (const s of p.slides) {
      assert.ok(words(s.head) <= 6, `head: ${s.head}`);
      if (s.body) assert.ok(words(s.body) <= 12, `body: ${s.body}`);
      if (s.js) assert.ok(words(joshuaSays(s.js)) <= 26, `js: ${joshuaSays(s.js)}`);
    }
  });
  test(`post ${n}: double helix — photo slides are Strand A, Joshua says is Strand B, caption says so`, () => {
    for (const s of p.slides.filter((x) => x.style === 'photo')) assert.match(s.eb, /^Strand A · /);
    assert.ok(p.helix === true);
    assert.match(captionFor(p), /Two strands, one helix/);
  });
});
