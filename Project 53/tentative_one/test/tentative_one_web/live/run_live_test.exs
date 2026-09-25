defmodule TentativeOneWeb.RunLiveTest do
  use TentativeOneWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias TentativeOneWeb.RunLive

  defp start(conn, steps) do
    {:ok, view, _} = live(conn, ~p"/")
    view |> form("#plan", plan: %{steps: steps}) |> render_submit()
    view
  end

  defp tick(view, n \\ 1) do
    for _ <- 1..n, do: send(view.pid, :tick)
    render(view)
  end

  defp key(view, k), do: render_hook(view, "key", %{"key" => k})
  defp say(view, text), do: view |> form("#otherwise", say: %{text: text}) |> render_submit()

  describe "empty page" do
    test "asks for steps", %{conn: conn} do
      {:ok, _v, html} = live(conn, ~p"/")
      assert html =~ "One step per line"
    end

    test "West starts at zero", %{conn: conn} do
      {:ok, _v, html} = live(conn, ~p"/")
      assert html =~ ~s(data-west="0")
      assert html =~ ~s(data-status="empty")
    end

    test "1 and 0 before a run do nothing", %{conn: conn} do
      {:ok, v, _} = live(conn, ~p"/")
      assert key(v, "1") =~ ~s(data-status="empty")
      assert key(v, "0") =~ ~s(data-west="0")
    end

    test "a stray tick before a run does nothing", %{conn: conn} do
      {:ok, v, _} = live(conn, ~p"/")
      assert tick(v) =~ ~s(data-status="empty")
    end

    test "the key hook is mounted on the page", %{conn: conn} do
      {:ok, _v, html} = live(conn, ~p"/")
      assert html =~ ~s(phx-hook="Keys")
    end
  end

  describe "starting a run" do
    test "one list item per non-blank line", %{conn: conn} do
      v = start(conn, "a\n\nb\n c ")
      assert has_element?(v, "#step-0", "a")
      assert has_element?(v, "#step-1", "b")
      assert has_element?(v, "#step-2", "c")
      refute has_element?(v, "#step-3")
    end

    test "all steps start waiting", %{conn: conn} do
      v = start(conn, "a\nb")
      assert has_element?(v, "#step-0.pending")
      assert has_element?(v, "#step-1.pending")
    end

    test "status shows running", %{conn: conn} do
      assert render(start(conn, "a")) =~ ~s(data-status="running")
    end

    test "an empty plan is done at once", %{conn: conn} do
      assert render(start(conn, "\n\n")) =~ ~s(data-status="done")
    end
  end

  describe "tentative 1" do
    test "moves with no input from him", %{conn: conn} do
      v = start(conn, "draft\nformat")
      html = tick(v, 2)
      assert html =~ ~s(data-status="done")
      assert html =~ ~s(data-west="0")
    end

    test "each step is marked tentative", %{conn: conn} do
      v = start(conn, "draft\nformat")
      tick(v, 2)
      assert has_element?(v, "#step-0.tentative", "1 · tentative")
      assert has_element?(v, "#step-1.tentative")
    end

    test "the end surfaces what was assumed", %{conn: conn} do
      v = start(conn, "draft\nformat")
      assert tick(v, 2) =~ "Tentative: draft · format"
    end

    test "one tick moves one step, not two", %{conn: conn} do
      v = start(conn, "a\nb")
      tick(v)
      assert has_element?(v, "#step-0.tentative")
      assert has_element?(v, "#step-1.pending")
    end

    test "extra ticks after done change nothing", %{conn: conn} do
      v = start(conn, "a")
      html = tick(v, 1)
      assert tick(v, 3) == html
    end
  end

  @samples %{
    destroy: "delete the logs",
    send: "email it",
    money: "pay the fee",
    regulated: "export PII",
    address: "cc a@b.co",
    password: "set the password"
  }

  for {why, text} <- @samples do
    @why why
    @text text

    describe "inflection · #{why}" do
      test "holds and names the reason and both poles", %{conn: conn} do
        v = start(conn, @text <> "\nafter")
        html = tick(v)
        assert html =~ ~s(data-status="held")
        assert has_element?(v, "#decide", RunLive.reason_text(@why))
        assert has_element?(v, "#decide", "1 clears it · 0 skips it")
      end

      test "1 clears it for one keystroke", %{conn: conn} do
        v = start(conn, @text <> "\nafter")
        tick(v)
        key(v, "1")
        html = tick(v)
        assert has_element?(v, "#step-0.approved", "1 · yours")
        assert html =~ ~s(data-status="done")
        assert html =~ ~s(data-west="1")
      end

      test "0 skips the step, the rest still runs", %{conn: conn} do
        v = start(conn, @text <> "\nafter")
        tick(v)
        key(v, "0")
        html = tick(v)
        assert has_element?(v, "#step-0.skipped", "0 · skipped")
        assert has_element?(v, "#step-1.tentative")
        assert html =~ ~s(data-status="done")
      end
    end
  end

  describe "held" do
    test "ticks do not move past a hold", %{conn: conn} do
      v = start(conn, "email it\nafter")
      tick(v)
      tick(v, 3)
      assert has_element?(v, "#step-1.pending")
    end

    test "the decide line leaves once cleared", %{conn: conn} do
      v = start(conn, "email it")
      tick(v)
      key(v, "1")
      refute has_element?(v, "#decide")
    end
  end

  describe "0 while running" do
    test "stops the run", %{conn: conn} do
      v = start(conn, "a\nb\nc")
      tick(v)
      assert key(v, "0") =~ ~s(data-status="stopped")
    end

    test "stopped runs ignore ticks", %{conn: conn} do
      v = start(conn, "a\nb")
      key(v, "0")
      tick(v, 3)
      assert has_element?(v, "#step-0.pending")
    end

    test "stopping still surfaces what was assumed", %{conn: conn} do
      v = start(conn, "a\nb")
      tick(v)
      assert key(v, "0") =~ "Tentative: a"
    end
  end

  describe "telling it otherwise" do
    test "typed text becomes the next step", %{conn: conn} do
      v = start(conn, "a\nb")
      tick(v)
      say(v, "use Gemini")
      assert has_element?(v, "#step-1", "use Gemini")
      assert has_element?(v, "#step-2", "b")
    end

    test "costs every character West", %{conn: conn} do
      v = start(conn, "a\nb")
      assert say(v, "use Gemini") =~ ~s(data-west="10")
    end

    test "after done, it resumes the run", %{conn: conn} do
      v = start(conn, "a")
      tick(v)
      assert say(v, "one more") =~ ~s(data-status="running")
    end

    test "a typed inflection still holds", %{conn: conn} do
      v = start(conn, "a")
      tick(v)
      say(v, "send it")
      assert tick(v) =~ ~s(data-status="held")
    end

    test "a blank box costs nothing", %{conn: conn} do
      v = start(conn, "a")
      assert say(v, "   ") =~ ~s(data-west="0")
    end
  end

  describe "keys" do
    for k <- ["Shift", "Enter", "2", "a", "Escape"] do
      @k k
      test "#{inspect(k)} costs nothing and changes nothing", %{conn: conn} do
        v = start(conn, "a")
        before = render(v)
        assert key(v, @k) == before
      end
    end

    test "1 while running counts one keystroke and changes nothing else", %{conn: conn} do
      v = start(conn, "a\nb")
      html = key(v, "1")
      assert html =~ ~s(data-west="1")
      assert html =~ ~s(data-status="running")
    end
  end

  describe "new run" do
    test "clears back to the empty page", %{conn: conn} do
      v = start(conn, "a")
      html = v |> element("#reset") |> render_click()
      assert html =~ ~s(data-status="empty")
      assert html =~ "One step per line"
    end

    test "West resets with it", %{conn: conn} do
      v = start(conn, "a")
      say(v, "note")
      assert v |> element("#reset") |> render_click() =~ ~s(data-west="0")
    end
  end
end
