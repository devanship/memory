import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

<<<<<<< HEAD
export default function game_init(root, channel) {
  ReactDOM.render(
    <Starter channel={channel}/>, 
    root);
=======
export default function game_init(root) {
  ReactDOM.render(
    <Starter width={4} height={4}/>, 
    root);
}

//https://www.youtube.com/watch?v=cZ90wJXtsQQ 
const states = {FIRST_CARD: "Pick first card.", SECOND_CARD: "Pick second card.", WRONG: "WRONG", FINISHED: "FINISHED"};

//https://stackoverflow.com/questions/38101522/how-to-render-random-objects-from-an-array-in-react
function shuffle(a) {
  var j, x, i;
  for(i = a.length - 1; i > 0; i--) {
    j = Math.floor(Math.random() * (i + 1));
    x = a[i];
    a[i] = a[j];
    a[j] = x;
  }
  return a;
}

//https://stackoverflow.com/questions/966225/how-can-i-create-a-two-dimensional-array-in-javascript
function createArray(x, y) {
  return Array.apply(null, Array(x)).map(function(e) {
    return Array(y);
  });
>>>>>>> d7a346bd84f9c28db386f9dd770d963c03f7ee39
}

class Starter extends React.Component {
  constructor(props) {
    super(props);
<<<<<<< HEAD
    this.channel = props.channel;

    this.state = {
      cards: [],
      thisCard: null,
      firstCard: null,
      cardsFlipped: 0,
      score: 0,
      clickable: true,
      status: 0
    }

    this.channel.join()
    .receive("ok", this.gotView.bind(this))
    .receive("error", resp => { console.log("Unable to join", resp) });

    this.click = this.click.bind(this)
    this.unflip = this.unflip.bind(this)
    this.restart = this.restart.bind(this)
  }

  gotView(view) {
    this.setState(view.game);
  }

  click(i) {
    this.channel.push("click", { i: i })
    .receive("ok", this.gotView.bind(this))
    .receive("unflip", this.unflip.bind(this))
  }

  unflip(view) {
    let oldStatus = this.state.status;
    this.gotView(view)
    console.log(view)
    let updatedStatus = this.state.status;
    if(updatedStatus > oldStatus) {
      this.channel.push("click").receive("ok", this.gotView.bind(this))
    } else {
       setTimeout(() => {this.channel.push("unflip").receive("ok", this.gotView.bind(this))}, 500);
    }
=======

    this.state = {
      cards: this.shuffleCards(),
      gameState: states.FIRST_CARD,
      first: null,
      second: null,
      score: 0
    }

    this.click = this.click.bind(this);
    this.restart = this.restart.bind(this);
    this.shuffleCards = this.shuffleCards.bind(this);
    this.finished = this.finished.bind(this);  
  }

  shuffleCards() {
    //2D array with dimensions of gameboard (4X4)
    var cards = createArray(this.props.width, this.props.height);
    const letters = ["A", "B", "C", "D", "E", "F", "G", "H"]
    let dup = _.concat(letters, letters)

    //Then it shuffles the array with the duplicate objecst
    shuffle(dup);

    //Adds properties to the objects in the array
    let main = dup.map(function(val) {
      return {
        cardValue: val,
        isFlipped: false,
        row: null,
        col: null
      }
    });

    //Adds the values in the array of objects into a 2D array to manage placement of items in the gameboard
    for(var r=0; r < this.props.height; r++) {
      for (var c=0; c < this.props.width; c++) {
        cards[r][c] = {cardValue: main[r*this.props.width+c].cardValue, isFlipped:false, row: r, col: c}
      }
    };

    return cards;
  }

  //Handles click on a card
  click(card) {

    if(!card.isFlipped) {
      switch(this.state.gameState) {

        //If indicated to select first card, the card selected will be flipped and set as the first card. 
        //Once card is select, player will be prompted to select second card.
        //Score will increase by 1 per click
        case states.FIRST_CARD:
          this.state.cards[card.row][card.col].isFlipped=true;
          this.setState({
            cards: this.state.cards,
            first: card,
            gameState: states.SECOND_CARD,
            score: this.state.score + 1
          });
        break;

        //If indicated to select second card, the card selected will be flipped.
        //If the value of the second card == the value of the first card, the player will be indicated to select a first card again.
        //If the value of the second card !== the value of the first card, the seleced card will be set as the second card.
        //Player will be prompted as Wrong.
        case states.SECOND_CARD:
          this.state.cards[card.row][card.col].isFlipped=true;

          if(this.state.first.cardValue == card.cardValue) {
            this.setState({
              gameState: states.FIRST_CARD,
              cards: this.state.cards,
              score: this.state.score + 1 
            })
          } else {
            this.setState({
              gameState: states.WRONG,
              cards: this.state.cards,
              second: card,
              score: this.state.score + 1 
            })
          }
        break;

        //If cards do not match, the first and second cards will flip over.
        //The selected card will be flipped to show value and will be set as the first card.
        case states.WRONG:
          this.state.cards[this.state.first.row][this.state.first.col].isFlipped=false;
          this.state.cards[this.state.second.row][this.state.second.col].isFlipped=false;
          this.state.cards[card.row][card.col].isFlipped=true;
          this.setState({
            gameState: states.SECOND_CARD,
            cards: this.state.cards,
            first: card,
            score: this.state.score + 1
          })
        break;
      }
    }
  }

  //Resets the game
  restart()  {
    this.setState({
      cards: this.shuffleCards(),
      gameState: states.FIRST_CARD,
      first: null,
      second: null,
      score: 0
    })
  }

  finished() {
  }
  
  render() {
    let cardVal;
    const createCards = this.state.cards.map((row, r) => 
      <tr key={r}>
        {row.map((card, i) => 
          <td key={i} onClick={() => this.click(card)}>
            <div className="card">
              {card.isFlipped ? (<div className="cardValue">{card.cardValue}</div>) : (cardVal = <div className="guess">?</div>)}
            </div>
          </td>
        )}
      </tr>)

      return (
        <div>

          <h1> Memory Game </h1>

          <div className="container">
            <table className="row">
              <tbody className="column-30">{createCards}</tbody>
            </table>
          </div>

          <div className="row">
            <div> Score: {this.state.score} </div>
            <button className="button column column-20" onClick={this.restart}>Restart</button>
          </div>
        </div>

    )
>>>>>>> d7a346bd84f9c28db386f9dd770d963c03f7ee39
  }

  restart() {
    this.channel.push("restart").receive("ok", this.gotView.bind(this))
  }

  render() {

    const createCards = this.state.cards.map((card, i) => {
    let cardVal
    return (
      <div className="col-3" key={i}>
        <div className="card" onClick={() => this.click(i)}>
          {card.isFlipped ? (cardVal = <div className="cardValue">{card.cardValue}</div>) : (cardVal = <div className="guess">?</div>)}
        </div>
      </div>
      )
    })

    return (
      <div>
        <div className="row cardsRow" style={{ 'flexWrap': 'wrap' }}>
          {createCards}
        </div>
        <div className="row">
          <div> Score: {this.state.score} </div>
          <button onClick={() => this.restart()}>Restart</button>
        </div>
      </div>
    )
  }
}
