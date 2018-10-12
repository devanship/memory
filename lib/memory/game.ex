defmodule Memory.Game do

  defp default_player do
    player =
    %{
      name: nil,
      score: 0,
      isActive: false,
      cardsFlipped: 0,
      playerId: nil
    }
    [player, player]
  end

  def new do
    %{
      cards: shuffle(),
      thisCard: nil,
      firstCard: nil,
      clicks: 0,
      clickable: true,
      status: 0,
      players: default_player(),
      observers: []
    }
  end

  def client_view(game, user) do
    %{
      cards: game.cards,
      thisCard: game.thisCard,
      firstCard: game.firstCard,
      clicks: game.clicks,
      clickable: game.clickable,
      status: game.status,
      players: game.players,
      observers: game.observers
    }
  end

  def add_user(game, name) do
    players = Map.get(game, :players)
    p1 = Enum.at(players, 0)
    p2 = Enum.at(players, 1)
    p1_id = Map.get(p1, :name)


      game = if !p1_id do
        p1 = %{p1 | name: name, playerId: 0, isActive: true}
        Map.put(game, :players, [p1, p2])
      else
        if p1_id != name do
          p2 = %{p2 | name: name, playerId: 1, isActive: false}
          Map.put(game, :players, [p1, p2])
        end
      end
    game
  end

  defp shuffle() do
    [
      %{cardValue: "A", isFlipped: false},
      %{cardValue: "A", isFlipped: false},
      %{cardValue: "B", isFlipped: false},
      %{cardValue: "B", isFlipped: false},
      %{cardValue: "C", isFlipped: false},
      %{cardValue: "C", isFlipped: false},
      %{cardValue: "D", isFlipped: false},
      %{cardValue: "D", isFlipped: false},
      %{cardValue: "E", isFlipped: false},
      %{cardValue: "E", isFlipped: false},
      %{cardValue: "F", isFlipped: false},
      %{cardValue: "F", isFlipped: false},
      %{cardValue: "G", isFlipped: false},
      %{cardValue: "G", isFlipped: false},
      %{cardValue: "H", isFlipped: false},
      %{cardValue: "H", isFlipped: false}
    ]
    |> Enum.shuffle()
  end

  def flip(cards, i) do
    List.replace_at(cards, i,
      %{cardValue: Enum.at(cards, i).cardValue,
        isFlipped: true
        })
  end

  def unflip(game, player) do
    player = Enum.find(game.players, fn p -> p.name == player end)
    if player.cardsFlipped == 2 do
      cardId = game.thisCard
      firstId = game.firstCard

      updatedCards =
      List.replace_at(game.cards,
        game.thisCard,
        %{cardValue: Enum.at(game.cards, game.thisCard).cardValue,
          isFlipped: false
          })
      |> List.replace_at(game.firstCard,
        %{cardValue: Enum.at(game.cards, game.firstCard).cardValue,
          isFlipped: false
          })

      # updatedPlayers = 
      # List.replace_at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end),
      #   %{name: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).name,
      #     score: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).score + 1,
      #     isActive: false,
      #     cardsFlipped: 0,
          # playerId: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).playerId})

          updatedPlayers = Enum.map(game.players, fn (p) -> %{p | isActive: !p.isActive} end)

      game
      |> Map.put(:cards, updatedCards)
      |> Map.put(:clickable, true)
      |> Map.put(:players, updatedPlayers)
    end
  end

  def checkMatch(game, player, i) do
    if player.cardsFlipped != 0 && (Enum.at(game.cards, game.firstCard).cardValue == Enum.at(game.cards, i).cardValue) do
      updatedCards =
      List.replace_at(game.cards, i,
        %{cardValue: Enum.at(game.cards, i).cardValue,
          isFlipped: true
          })
      |> List.replace_at(game.firstCard,
        %{cardValue: Enum.at(game.cards, game.firstCard).cardValue,
          isFlipped: true
          })

      # updatedPlayers = 
      # List.replace_at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end),
      #   %{name: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).name,
      #     score: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).score + 1,
      #     isActive: false,
      #     cardsFlipped: 0,
      #     playerId: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).playerId})
      updatedPlayers = Enum.map(game.players, fn (p) -> %{p | isActive: !p.isActive} end)

      game
      |> Map.put(:cards, updatedCards)
      |> Map.put(:status, game.status + 1)
      |> Map.put(:clickable, true)
      |> Map.put(:players, updatedPlayers)

    else
      updatedPlayers = 
      List.replace_at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end),
        %{name: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).name,
          score: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).score,
          isActive: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).isActive,
          cardsFlipped: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).cardsFlipped + 1,
          playerId: Enum.at(game.players, Enum.find_index(game.players, fn p -> p.name == player.name end)).playerId})

      game
      |> Map.put(:players, updatedPlayers)
      |> Map.put(:clickable, player.cardsFlipped == 0)
    end
  end

  def switchPlayer(game, player) do
    cond do
      player.playerId == 0 ->
        player
        |> Map.put(:isActive, false)
        nextPlayer = Enum.at(game.players, 1)
        |> Map.put(:isActive, true)
      player.playerId == 1 ->
        player
        |> Map.put(:isActive, false)
        nextPlayer = Enum.at(game.players, 0)
        |> Map.put(:isActive, true)
      player.playerId == -1 ->
        player
        |> Map.put(:isActive, false)
    end
  end

  def setId(game, player) do
    cond do
      player == Enum.at(game.player, 0) ->
        Map.put(player, :playerId, 0)
      player == Enum.at(game.player, 1) ->
        Map.put(player, :playerId, 1)
      true ->
        Map.put(player, :playerId, -1)
    end
  end

  def click(game, player, i) do
    player = Enum.find(game.players, fn p -> p.name == player end)
    if player.isActive do
      card = Enum.at(game.cards, i)
      if not card.isFlipped && game.clickable && (player.cardsFlipped == 0 || game.firstCard != i) do
        updatedGame = game
        |> Map.put(:thisCard, i)
        |> Map.put(:cards, flip(game.cards, i))

        card = Enum.at(updatedGame.cards, i)
        checkMatch(updatedGame, player, i)
        |> Map.put(:firstCard, if(player.cardsFlipped == 0, do: i, else: game.firstCard))
        |> Map.put(:clicks, game.clicks + 1)
      else
        game
      end
    end
  end

  def restart(game, user) do
    new()
  end
end
