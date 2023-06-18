// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "./StakingInterface.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTStakingDAO is ERC1155, AccessControl {
    using SafeMath for uint256;

    bytes32 public constant MEMBER = keccak256("MEMBER");
    uint256 public constant MAX_SUPPLY_PER_ID = 10000;
    uint256 public constant MAX_PER_WALLET = 50;
    uint256 public constant PRICE_PER_TOKEN = 0.1 ether;

    //Moonbase Alpha Precompile Address.
    address public constant stakingPrecompileAddress = 0x0000000000000000000000000000000000000800;

    // Define Staking States
    enum DAOState {COLLECTING, STAKING, REVOKING, REVOKED}
    DAOState public daoState;

    // Mappings to keep track of stake data
    mapping(uint256 => mapping(address => uint256)) public stakes;
    mapping(uint256 => uint256) public totalStakes;

    //The collator we want to delegate to.
    address public target;

    // Initialize the Staking Interface
    ParachainStaking public staking;
   

    constructor(address _admin, address _target) ERC1155("https://your-metadata-api.com/{id}.json") {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(MEMBER, _admin);
        target = _target;

        staking = ParachainStaking(stakingPrecompileAddress);

    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(uint256 _id, uint256 _count) external payable {
        require(msg.value == PRICE_PER_TOKEN, "Incorrect Ether value sent");
        require(_count < MAX_SUPPLY_PER_ID, "Exceeded max supply");
        require(balanceOf(msg.sender, _id) < MAX_PER_WALLET, "Exceeded max token per wallet limit");

        _mint(msg.sender, _id, _count, "");
    }

    function stake(uint256 _id) external onlyRole(MEMBER) {
        require(daoState == DAOState.COLLECTING, "DAO is not currently accepting stakes");
        require(balanceOf(msg.sender, _id) > 0, "You do not own any tokens of this ID");

        uint256 stakeAmount = balanceOf(msg.sender, _id);
        stakes[_id][msg.sender] = stakes[_id][msg.sender].add(stakeAmount);
        totalStakes[_id] = totalStakes[_id].add(stakeAmount);

        staking.delegate(target, address(this).balance, staking.candidateDelegationCount(target), staking.candidateDelegationCount(address(this)));
    }



    function withdraw(uint256 _id) external onlyRole(MEMBER) {
        require(daoState == DAOState.REVOKED, "DAO is not currently allowing withdrawals");

        
        uint256 withdrawAmount = balanceOf(msg.sender, _id);
        stakes[_id][msg.sender] = 0;
        totalStakes[_id] = totalStakes[_id].sub(withdrawAmount);
        staking.scheduleDelegatorBondLess(address(this), withdrawAmount * PRICE_PER_TOKEN);

    }

    // Admin functions to manage staking state
    function startStaking() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(daoState == DAOState.COLLECTING, "Invalid state transition");
        daoState = DAOState.STAKING;
    }

    function revokeStaking() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(daoState == DAOState.STAKING, "Invalid state transition");
        daoState = DAOState.REVOKING;
    }

    function finalizeRevocation() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(daoState == DAOState.REVOKING, "Invalid state transition");
        daoState = DAOState.REVOKED;
    }

    function resetDAO() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(daoState == DAOState.REVOKED, "Invalid state transition");
        daoState = DAOState.COLLECTING;
    }

    receive() external payable {
        revert("Please use the mint function to buy tokens");
    }
}
