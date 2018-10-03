defmodule Memory.Game do

  import Elixir.List
  
  def new() do
    %{
      cards: shuffle(),
      thisCard: nil,
      firstCard: nil,
      score: 0,
      cardsFlipped: 0,
      clickable: true
    }
  end

  def client_view(game) do
    %{
      cards: game.cards,
      thisCard: game.thisCard,
      firstCard: game.firstCard,
      score: game.score,
      cardsFlipped: game.cardsFlipped,
      clickable: game.clickable
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
    # |> Enum.chunk_every(4)
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
        isFlipped: true
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
            isFlipped: false})
        |> List.replace_at(firstId,
             %{cardValue: Enum.at(game.cards, firstId).cardValue,
              i: Enum.at(game.cards, firstId).i,
              isFlipped: false})
      Map.put(game, :cards, newCards)
      |> Map.put(:cardsFlipped, 0)
      |> Map.put(:clickable, true)
      |> Map.put(:thisCard, nil)
      |> Map.put(:firstCard, nil)
    else 
      game
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
            isFlipped: Enum.at(game.cards, cardId).isFlipped})
        |> List.replace_at(firstId,
             %{cardValue: Enum.at(game.cards, firstId).cardValue,
              i: Enum.at(game.cards, firstId).i,
              isFlipped: Enum.at(game.cards, firstId).isFlipped})
      Map.put(game, :cards, newCards)
    else 
      game
    end
  end

   def click(game, card) do
    newCard = string_to_atom(card)
    if not newCard.isFlipped && game.clickable && (game.cardsFlipped == 0 || game.firstCard != newCard.i) do 
        newGame = game
        |> Map.put(:thisCard, newCard.i)
        |> Map.put(:cards, flip(game.cards, newCard))

        newCard = Enum.at(newGame.cards, Enum.find_index(newGame.cards, fn c -> c.i == newCard.i end))
        checkMatch(newGame, newCard)
        |> Map.put(:firstCard, if(game.cardsFlipped == 0, do: newCard.i, else: game.firstCard))
        |> Map.put(:clickable, game.cardsFlipped == 0)
        |> Map.put(:score, game.score + 1)
        |> Map.put(:cardsFlipped, game.cardsFlipped + 1)
        |> IO.inspect
      else
        game
    end
   end

   def restart(game) do
    new()
   end

end