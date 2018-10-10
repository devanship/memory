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


  ## Implementations
  def init(state) do
    {:ok, state}
  end

  def handle_call({:view, game, user}, _from, state) do
    gg = Map.get(state, game, Game.new)
    {:reply, Game.client_view(gg, user), Map.put(state, game, gg)}
  end

# TODO create this method
  def add_user(game, player) do
    players = Enum.map game.players, fn {name, info} ->
      {name, %{ Game.default_player() | score: info.score || 0 }}
    end
    Map.put(Game.default_player(), :players, Enum.into(game.players, %{}))
  end

end
