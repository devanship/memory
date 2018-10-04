defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.Game

  def join("games:" <> name, payload, socket) do
    game = Memory.GameBackup.load(name) || Game.new()
    socket = socket
    |> assign(:game, game)
    |> assign(:name, name)
    {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
  end

  def handle_in("click", %{"card" => c}, socket) do
    game = Game.click(socket.assigns[:game], c)
    socket = assign(socket, :game, game)
    Memory.GameBackup.save(socket.assigns[:name], socket.assigns[:game])
    if(game.cardsFlipped == 2) do
      {:reply, {:unflip, %{ "game" => Game.client_view(game) }}, socket}
    else
      {:reply, {:ok, %{ "game" => Game.client_view(game) }}, socket}
    end
  end

  def handle_in("unflip", payload, socket) do
    game = Game.unflip(socket.assigns[:game])
    socket = assign(socket, :game, game)
    Memory.GameBackup.save(socket.assigns[:name], socket.assigns[:game])
    {:reply, {:ok, %{ "game" => Game.client_view(game) }}, socket}
  end

# Sends a reset request
def handle_in("restart", payload, socket) do
  game = Game.new()
  socket = assign(socket, :game, game)
  {:reply, {:ok, %{ "game" => Game.client_view(game) }}, socket}
end

end
