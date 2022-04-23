'reach 0.1';

const [playHand, ZERO, ONE, TWO, THREE, FOUR, FIVE] = makeEnum(6);
const [gHand, gZERO, gONE, gTWO, gTHREE, gFOUR,
  gFIVE, gSIX, gSEVEN, gEIGHT, gNINE, gTEN] = makeEnum(11);
const [gameOutcome, A_WINS, B_WINS, DRAW] = makeEnum(3);

// function that computes the winner based on hands and guesses
const winner = (playHandA, playHandB, gHandA, gHandB) => {

  // if both guesses are the same
  if (gHandA == gHandB) {
    const realOutcome = DRAW;
    return realOutcome;
  } else {
    // if first player guess is equal to total of both hands played
    if (gHandA == (playHandA + playHandB)) {
      const realOutcome = A_WINS;
      return realOutcome;
    } else {
      // if second player guess is equal to total of both hands played
      if (gHandB == (playHandA + playHandB)) {
        const realOutcome = B_WINS;
        return realOutcome;
        // else the outcome is a draw
      } else {
        const realOutcome = DRAW;
        return realOutcome;
      }
    }
  }
};

// the asserts give the forall indicators as to expected outcomes
// can work with any value, we are more concernced with all
// possible combinations of the game outcome given inputs
assert(winner(ZERO, FOUR, gZERO, gFOUR) == B_WINS);
assert(winner(FOUR, ZERO, gFOUR, gZERO) == A_WINS);
assert(winner(ZERO, ONE, gZERO, gFOUR) == DRAW);
assert(winner(FIVE, FIVE, gFIVE, gFIVE) == DRAW);

// assert for all possible combinations of inputs
forall(UInt, playHandA =>
  forall(UInt, playHandB =>
    forall(UInt, gHandA =>
      forall(UInt, gHandB =>
        assert(gameOutcome(winner(playHandA, playHandB, gHandA, gHandB)))))));

// assert for all possible hands where guesses are the same
forall(UInt, playHandA =>
  forall(UInt, playHandB =>
    forall(UInt, sameGuess => // this variable is local?
      assert(winner(playHandA, playHandB, sameGuess, sameGuess) == DRAW))));

// shared player method signatures
const Player = {
  ...hasRandom, 
  getHand: Fun([], UInt),
  getGuess: Fun([UInt], UInt),
  seeActual: Fun([UInt], Null),
  seeOutcome: Fun([UInt], Null),
  informTimeout: Fun([], Null),
  testMessage: Fun([], Null),
};

// Reach app starts here
export const main = Reach.App(() => {

  // participant interact interface
  const Starsky = Participant('Starsky', {
    ...Player, // inherit all Player functions
    wager: UInt, // declare wager
    deadline: UInt, // declare deadline
  });

  // participant interact interface
  const Hutch = Participant('Hutch', {
    ...Player, // inherit all Player functions
    acceptWager: Fun([UInt], Null), // declare acceptWager method signature
  });

  // initialize the app
  init();

  const informTimeout = () => {
    each([Starsky, Hutch], () => {
      interact.informTimeout();
    });
  };

  // first participant creates the wager and deadline
  Starsky.only(() => {
    const wager = declassify(interact.wager);
    const deadline = declassify(interact.deadline);
  });

  // The first one to publish deploys the contract
  Starsky.publish(wager, deadline)
    .pay(wager);
  commit();

  // Hutch always accepts this wager
  Hutch.only(() => {
    interact.acceptWager(wager);
  });

  // The second one to publish always attaches
  Hutch.pay(wager)
    .timeout(relativeTime(deadline), () => closeTo(Starsky, informTimeout));

  // can you make this a counter until one player makes 3 games?
  var outcome = DRAW;

  // invariant must be true after the execution of the while loop
  // has the balance been paid?
  // is the outcome valid against enumerated type gameOutcome?
  invariant(balance() == 2 * wager && gameOutcome(outcome));

  // while the outcome is still a draw, continue to loop
  while ( outcome == DRAW ) {
    commit();

    Starsky.only(() => {
      const _playHandA = interact.getHand();
      // getGuess takes in the value of your hand, so that you can
      // add what you think the other player has
      const _gHandA = interact.getGuess(_playHandA);

      // makeCommitment with salt values
      const [_commitA, _saltA] = makeCommitment(interact, _playHandA);
      const commitA = declassify(_commitA);
      const [_guessCommitA, _guessSaltA] = makeCommitment(interact, _gHandA);
      const guessCommitA = declassify(_guessCommitA);
    });

    // publish commitment to hand and commitment to guess value
    Starsky.publish(commitA, guessCommitA)
      .timeout(relativeTime(deadline), () => closeTo(Hutch, informTimeout));
    commit();

    // Hutch cannot know these values at this state
    unknowable(Hutch, Starsky(_playHandA, _saltA));
    unknowable(Hutch, Starsky(_gHandA, _guessSaltA));

    Hutch.only(() => {
      const _playHandB = interact.getHand();
      const _gHandB = interact.getGuess(_playHandB);
      const playHandB = declassify(_playHandB);
      const gHandB = declassify(_gHandB);
    });

    Hutch.publish(playHandB, gHandB)
      .timeout(relativeTime(deadline), () => closeTo(Starsky, informTimeout));
    commit();

    // Starsky can reveal his info
    Starsky.only(() => {
      const [saltA, playHandA] = declassify([_saltA, _playHandA]);
      const [guessSaltA, gHandA] = declassify([_guessSaltA, _gHandA]);
    });

    // Starsky can publish unhashed values
    Starsky.publish(saltA, playHandA)
      .timeout(relativeTime(deadline), () => closeTo(Hutch, informTimeout));
    checkCommitment(commitA, saltA, playHandA);
    commit();

    Starsky.publish(guessSaltA, gHandA)
      .timeout(relativeTime(deadline), () => closeTo(Hutch, informTimeout));
    commit();

    Starsky.only(() => {
      const winningNum = playHandA + playHandB;
      interact.seeActual(winningNum);
    });

    Starsky.publish(winningNum)
      .timeout(relativeTime(deadline), () => closeTo(Hutch, informTimeout));

    Hutch.only(() => {
      interact.seeActual(winningNum);
    });
    // all Reach loops require this continue explicitly
    // variables are only permitted to be assigned values
    // immediately preceeding a continue
    outcome = winner(playHandA, playHandB, gHandA, gHandB);
    continue;
  }; // end of while loop

  // make sure that someone has won
  assert(outcome == A_WINS || outcome == B_WINS);

  // transfer winnings to player
  transfer(2 * wager).to(outcome == A_WINS ? Starsky : Hutch);
  commit();

  // show each player the outcome
  each([Starsky, Hutch], () => {
    interact.seeOutcome(outcome);
  });
  exit();
});
