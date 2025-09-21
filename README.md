# Aquifi Airdrop Smart Contract

## Overview
A Clarity smart contract for managing token airdrops with eligibility criteria and claiming mechanisms on the Stacks blockchain.

## Features
- Eligibility tracking per user
- Configurable airdrop drops with time windows
- Prevention of double claims
- Owner-controlled drop creation

## Core Functions

### Public Functions
- `evaluate-user`: Checks and records user eligibility
- `claim-drop`: Allows eligible users to claim airdrops
- `create-drop`: Admin function to create new airdrops

### Read-Only Functions
- `has-claimed`: Verifies if a user has claimed a specific drop
- `get-drop-info`: Retrieves airdrop configuration details
- `get-user-eligibility`: Gets a user's eligibility status

## Current Implementation Notes
- NFT ownership check is currently a placeholder (returns `true`)
- Transaction count is hardcoded (returns `10`)
- Users must have at least 5 transactions to be eligible
- Uses STX for token transfers

## Error Codes
- `u1`: Drop not found
- `u2`: User not eligible
- `u3`: User not evaluated
- `u4`: Already claimed
- `u5`: Drop not started
- `u6`: Drop ended
- `u7`: Transfer failed
- `u8`: Unauthorized

## Security Features
- Owner-only drop creation
- Time-bounded claims
- Double-claim prevention
- Eligibility validation before claims

## Requirements
- Stacks blockchain
- Clarity-compatible wallet
- Contract owner authorization for administrative functions
