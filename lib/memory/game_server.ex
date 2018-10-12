defmodule Memory.GameServer do
  use GenServer

  alias Memory.Game

  ## Client Interface
  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def view(game, user) do
    GenServer.call(__MODULE__, {:view, game, user})
  end

  def click(game, user, i) do
    GenServer.call(__MODULE__, {:click, game, user, i})
  end

  def unflip(game, user) do
    GenServer.call(__MODULE__, {:unflip, game, user})
  end

  def restart() do
    GenServer.call(__MODULE__, {:restart})
  end

  ## Implementations
  def init(state) do
    {:ok, state}
  end

  def handle_call({:view, game, user}, _from, state) do
    gg = Map.get(state, game, Game.new)
    |> Game.add_user(user)
    {:reply, Game.client_view(gg, user), Map.put(state, game, gg)}
  end

  def handle_call({:unflip, game, user}, _from, state) do
    gg = Map.get(state, game)
    |> Game.unflip(user)
    view = Game.client_view(gg, user)
    MemoryWeb.Endpoint.broadcast("games:" <> game, "unflip", view)
    {:reply, view, Map.put(state, game, gg)}
  end

  def handle_call({:click, game, user, i}, _from, state) do 
    gg = Map.get(state, game)
    |> Game.click(user, i)
    view = Game.client_view(gg, user)
    MemoryWeb.Endpoint.broadcast("games:" <> game, "click", view)
    {:reply, view, Map.put(state, game, gg)}
  end

  def handle_call({:restart, game, user}, _from, state) do 
    gg = Map.get(state, game, Game.new())
    |> Game.restart(user)
    view = Game.client_view(gg, user)
    MemoryWeb.Endpoint.broadcast("games:" <> game, "click", view)
    {:reply, view, Map.put(state, game, gg)}
  end

end
