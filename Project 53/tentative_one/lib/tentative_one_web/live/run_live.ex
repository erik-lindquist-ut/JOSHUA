defmodule TentativeOneWeb.RunLive do
  @moduledoc """
  Paste steps. They move on a tentative 1. An inflection point holds
  and asks for one key: 1 clears it · 0 skips it. 0 while running stops.
  Anything typed in the box is him telling otherwise.
  """
  use TentativeOneWeb, :live_view
  alias TentativeOne.Run

  @impl true
  def mount(_params, _session, socket), do: {:ok, assign(socket, run: nil)}

  @impl true
  def handle_event("start", %{"plan" => %{"steps" => steps}}, socket) do
    {:noreply, socket |> assign(run: Run.new(steps)) |> schedule()}
  end

  def handle_event("key", %{"key" => key}, %{assigns: %{run: %Run{} = run}} = socket)
      when key in ["1", "0"] do
    {:noreply, socket |> assign(run: Run.input(run, key)) |> schedule()}
  end

  def handle_event("key", _params, socket), do: {:noreply, socket}

  def handle_event("otherwise", %{"say" => %{"text" => text}}, %{assigns: %{run: %Run{} = run}} = socket) do
    {:noreply, socket |> assign(run: Run.input(run, text)) |> schedule()}
  end

  def handle_event("otherwise", _params, socket), do: {:noreply, socket}

  def handle_event("reset", _params, socket), do: {:noreply, assign(socket, run: nil)}

  @impl true
  def handle_info(:tick, %{assigns: %{run: %Run{} = run}} = socket) do
    {:noreply, socket |> assign(run: Run.tick(run)) |> schedule()}
  end

  def handle_info(:tick, socket), do: {:noreply, socket}

  defp schedule(%{assigns: %{run: %Run{status: :running}}} = socket) do
    case Application.get_env(:tentative_one, :tick_ms, 900) do
      :manual -> :ok
      ms -> if connected?(socket), do: Process.send_after(self(), :tick, ms)
    end

    socket
  end

  defp schedule(socket), do: socket

  @reasons %{
    destroy: "deletes or overwrites",
    send: "sends something out",
    money: "moves money",
    regulated: "touches regulated data",
    address: "puts an email address on it",
    password: "involves a password"
  }

  def reason_text(why), do: Map.fetch!(@reasons, why)

  defp label(:pending), do: {"pending", "waiting"}
  defp label(:tentative), do: {"tentative", "1 · tentative"}
  defp label(:approved), do: {"approved", "1 · yours"}
  defp label(:skipped), do: {"skipped", "0 · skipped"}
  defp label({:held, _}), do: {"held", "held"}

  @impl true
  def render(assigns) do
    ~H"""
    <div id="t1" phx-hook="Keys" data-status={status(@run)} data-west={west(@run)}>
      <h1>Tentative One</h1>
      <p class="mute">Everything moves on 1. Only an inflection point stops.</p>

      <%= if @run == nil do %>
        <.form for={%{}} as={:plan} id="plan" phx-submit="start">
          <textarea name="plan[steps]" rows="8" placeholder="One step per line"></textarea>
          <p><button type="submit">Run</button> <span class="mute">One step per line.</span></p>
        </.form>
      <% else %>
        <div class="bar">
          <strong id="status">Status: <%= @run.status %></strong>
          <span id="west" class="mute">West: <%= @run.west %> keystrokes</span>
        </div>

        <ol id="steps">
          <%= for {s, i} <- Enum.with_index(@run.steps) do %>
            <li id={"step-#{i}"} class={elem(label(s.state), 0)}>
              <%= s.text %><span class="tag"><%= elem(label(s.state), 1) %></span>
            </li>
          <% end %>
        </ol>

        <%= if held = held_step(@run) do %>
          <p id="decide" class="decide">
            “<%= held.text %>” <%= reason_text(elem(held.state, 1)) %>. 1 clears it · 0 skips it
          </p>
        <% end %>

        <%= if @run.status in [:done, :stopped] do %>
          <p id="surface">Tentative: <%= Enum.join(Run.tentatives(@run), " · ") %></p>
        <% end %>

        <.form for={%{}} as={:say} id="otherwise" phx-submit="otherwise">
          <input name="say[text]" placeholder="Tell it otherwise (becomes the next step)" autocomplete="off" />
        </.form>
        <p><button id="reset" phx-click="reset">New run</button></p>
      <% end %>
    </div>
    """
  end

  defp held_step(%Run{steps: steps}), do: Enum.find(steps, &match?({:held, _}, &1.state))
  defp status(nil), do: "empty"
  defp status(r), do: r.status
  defp west(nil), do: 0
  defp west(r), do: r.west
end
