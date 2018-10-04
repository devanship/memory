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
      %{cardValue: "A", i: 1, isFlipped: false, status: "availabe"},
      %{cardValue: "A", i: 2, isFlipped: false, status: "availabe"},
      %{cardValue: "B", i: 3, isFlipped: false, status: "availabe"},
      %{cardValue: "B", i: 4, isFlipped: false, status: "availabe"},
      %{cardValue: "C", i: 5, isFlipped: false, status: "availabe"},
      %{cardValue: "C", i: 6, isFlipped: false, status: "availabe"},
      %{cardValue: "D", i: 7, isFlipped: false, status: "availabe"},
      %{cardValue: "D", i: 8, isFlipped: false, status: "availabe"},
      %{cardValue: "E", i: 9, isFlipped: false, status: "availabe"},
      %{cardValue: "E", i: 10, isFlipped: false, status: "availabe"},
      %{cardValue: "F", i: 11, isFlipped: false, status: "availabe"},
      %{cardValue: "F", i: 12, isFlipped: false, status: "availabe"},
      %{cardValue: "G", i: 13, isFlipped: false, status: "availabe"},
      %{cardValue: "G", i: 14, isFlipped: false, status: "availabe"},
      %{cardValue: "H", i: 15, isFlipped: false, status: "availabe"},
      %{cardValue: "H", i: 16, isFlipped: false, status: "availabe"}
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
      status: Enum.at(cards, ind).status
      })
  end

  def unflip(game) do 
    if game.cardsFlipped == 2 do
      cardId = getInd(game.cards, game.thisCard)
      firstId = getInd(game.cards, game.firstCard)

      newCards =
      List.replace_at(game.cards,
        cardId,
        %{cardValue: Enum.at(game.cards, cardId).cardValue,
        i: Enum.at(game.cards, cardId).i,
        isFlipped: false,
        status: Enum.at(game.cards, cardId).status})
      |> List.replace_at(firstId,
        %{cardValue: Enum.at(game.cards, firstId).cardValue,
        i: Enum.at(game.cards, firstId).i,
        isFlipped: false,
        status: Enum.at(game.cards, cardId).status})
      Map.put(game, :cards, newCards)
      |> Map.put(:cardsFlipped, 0)
      |> Map.put(:clickable, true)

    end
  end

  defp getInd(cards, i) do
    Enum.find_index(cards, fn(x) -> x.i == i end)
  end

  def checkMatch(game, card) do
    if game.cardsFlipped != 0 && (Enum.at(game.cards, getInd(game.cards, game.firstCard)).cardValue == card.cardValue) do
      cardId = getInd(game.cards, card.i)
      firstId = getInd(game.cards, game.firstCard)

      newCards =
      List.replace_at(game.cards,
        cardId,
        %{cardValue: Enum.at(game.cards, cardId).cardValue,
        i: Enum.at(game.cards, cardId).i,
        isFlipped: true,
        status: "matched"})
      |> List.replace_at(firstId,
        %{cardValue: Enum.at(game.cards, firstId).cardValue,
        i: Enum.at(game.cards, firstId).i,
        isFlipped: true,
        status: "matched"})
      Map.put(game, :cards, newCards)
      |> Map.put(:status, game.status + 1)
      |> Map.put(:cardsFlipped, 0)
      |> Map.put(:clickable, game.cardsFlipped == 0)
    else 
      game
      |> Map.put(:cardsFlipped, game.cardsFlipped + 1)
      |> Map.put(:clickable, game.cardsFlipped == 0)
    end
  end

  def click(game, card) do
    newCard = string_to_atom(card)
    if newCard.status != "matched" && game.clickable && (game.cardsFlipped == 0 || game.firstCard != newCard.i) do
      newGame = game
      |> Map.put(:thisCard, newCard.i)
      |> Map.put(:cards, flip(game.cards, newCard))

      newCard = Enum.at(newGame.cards, Enum.find_index(newGame.cards, fn c -> c.i == newCard.i end))
      checkMatch(newGame, newCard)
      |> Map.put(:firstCard, if(game.cardsFlipped == 0, do: newCard.i, else: game.firstCard))
      |> Map.put(:score, game.score + 1)
      |>IO.inspect
    else
      game
    end
  end

  def restart() do
    new()
  end
end