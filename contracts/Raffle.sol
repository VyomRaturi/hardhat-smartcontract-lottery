// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Raffle is VRFConsumerBaseV2, AutomationCompatibleInterface {
    // Type declarations
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    // Errors
    error Raffle__LessEthSent();
    error Raffle__EthTransferFailed();
    error Raffle__NotOpen();

    // state variables
    uint256 private immutable i_fees;
    uint256 private immutable i_interval;
    uint256 private s_lastTimestamp;
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
    RaffleState raffleState;

    // Events
    event EnteredRaflle(address indexed user);
    event RequestedRandomWords(uint256 indexed requestId);
    event WinnerSelected(address indexed winner);

    constructor(
        address vrfCoordinatorAddr,
        uint256 fees,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinatorAddr) {
        i_fees = fees;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddr);
        i_gasLane = gasLane;
        i_subId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        raffleState = RaffleState.OPEN;
        s_lastTimestamp = block.timestamp;
        i_interval = interval;
    }

    function enterRaflle() public payable {
        if (raffleState == RaffleState.CALCULATING) {
            revert Raffle__NotOpen();
        }

        if (msg.value < i_fees) {
            revert Raffle__LessEthSent();
        }

        s_participants.push(payable(msg.sender));

        emit EnteredRaflle(msg.sender);
    }

    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory performData) {
        bool hasBalance = (address(this).balance > 0);
        bool intervalPassed = (block.timestamp - s_lastTimestamp >= i_interval);
        bool isOpen = (raffleState == RaffleState.OPEN);

        upkeepNeeded = (hasBalance && intervalPassed && isOpen);
        performData = "";
    }

    function performUpkeep(bytes calldata /* performData */) external {
        (bool upkeepNeeded, ) = checkUpkeep("");

        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                block.timestamp - s_lastTimestamp,
                address(this).balance,
                raffleState
            );
        }

        raffleState = RaffleState.CALCULATING;

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );

        emit RequestedRandomWords(requestId);
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
        s_participants = new address[](0);
        //     s_lastTimestamp = block.timestamp;
        raffleState = RaffleState.OPEN;
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
