# Polkadot_EasyA_Hackathon2023
Polkadot x EasyA Hackathon

## Smart Contract

The NFTStakingDAO(https://github.com/luckiestkitty/Polkadot_EasyA_Hackathon2023/blob/main/contracts/NFTStakingDAO.sol) contract utilizes the ERC-1155 standard to manage various groups of staking.

The contract integrates with the Parachain Staking precompile for Moonbeam, which can be found at the following link: https://github.com/PureStake/moonbeam/blob/master/precompiles/parachain-staking/StakingInterface.sol.

### ERC-1155 Token Management

Each Token ID managed by the ERC-1155 contract represents a distinct group for staking purposes. A few important considerations are defined for these token groups:
Maximum Supply: The maximum token supply for each Token ID is set to 10,000 units.
Maximum Mint per Wallet: Each wallet address can mint a maximum of 50 tokens per Token ID.
Token Price: The price for each unit of token under any given Token ID is fixed at 0.1 (in the token's denomination currency).

### Staking and Rewards Distribution

The staking reward distribution is proportional to a wallet's share in the total supply of the specific Token ID:
For example, if a user owns 50 tokens and the total supply for the Token ID is 1,000, then the user's share is 50 / 1000 = 0.05 or 5% of the total supply.
As the owner's stake changes (either due to acquiring more tokens or transferring tokens to another wallet), their share in the staking rewards will dynamically adjust.

### Token Transferability

The ERC-1155 standard allows tokens to be transferred or sold to other addresses at any time. When a token transfer occurs, the ownership share of the Token ID (and consequently, the share in the staking reward) is also transferred to the new owner.
This system thus provides flexibility for participants, allowing them to enter or exit staking pools by simply transferring their tokens, with all the proportional staking interests being automatically transferred in the process.

## Deployed contract at Moonbase Alpha
https://moonbase.moonscan.io/address/0x6f51935f88bb78ef6b821f2be36f1ac143532d68

## Polkadot Educational Slack Bot

The Polkadot EduBot is a Python-based Slack bot that uses the OpenAI Chat API to facilitate interactive learning about the Polkadot network. It manages a knowledge base of Polkadot documents (URLs, PDFs) uploaded to a dedicated vectorstore. This allows the bot to provide detailed responses to user queries, promoting a dynamic and engaging educational experience.
