// Redirect: this file was a stale early copy of ../posts.test.js (its first 82 lines, requiring a
// ./posts.js that never lived in priv/). The real specs are ../posts.test.js, which loads
// priv/static/assets/posts.js. Running this file runs exactly those specs:
//   node priv/posts.test.js   (same as: node posts.test.js)
require('../posts.test.js');
