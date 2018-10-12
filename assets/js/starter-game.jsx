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
      clicks: 0,
      clickable: true,
      status: 0,
      players: [],
      observers: [],
    }

    this.channel.on("click", (game) => {
      this.setState(game);
    });

    this.channel.on("unflip", (game) => {
      this.setState(game);
    });

    this.channel.on("restart", (game) => {
      this.setState(game);
    });

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
    // .receive("ok", this.gotView.bind(this))
    .receive("unflip", this.unflip.bind(this))
  }

  unflip(view) {
    //  let oldStatus = this.state.status;
    this.gotView(view)
    // let updatedStatus = this.state.status;
    // if(updatedStatus > oldStatus) {
    //    this.channel.push("click").receive("ok", this.gotView.bind(this))
    // } else {
        setTimeout(() => {this.channel.push("unflip")}, 500);
    // }
  }

  restart() {
    this.channel.push("restart")
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
    const players = this.state.players.map((player, i) => {
      return (
        <div className="col-3" key={i}>
        <div className="player">
          Player: {player.name}
        </div>
      </div>
      )
    })


      if(this.state.players.length >= 2) {
        return (
          <div>
            <div className="row names">{players}</div>
            <div className="row cardsRow" style={{ 'flexWrap': 'wrap' }}>
              {createCards}
            </div>
            <div className="row">
              <div> Click: {this.state.clicks} </div>
              <button onClick={() => this.restart()}>Restart</button>
            </div>
          </div>
        )
      } else {
        return (
          <div className="waiting">Waiting for another player...</div>
        )
      }
  }
}
