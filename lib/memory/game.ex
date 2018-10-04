defmodule Memory.Game do

  def new() do
    %{
      cards: shuffle(),
      thisCard: nil,
      firstCard: nil,
      score: 0,
      cardsFlipped: 0,
      clickable: true,
      status: 0
    }
  end

  def client_view(game) do
    %{
      cards: game.cards,
      thisCard: game.thisCard,
      firstCard: game.firstCard,
      score: game.score,
      cardsFlipped: game.cardsFlipped,
      clickable: game.clickable,
      status: game.status
    }
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

  def unflip(game) do 
    if game.cardsFlipped == 2 do
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
      |> Map.put(:cardsFlipped, 0)
      |> Map.put(:clickable, true)

    end
  end

  def checkMatch(game, i) do
    if game.cardsFlipped != 0 && (Enum.at(game.cards, game.firstCard).cardValue == Enum.at(game.cards, i).cardValue) do
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
      |> Map.put(:cardsFlipped, 0)
      |> Map.put(:clickable, true)
    else 
      game
      |> Map.put(:cardsFlipped, game.cardsFlipped + 1)
      |> Map.put(:clickable, game.cardsFlipped == 0)
    end
  end

  def click(game, i) do
    card = Enum.at(game.cards, i)
    if not card.isFlipped && game.clickable && (game.cardsFlipped == 0 || game.firstCard != i) do
      updatedGame = game
      |> Map.put(:thisCard, i)
      |> Map.put(:cards, flip(game.cards, i))

      card = Enum.at(updatedGame.cards, i)
      checkMatch(updatedGame, i)
      |> Map.put(:firstCard, if(game.cardsFlipped == 0, do: i, else: game.firstCard))
      |> Map.put(:score, game.score + 1)
    else
      game
    end
  end

  def restart() do
    new()
  end
end