defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.GameServer

  def join("games:" <> game, payload, socket) do
    socket = assign(socket, :game, game)
    view = GameServer.view(game, socket.assigns[:user])
    IO.inspect(view)
    {:ok, %{"join" => game, "game" => view}, socket}

  end

  def handle_in("click", %{"i" => i}, socket) do
    view = GameServer.click(socket.assigns[:game], socket.assigns[:user], i)
    player = Enum.find(view.players, fn p -> p.name == socket.assigns[:user] end)

    if(player.cardsFlipped == 2) do
       {:reply, {:unflip, %{ "game" => view }}, socket}
     else
       {:reply, {:ok, %{ "game" => view }}, socket}
     end
   end

  def handle_in("unflip", payload, socket) do
    view = GameServer.unflip(socket.assigns[:game], socket.assigns[:user])
    {:reply, {:ok, %{ "game" => view }}, socket}

  end

  # def handle_in("restart", payload, socket) do
  #   game = Game.new()
  #   player = Game.default_player()
  #   socket = assign(socket, :game, game)
  #   {:reply, {:ok, %{ "game" => Game.client_view(game, player) }}, socket}
  # end

end
