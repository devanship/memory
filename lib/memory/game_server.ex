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

  def add_user(game, id) do
    GenServer.call(__MODULE__, {:add_user, game, id})
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
    gg = Map.get(state, game, Game.new)
    |> Game.unflip(user)
    view = Game.client_view(gg, user)
    {:reply, view, Map.put(state, game, gg)}
  end

  def handle_call({:click, game, user, i}, _from, state) do 
    gg = Map.get(state, game, Game.new)
    |> Game.click(user, i)
    view = Game.client_view(gg, user)
    {:reply, view, Map.put(state, game, gg)}
  end
end
