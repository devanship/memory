import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
  ReactDOM.render(
    <Starter channel={channel}/>, 
    root);
}

class Starter extends React.Component {
  constructor(props) {
    super(props);
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

    this.findMatches = this.findMatches.bind(this)
  }

  gotView(view) {
    this.setState(view.game);
  }

  sendCard(card) {
    this.channel.push("click", { card: card })
    .receive("ok", this.gotView.bind(this))
    .receive("unflip", this.sendUnflip.bind(this))
  }

  sendUnflip(view) {
    let oldStatus = this.state.status;
    this.gotView(view)
    console.log(view)
    let newStatus = this.state.status;
    if(newStatus > oldStatus) {
      this.channel.push("click").receive("ok", this.gotView.bind(this))
    } else {
       setTimeout(() => {this.channel.push("unflip").receive("ok", this.gotView.bind(this))}, 1000);
    }
  }

  sendRestart() {
    this.channel.push("restart").receive("ok", this.gotView.bind(this))
  }

  findMatches(cards) {
    let matchedCards = [];
    cards = this.state.cards
    cards.map((card, i) => {
      if(card.isFlipped) {
        matchedCards.push(card)
      } 
    })
    return matchedCards.length
  }

  render() {
    const createCards = this.state.cards.map((card, i) => {
      return <Card card={card} click={this.sendCard.bind(this)} key={i}/>
    })

    return (
      <div>
      <div className="row cardsRow" style={{ 'flexWrap': 'wrap' }}>
      {createCards}
      </div>
      <div className="row">
      <div> Score: {this.state.score} </div>
      <Restart restart={this.sendRestart.bind(this)}/>
      </div>
      </div>
      )
  }
}

function Card(props) {
  let card = props.card
  let cardVal
  return (
    <div className="col-3">
    <div className="card" onClick={() => props.click(card)}>
    {card.isFlipped ? (cardVal = card.cardValue) : (cardVal = "?")}
    </div>
    </div>
    )
}

function Restart(props) {
  return <button onClick={() => props.restart()}>Restart</button>
}

