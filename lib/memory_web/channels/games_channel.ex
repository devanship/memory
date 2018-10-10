defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.GameServer

  def join("games:" <> game, payload, socket) do
    socket = assign(socket, :game, game)
    view = GameServer.view(game, socket.assigns[:user])
    {:ok, %{"join" => game, "game" => view}, socket}
  end

  # def handle_in("click", %{"i" => i}, socket) do
  #   view = GameServer.guess(socket.assigns[:game], socket.assigns[:user], i)
  #   # if(game.cardsFlipped == 2) do
  #   #   {:reply, {:unflip, %{ "game" => view }}, socket}
  #   # else
  #   #   {:reply, {:ok, %{ "game" => view }}, socket}
  #   # end
  #   {:reply, {:ok, %{ "game" => view }}, socket}
  # end

  def handle_in("unflip", payload, socket) do
    Memory.GameBackup.save(socket.assigns[:name], socket.assigns[:game])
    view = GameServer.unflip(socket.assigns[:game], socket.assigns[:user])
    {:reply, {:ok, %{ "game" => view }}, socket}
  end

  def handle_in("restart", payload, socket) do
    game = Game.new()
    player = Game.default_player()
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game, player) }}, socket}
  end

end
