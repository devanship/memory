defmodule Memory.Game do

  def new() do
    %{
      cards: shuffle(),
      thisCard: nil,
      firstCard: nil,
      score: 0,
      clickable: true,
      status: 0,
      players: [],
    }
  end

  def new(players) do
    players = Enum.map players, fn {name, info} ->
      {name, %{ default_player() | score: info.score || 0 }}
    end
    Map.put(new(), :players, Enum.into(players, %{}))
  end

  def default_player() do
    %{
      score: 0,
      isActive: true,
      cardsFlipped: 0,
      playerId: nil
    }
  end

  def client_view(game, player) do
    players = Enum.map game.players, fn {playerName, playerInfo} ->
      %{ name: playerName,
          score: playerInfo.score,
          isActive: playerInfo.isActive,
          cardsFlipped: playerInfo.cardsFlipped,
          playerId: nil
        }
    end

    %{
      cards: game.cards,
      thisCard: game.thisCard,
      firstCard: game.firstCard,
      score: game.score,
      clickable: game.clickable,
      status: game.status,
      players: Enum.map(game.players, fn p -> setPlayerId(game, p) end)
    }
  end

  def setPlayerId(game, player) do
    cond do
      player == Enum.at(game.player, 0) ->
        Map.put(player, :playerId, 0)
      player == Enum.at(game.player, 1) ->
        Map.put(player, :playerId, 1)
      true ->
        Map.put(player, :playerId, -1)
    end
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
      Map.put(game, :cards, updatedCards)
      |> Map.put(:clickable, true)

      player
      |> Map.put(:cardsFlipped, 0)
      |> switchPlayer(game)
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
      Map.put(game, :cards, updatedCards)
      |> Map.put(:status, game.status + 1)
      |> Map.put(:clickable, true)

      player
      |> Map.put(:cardsFlipped, 0)
    else
      game
      |> Map.put(:clickable, game.cardsFlipped == 0)

      player
      |> Map.put(:cardsFlipped, game.cardsFlipped + 1)
    end
  end

  # def isPlayerActive(game, player) do
  #   players = game.players
  #   playerInfo = players[:player]
  #   isActive = playerInfo[:isActive]
  #   return isActive
  # end

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

  def click(game, player, i) do
    if player.isActive do
      card = Enum.at(game.cards, i)
      if not card.isFlipped && game.clickable && (player.cardsFlipped == 0 || game.firstCard != i) do
        updatedGame = game
        |> Map.put(:thisCard, i)
        |> Map.put(:cards, flip(game.cards, i))

        card = Enum.at(updatedGame.cards, i)
        checkMatch(updatedGame, player, i)
        |> Map.put(:firstCard, if(game.cardsFlipped == 0, do: i, else: game.firstCard))
        |> Map.put(:score, game.score + 1)

        switchPlayer(game, player)
      else
        game
      end
    end
  end

  def restart() do
    new()
  end
end
