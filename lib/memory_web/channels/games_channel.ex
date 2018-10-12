defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.GameServer

  def join("games:" <> game, payload, socket) do
    socket = assign(socket, :game, game)
    view = GameServer.view(game, socket.assigns[:user])
    {:ok, %{"join" => game, "game" => view}, socket}

  end

  def handle_in("click", %{"i" => i}, socket) do
    view = GameServer.click(socket.assigns[:game], socket.assigns[:user], i)
    |> IO.inspect
    player = Enum.find(view.players, fn p -> p.name == socket.assigns[:user] end)
    broadcast(socket, "click", view)
    if(player.cardsFlipped == 2) do
       {:reply, {:unflip, %{ "game" => view }}, socket}
     else
       {:noreply, socket}
     end
   end

  def handle_in("unflip", payload, socket) do
    view = GameServer.unflip(socket.assigns[:game], socket.assigns[:user])
    broadcast(socket, "unflip", view)
    {:reply, {:ok, %{ "game" => view }}, socket}

  end

  def handle_in("restart", payload, socket) do
    view = GameServer.restart(socket.assigns[:game], socket.assigns[:user])
    broadcast(socket, "restart", view)
    {:reply, {:ok, %{ "game" => view }}, socket}
  end

end
