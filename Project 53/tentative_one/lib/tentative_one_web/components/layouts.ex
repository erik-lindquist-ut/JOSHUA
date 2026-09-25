defmodule TentativeOneWeb.Layouts do
  use TentativeOneWeb, :html

  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Phoenix.Controller.get_csrf_token()} />
        <title>Tentative One</title>
        <style>
          :root{--bg:#fbfaf7;--fg:#1d1d1b;--mute:#6b6a65;--line:#e4e1d8;--one:#2f6f4f;--zero:#a33a2a;--held:#9a6a00}
          @media (prefers-color-scheme: dark){:root{--bg:#161614;--fg:#eceae4;--mute:#9a988f;--line:#2e2d29;--one:#6fbf95;--zero:#e0806f;--held:#e2b44f}}
          *{box-sizing:border-box} body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 ui-sans-serif,system-ui,sans-serif}
          main{max-width:720px;margin:0 auto;padding:24px 16px}
          h1{font-size:20px;margin:0 0 4px} .mute{color:var(--mute)}
          textarea,input{width:100%;font:inherit;padding:10px;border:1px solid var(--line);border-radius:8px;background:transparent;color:inherit}
          button{font:inherit;padding:8px 14px;border-radius:8px;border:1px solid var(--line);background:var(--fg);color:var(--bg);cursor:pointer}
          ol{padding-left:22px} li{padding:6px 0;border-bottom:1px solid var(--line)}
          .tag{font-size:12px;padding:1px 8px;border-radius:99px;border:1px solid currentColor;margin-left:8px}
          .tentative,.approved{color:var(--one)} .skipped{color:var(--zero)} .held{color:var(--held)} .pending{color:var(--mute)}
          .bar{display:flex;gap:16px;align-items:baseline;justify-content:space-between;margin:16px 0}
          .decide{font-weight:600;padding:12px;border:1px solid var(--held);border-radius:8px}
        </style>
        <script src="/js/phoenix/phoenix.min.js"></script>
        <script src="/js/lv/phoenix_live_view.min.js"></script>
        <script>
          window.addEventListener("DOMContentLoaded", () => {
            const csrf = document.querySelector("meta[name='csrf-token']").content
            // 1 and 0 anywhere on the page — except while typing in a box
            const Keys = {mounted() {
              this.onKey = e => {
                if (e.target.closest("input, textarea")) return
                if (e.key === "1" || e.key === "0") this.pushEvent("key", {key: e.key})
              }
              window.addEventListener("keyup", this.onKey)
            }, destroyed() { window.removeEventListener("keyup", this.onKey) }}
            new LiveView.LiveSocket("/live", Phoenix.Socket, {hooks: {Keys}, params: {_csrf_token: csrf}}).connect()
          })
        </script>
      </head>
      <body><%= @inner_content %></body>
    </html>
    """
  end

  def app(assigns), do: ~H"<main><%= @inner_content %></main>"
end
