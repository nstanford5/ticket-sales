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
    ready: Fun([Contract], Null),
  });
  const B = API('Buyer', {
    buyTicket: Fun([], Bool),
  });
  init();

  A.only(() => {
    const amount = declassify(interact.cost);
    const tok = declassify(interact.token);
  });
  A.publish(amount, tok);
  commit();
  A.interact.ready(getContract());
  A.pay([[3, tok]]);

  const [ticketsSold] = parallelReduce([0])
    .invariant(balance() == amount * ticketsSold)
    .invariant(balance(tok) == 3 - ticketsSold)// commenting this out throws balance errors
    .while(ticketsSold < 3)
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