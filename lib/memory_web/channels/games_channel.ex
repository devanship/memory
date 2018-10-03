defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.Game

  def join("games:" <> name, payload, socket) do
      if authorized?(payload) do
        game = Memory.GameBackup.load(name) || Game.new()
        socket = socket
        |> assign(:game, game)
        |> assign(:name, name)
        {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
      else
        {:error, %{reason: "unauthorized"}}
      end
    end

    # Sends the clicked card to clicked()
  def handle_in("click", %{"card" => c}, socket) do
    # Call clicked() with the current state and card
    game = Game.click(socket.assigns[:game], c)
    # Update game in socket assigns
    socket = assign(socket, :game, game)
    Memory.GameBackup.save(socket.assigns[:name], socket.assigns[:game])
    if(game.cardsFlipped == 2) do
      {:reply, {:unflip, %{ "game" => Game.client_view(game) }}, socket}
      IO.inspect(game.firstCard)
    else
      {:reply, {:ok, %{ "game" => Game.client_view(game) }}, socket}
    end
  end

  # Sends a request to unflip the two cards
  def handle_in("unflip", %{}, socket) do
    # Call unflip() with the current state
    game = Game.unflip(socket.assigns[:game])
    # Update game in socket assigns
    socket = assign(socket, :game, game)
    # Save game after generating new state
    Memory.GameBackup.save(socket.assigns[:name], socket.assigns[:game])
    # Send an ok message
    {:reply, {:ok, %{ "game" => Game.client_view(game) }}, socket}
  end

  # Sends a reset request
  def handle_in("restart", %{}, socket) do
    # Call new() to get a fresh state
    game = Game.new()
    # Update game in socket assigns
    socket = assign(socket, :game, game)
    # Save game after generating new state
    # Send an ok message
    {:reply, {:ok, %{ "game" => Game.client_view(game) }}, socket}
  end

  defp authorized?(_payload) do
    true
  end

end
