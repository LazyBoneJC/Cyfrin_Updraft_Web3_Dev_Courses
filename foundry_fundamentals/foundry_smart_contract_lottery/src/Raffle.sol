// Layout of the contract file:
// version
// imports
// errors
// interfaces, libraries, contract

// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// import {console} from "forge-std/console.sol";

/**
 * @title Raffle contract
 * @author Yu-Wei Chang
 * @notice
 * @dev Implements Chainlink VRFv2.5 for random number generation
 */
contract Raffle is VRFConsumerBaseV2Plus {
    /* Errors */
    error Raffle__SendMoreEthToEnterRaffle();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(
        uint256 balance,
        uint256 playersLength,
        uint256 raffleState
    );

    /* Type declarations */
    enum RaffleState {
        OPEN, // 0
        CALCULATING // 1
    } // enum: 定義一個枚舉類型，表示抽獎狀態

    /* State variable */
    uint16 private constant REQUEST_CONFIRMATIONS = 3; // number of confirmations before fulfilling
    uint32 private constant NUM_WORDS = 1; // number of random words to request
    uint256 private immutable i_entranceFee; // immutable variable
    // @dev The duration of the lottery in seconds
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callbackGasLimit; // gas limit for the callback function
    uint256 private immutable i_subscriptionId; // subscriptionId for VRF
    address payable[] private s_players; // storage variable
    uint256 private s_lastTimeStamp;
    address private s_recentWinner; // storage variable to store the winner's address
    RaffleState private s_raffleState; // storage variable to store the raffle state

    /* Events */
    // event: 宣告一個事件
    // emit: 觸發事件並記錄，寫進區塊鏈 logs 中
    event RaffleEntered(address indexed player); // indexed allows filtering by player address
    event winnerPicked(address indexed winner); // indexed allows filtering by winner address
    event RequestedRaffleWinner(uint256 indexed requestId); // indexed allows filtering by requestId

    // 建構子：部署時會自動執行
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane, // keyHash
        uint256 subscriptionId,
        uint32 callbackGasLimit // gas limit for the callback function
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId; // 設定訂閱ID
        i_callbackGasLimit = callbackGasLimit; // 設定回調函數的 gas 限制
        s_lastTimeStamp = block.timestamp; // 設定初始時間戳記
        s_raffleState = RaffleState.OPEN; // 初始狀態為 OPEN
    }

    function enterRaffle() public payable {
        // console.log(
        //     "Raffle: enterRaffle() called by %s with value %s",
        //     msg.sender,
        //     msg.value
        // );

        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreEthToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender); // emit the event
    }

    // When should the winner be picked?
    /**
     * @dev This is the function that Chianlink nodes will call to see if the lottery is ready to have a winner picked.
     * The following should be true in order for upkeepNeeded to be true:
     * 1. The time interval has passed betwin raffle runs
     * 2. The lottery is in an "open" state
     * 3. The contract has ETH (Check if contract has players)
     * 4. Implicitly, your subscription has LINK
     * @param - ignored
     * @return upkeepNeeded - true if it's time to restart the lottery
     * @return - ignored
     */
    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /** performData */) {
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x"); // return the upkeepNeeded and an empty bytes array
    }

    // 1. Get a random number
    // 2. Use random number to pick a player
    // 3. Be automatically called
    function performUpkeep(bytes calldata /* performData */) external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }

        s_raffleState = RaffleState.CALCULATING; // change the state to CALCULATING

        // Because of inheritance, we can use s_vrfCoordinator -> (IVRFCoordinatorV2Plus public s_vrfCoordinator;)
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);

        // Quiz: Is this redundant? Yes, because the requestId is already part of the request(vrfCoordinator).
        emit RequestedRaffleWinner(requestId); // emit the event with the requestId
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] calldata randomWords
    ) internal override {
        // Checks

        // Effects (Enternal Contract State)
        uint256 indexOfWinner = randomWords[0] % s_players.length; // get a random index
        address payable recentWinner = s_players[indexOfWinner]; // get the winner's address
        s_recentWinner = recentWinner; // store the winner's address
        s_raffleState = RaffleState.OPEN; // change the state back to OPEN
        s_players = new address payable[](0); // reset the players array
        s_lastTimeStamp = block.timestamp; // update the last timestamp
        emit winnerPicked(s_recentWinner);

        // Interactions(External Contracts Interactions)
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns (address) {
        return s_players[indexOfPlayer];
    }

    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }
}
