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

    this.sendCard = this.sendCard.bind(this)
    this.sendUnflip = this.sendUnflip.bind(this)
    this.sendRestart = this.sendRestart.bind(this)
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
    let updatedStatus = this.state.status;
    if(updatedStatus > oldStatus) {
      this.channel.push("click").receive("ok", this.gotView.bind(this))
    } else {
       setTimeout(() => {this.channel.push("unflip").receive("ok", this.gotView.bind(this))}, 500);
    }
  }

  sendRestart() {
    this.channel.push("restart").receive("ok", this.gotView.bind(this))
  }

  render() {
    const createCards = this.state.cards.map((card, i) => {
    let cardVal
    return (
      <div className="col-3" key={i}>
        <div className="card" onClick={() => this.sendCard(card)}>
          {card.isFlipped ? (cardVal = card.cardValue) : (cardVal = "?")}
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
          <button onClick={() => this.sendRestart()}>Restart</button>
        </div>
      </div>
    )
  }
}

