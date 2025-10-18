Commitment Contract

Overview

The Commitment Contract is a smart contract written in Clarity that enables users to create personal commitments backed by staked STX tokens.
Users pledge tokens when setting a goal and risk losing their stake if they fail to meet the commitment within the deadline. The contract promotes accountability and self-discipline through financial incentives.

🚀 Core Features

Create a Commitment

Users can create a new commitment by providing:

A textual description of their goal.

A deadline (block height) for completion.

The user’s entire STX balance is automatically staked into the contract.

Each commitment is assigned a unique incremental ID.

Complete a Commitment

The creator of an active commitment can mark it as completed before the deadline.

Once completed, the staked STX tokens are returned to the user.

The commitment’s status updates to "completed".

Mark as Failed

The creator can voluntarily mark their commitment as failed.

The stake is forfeited (remains in the contract), and the commitment status becomes "failed".

Expire a Commitment

If the block height surpasses the commitment’s deadline and it’s still active, the contract automatically or manually updates the status to "expired".

The stake is forfeited.

View Commitments and Stakes

Read-only functions allow users to:

Retrieve commitment details by ID.

View associated stake amounts.

Check the next available commitment ID.

View the current contract STX balance.

⚙️ Data Structures
Name	Type	Description
commitments	Map	Stores details of each commitment including creator, description, stake amount, deadline, and status.
commitment-stakes	Map	Tracks the stake amount for each commitment ID.
next-commitment-id	Data variable	Auto-incrementing ID counter for new commitments.

🧩 Error Codes

Constant	Code	Meaning
ERR-NOT-AUTHORIZED	u100	Caller is not the commitment creator.
ERR-COMMITMENT-NOT-FOUND	u101	Commitment ID does not exist.
ERR-COMMITMENT-ALREADY-COMPLETED	u102	Commitment has already been marked as completed.
ERR-COMMITMENT-ALREADY-FAILED	u103	Commitment has already failed.
ERR-COMMITMENT-EXPIRED	u104	Deadline has already passed.
ERR-INSUFFICIENT-BALANCE	u105	User has no STX to stake.
ERR-INVALID-DEADLINE	u106	Deadline must be greater than current block height.
ERR-INVALID-DESCRIPTION	u107	Description must be valid and non-empty.

🔒 Security and Validation

Only the creator can mark their own commitments as completed or failed.

Descriptions are validated and sanitized before storage.

Deadlines must be in the future.

Commitments automatically lose eligibility for completion once expired.

🧠 Design Considerations

The contract currently stakes the entire user balance when creating a commitment.
This can be refined to accept a user-specified stake amount.

There is no redistribution of forfeited tokens yet. Future versions may allow:

Donations to a treasury.

Redistribution to other users.

Charitable pool integrations.

📚 Available Public Functions

Function	Purpose
create-commitment (description, deadline)	Creates a new commitment and stakes tokens.
complete-commitment (commitment-id)	Marks a commitment as completed and refunds stake.
mark-commitment-failed (commitment-id)	Marks a commitment as failed and forfeits stake.
expire-commitment (commitment-id)	Marks a commitment as expired if deadline has passed.

🔍 Read-only Functions
Function	Returns
get-commitment (commitment-id)	Details of a specific commitment.
get-commitment-stake (commitment-id)	Amount staked for a commitment.
get-next-commitment-id	Next available commitment ID.
get-contract-balance	Total STX held in contract.

📄 License

This contract is released under the MIT License.