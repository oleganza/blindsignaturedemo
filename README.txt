
CLIENT:

As a client user can add extended pubkeys from custodians into his address book.

Then user sends money to public keys belonging to the custodians.

And to redeem the transactions, sends signing requests to each custodian whose pubkey was used.

To lock funds:
1. Client selects several custodians.
2. The output script is generated for their pubkeys. Script is stored together with its P2SH address.
3. Client sees P2SH address to send funds to.

To unlock funds:
1. App downloads unspent outputs for known P2SH addresses.
2. Allows user to select which funds to unlock.
3. Prepares requests for each custodian linked to the transaction.
4. Waits for signatures from all custodians.
5. Allows user to specify address to which funds should be relocated.

CUSTODIAN:

As a custodian, user can create a key pair for each client and add them into his address book.

Then, receive a request to sign the blinded transaction.

Reply with a blind signature after face-to-face authentication.




