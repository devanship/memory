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
      %{cardValue: "A", i: 1, isFlipped: false},
      %{cardValue: "A", i: 2, isFlipped: false},
      %{cardValue: "B", i: 3, isFlipped: false},
      %{cardValue: "B", i: 4, isFlipped: false},
      %{cardValue: "C", i: 5, isFlipped: false},
      %{cardValue: "C", i: 6, isFlipped: false},
      %{cardValue: "D", i: 7, isFlipped: false},
      %{cardValue: "D", i: 8, isFlipped: false},
      %{cardValue: "E", i: 9, isFlipped: false},
      %{cardValue: "E", i: 10, isFlipped: false},
      %{cardValue: "F", i: 11, isFlipped: false},
      %{cardValue: "F", i: 12, isFlipped: false},
      %{cardValue: "G", i: 13, isFlipped: false},
      %{cardValue: "G", i: 14, isFlipped: false},
      %{cardValue: "H", i: 15, isFlipped: false},
      %{cardValue: "H", i: 16, isFlipped: false}
    ]
    |> Enum.shuffle()
  end

  # https://stackoverflow.com/questions/31990134/how-to-convert-map-keys-from-strings-to-atoms-in-elixir
  defp string_to_atom(l) do 
    for {key, val} <- l, into: %{}, do: {String.to_atom(key), val}
  end

  defp flip(cards, card) do
    ind = Enum.find_index(cards, fn c -> c.i == card.i end)
    List.replace_at(cards, ind, %{
      cardValue: Enum.at(cards, ind).cardValue,
      i: Enum.at(cards, ind).i,
      isFlipped: true,
      })
  end

  def unflip(game) do 
    if game.cardsFlipped == 2 do
      cardId = Enum.find_index(game.cards, fn(x) -> x.i == game.thisCard end)
      firstId = Enum.find_index(game.cards, fn(x) -> x.i == game.firstCard end)

      newCards =
      List.replace_at(game.cards,
        cardId,
        %{cardValue: Enum.at(game.cards, cardId).cardValue,
        i: Enum.at(game.cards, cardId).i,
        isFlipped: false,
        })
      |> List.replace_at(firstId,
        %{cardValue: Enum.at(game.cards, firstId).cardValue,
        i: Enum.at(game.cards, firstId).i,
        isFlipped: false,
        })
      Map.put(game, :cards, newCards)
      |> Map.put(:cardsFlipped, 0)
      |> Map.put(:clickable, true)

    end
  end

  def checkMatch(game, card) do
    if game.cardsFlipped != 0 && (Enum.at(game.cards, Enum.find_index(game.cards, fn(x) -> x.i == game.firstCard end)).cardValue == card.cardValue) do
      cardId = Enum.find_index(game.cards, fn(x) -> x.i == card.i end)
      firstId = Enum.find_index(game.cards, fn(x) -> x.i == game.firstCard end)

      updatedCards =
      List.replace_at(game.cards,
        cardId,
        %{cardValue: Enum.at(game.cards, cardId).cardValue,
        i: Enum.at(game.cards, cardId).i,
        isFlipped: true,
        })                  
      |> List.replace_at(firstId,
        %{cardValue: Enum.at(game.cards, firstId).cardValue,
        i: Enum.at(game.cards, firstId).i,
        isFlipped: true,
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

  def click(game, card) do
    updatedCard = string_to_atom(card)
    if not updatedCard.isFlipped && game.clickable && (game.cardsFlipped == 0 || game.firstCard != updatedCard.i) do
      updatedGame = game
      |> Map.put(:thisCard, updatedCard.i)
      |> Map.put(:cards, flip(game.cards, updatedCard))

      updatedCard = Enum.at(updatedGame.cards, Enum.find_index(updatedGame.cards, fn c -> c.i == updatedCard.i end))
      checkMatch(updatedGame, updatedCard)
      |> Map.put(:firstCard, if(game.cardsFlipped == 0, do: updatedCard.i, else: game.firstCard))
      |> Map.put(:score, game.score + 1)
      |> IO.inspect
    else
      game
    end
  end

  def restart() do
    new()
  end
end