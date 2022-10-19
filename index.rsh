/**
 * Ticket Sale DApp
 * 
 * covers:
 * non-network tokens
 * more advanced invariant
 */

'reach 0.1';

export const main = Reach.App(() => {
  const A = Participant('Admin', {
    cost: UInt,
    token: Token,
    supply: UInt,
    ready: Fun([Contract], Null),
  });
  const B = API('Buyer', {
    buyTicket: Fun([], Bool),
  });
  init();

  A.only(() => {
    const amount = declassify(interact.cost);
    const tok = declassify(interact.token);
    const supply = declassify(interact.supply);
  });
  A.publish(amount, tok, supply);
  commit();
  A.interact.ready(getContract());
  A.pay([[supply, tok]]);

  const [ticketsSold] = parallelReduce([0])
    .invariant(balance() == amount * ticketsSold)
    .invariant(balance(tok) == supply - ticketsSold)// commenting this out throws balance errors
    .while(ticketsSold < supply)
    .api_(B.buyTicket, () => {
      return[amount, (ret) => {
        transfer(1, tok).to(this);
        ret(true);
        return [ticketsSold + 1];
      }];
    });
  transfer(balance()).to(A);
  commit();
  exit();
});