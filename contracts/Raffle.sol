// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Raffle is VRFConsumerBaseV2 {
    // Errors
    error Raffle__LessEthSent();
    error Raffle__EthTransferFailed();

    // state variables
    uint256 private immutable i_fees;
    // uint256 private immutable i_interval;
    // uint256 private s_lastTimestamp;
    address[] private s_participants;
    // mapping(address user => uint256 lastRoundPlayed) private userRound;
    // uint256 private s_round;
    address private s_recentWinner;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    // Events
    event EnteredRaflle(address indexed user);
    event RequestedRandomWords(uint256 indexed requestId);
    event WinnerSelected(address indexed winner);

    constructor(
        address vrfCoordinatorAddr,
        uint256 fees,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorAddr) {
        i_fees = fees;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddr);
        i_gasLane = gasLane;
        i_subId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaflle() public payable {
        if (msg.value < i_fees) {
            revert Raffle__LessEthSent();
        }
        s_participants.push(payable(msg.sender));
        emit EnteredRaflle(msg.sender);
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomWords
    ) internal override {
        uint256 randomNumber = randomWords[0] % s_participants.length;
        address winner = s_participants[randomNumber];
        emit WinnerSelected(winner);
        (bool success, ) = payable(winner).call{value: address(this).balance}(
            ""
        );
        if (!success) {
            revert Raffle__EthTransferFailed();
        }
        s_recentWinner = winner;
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

    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }
}
