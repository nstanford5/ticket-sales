import { loadStdlib, ask } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib();

// sleep function for delaying console messages
function sleep(milliseconds){
  const date = Date.now();
  let currentDate = null;
  do {
    currentDate = Date.now();
  } while (currentDate - date < milliseconds);
}

//const startingBalance = stdlib.parseCurrency(500);
//const accStarsky = await stdlib.newTestAccount(startingBalance);
//const accHutch = await stdlib.newTestAccount(startingBalance);

console.log('Welcome to Morra - Starsky and Hutch!');
sleep(2000);
console.log('And the crowd goes wild...');
sleep(2000);
console.log('..aaahhhhhhh..');
sleep(2000);
console.log('A cherry red Gran Torino rips across the screen');
sleep(2000);

// ask needs to be implemented from the stdlib
const isStarsky = await ask.ask(
  `Starsky, is that you?`,
  ask.yesno
);

const who = isStarsky ? 'Starsky' : 'Hutch';

sleep(2000);
console.log(`Starting Morra as ${who}`);

const createAcc = await ask.ask(
  `Would you like to create an account?`,
  ask.yesno
);

let acc = null;
if(createAcc){
  // create new test account and fund with 1000 tokens
  acc = await stdlib.newTestAccount(stdlib.parseCurrency(1000));
} else { // import account from secret mnemonic
  const secret = await ask.ask(
    `What is your account secret?`,
    (x => x)
  );
  acc = await stdlib.newAccountFromSecret(secret);
}

// who is it?
// deploy or attach accordingly
let ctc = null;
if (isStarsky){
  ctc = acc.contract(backend);
  ctc.getInfo().then((info) => {
    console.log(`The contract is deployed = ${JSON.stringify(info)}`);
  });
} else {
  const info = await ask.ask(
    `Please paste the contract information`,
    JSON.parse
  );
  ctc = acc.contract(backend, info);
}

const fmt = (x) => stdlib.formatCurrency(x, 4);
const getBalance = async () => fmt(await stdlib.balanceOf(acc));

//const starskyBefore = await getBalance(accStarsky);
//const hutchBefore = await getBalance(accHutch);
//console.log(`Starsky before value: ${starskyBefore}`);
//console.log(`Hutch before value: ${hutchBefore}`);

const before = await getBalance();
console.log(`Your balance is ${before}`);

//const ctcStarsky = accStarsky.contract(backend);
//const ctcHutch = accHutch.contract(backend, ctcStarsky.getInfo());

const interact = { ...stdlib.hasRandom };

const HAND = [0, 1, 2, 3, 4, 5];
const GUESS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

interact.informTimeout = () => {
  console.log(`There was a timeout`);
  process.exit(1);
};

if(isStarsky) {
  const amount = await ask.ask(
    `How much do you want to wager?`,
    stdlib.parseCurrency
  );
  interact.wager = amount;
  interact.deadline = {ETH: 100, ALGO: 100, CFX: 1000}[stdlib.connector];

} else { // must be Hutch
  interact.acceptWager = async (amount) => {
    const accepted = await ask.ask(
      `Do you accept the wager of ${fmt(amount)}`,
      ask.yesno
    );
    if(!accepted){
      process.exit(0);
    }
  };
}

interact.getHand = async () => {
  const hand = await ask.ask(`What hand will you play? (0-5 only)`);
  console.log(`You played ${hand}`);
  return hand;
};

interact.getGuess = async () => {
  const guess = await ask.ask(`What is your guess for the total?`);
  console.log(`You guessed ${guess} total`);
  return guess;
};

interact.seeActual = (winningNum)  => {
  console.log(`The actual winning number is: ${winningNum}`);
};

const OUTCOME = ['Starsky wins!', 'Hutch wins!', 'Draw'];
interact.seeOutcome = (outcome) => {
  console.log(`The outcome is ${OUTCOME[outcome]}`);
};

const part = isStarsky ? ctc.p.Starsky : ctc.p.Hutch;
await part(interact);

const after = await getBalance();
console.log(`Your balance is now ${after}`);

/*
const Player = (Who) => ({
  ...stdlib.hasRandom,
  getHand: async () => {
    const hand = Math.floor(Math.random() * 6);
    
    // implement automatic timeout function 5% of hands
    if(Math.random() <= 0.05){
      for(let i = 0; i < 10; i++){
        console.log(`${Who} drags his feet picking a hand`);
        await stdlib.wait(1);
      }
    }
    console.log(`${Who} played ${HAND[hand]}`); 
    return hand;
  },
  getGuess: async (hand) => {
    const guess = Math.floor(Math.random() * 6) + HAND[hand];
    console.log(`${Who} guessed ${guess}`);
    return guess;
  },
  seeActual: (winningNumber) => {
    console.log(`Actual winning number: ${winningNumber}`);
  },
  seeOutcome: async (outcome) => {
    console.log(`${Who} saw the outcome ${OUTCOME[outcome]}`);
  },
  informTimeout: () => {
    console.log(`${Who} observed a timeout`);
  },
});*/

//console.log('Launching...');

/*
await Promise.all([
  ctcStarsky.p.Starsky({
    ...Player('Starsky'),
    wager: stdlib.parseCurrency(10),
    deadline: 10,

  }),
  ctcHutch.p.Hutch({
    ...Player('Hutch'),
    acceptWager: async (amount) => {
      // implement automatic timeout 10% of games
      if(Math.random() <= 0.1){
        for(let i = 0; i < 10; i++){
          console.log(`Hutch looks for his wallet...`);
          await stdlib.wait(1);
        }
      } else {
        console.log(`Hutch accepts the wager of ${fmt(amount)}.`);
      }
    },
  }),
]);
*/

//const afterStarsky = await getBalance(accStarsky);
//const afterHutch = await getBalance(accHutch);

//console.log(`Starsky went from ${starskyBefore} to ${afterStarsky}`);
//console.log(`Hutch went from ${hutchBefore} to ${afterHutch}`);


console.log('Goodbye, Starsky and Hutch!');

ask.done();
