// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Raffle is VRFConsumerBaseV2 {
    // Errors
    error Raffle__LessEthSent();

    // State variables
    uint256 private immutable i_fees;
    address[] private s_participants;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    // Events
    event EnteredRaflle(address indexed user);

    constructor(
        address vrfCoordinatorAddr,
        uint256 entranceFee
    ) VRFConsumerBaseV2(vrfCoordinatorAddr) {
        i_fees = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddr);
    }

    function enterRaflle() public payable {
        if (msg.value < i_fees) {
            revert Raffle__LessEthSent();
        }
        s_participants.push(payable(msg.sender));
        emit EnteredRaflle(msg.sender);
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        //     uint256 randomNumber = randomWords[0] % s_participants.length;
        //     address winner = s_participants[randomNumber];
        //     emit WinnerSelected(winner, address(this).balance, s_round);
        //     (bool success, ) = payable(winner).call{value: address(this).balance}(
        //         ""
        //     );
        //     if (!success) {
        //         revert Raffle__EthTransferFailed();
        //     }
        //     s_recentWinner = winner;
        //     s_round += 1;
        //     s_participants = new address[](0);
        //     s_lastTimestamp = block.timestamp;
        //     raffleState = RaffleState.OPEN;
    }

    // View / Pure functions
    function getEntranceFee() public view returns (uint256) {
        return i_fees;
    }

    function getParticipant(uint256 idx) public view returns (address) {
        return s_participants[idx];
    }

    function getAllParticipants() external view returns (address[] memory) {
        return s_participants;
    }

    function getParticipantsLength() external view returns (uint256) {
        return s_participants.length;
    }
}
