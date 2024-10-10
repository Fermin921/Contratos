// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "./simpleCoin 2.sol";

contract simpleCrowdSale {
    uint256 public startTime; //Tiempo de inicio
    uint256 public endTime; //Tiempo de finalización
    uint256 public weiTokenPrice; //Precio del token en Wei
    uint256 public weiInvestmentObjective;
    mapping(address => uint256) public InvestmentAmountOf;
    uint256 public investmentReceived;
    uint256 public investmentRefunded;
    bool public isFinalized;
    bool public isRefundedAllowed;
    address public owner;
    simpleCoin public CrowdSaleToken;

    modifier onlyOwner() {
        if (msg.sender != owner) revert();
        _;
    }

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _weiTokenPrice,
        uint256 _etherInvestmentObjective
    ) public {
        require(_startTime >= block.timestamp);
        require(_endTime >= _startTime);
        require(_weiTokenPrice != 0);
        require(_etherInvestmentObjective != 0);
        startTime = _startTime;
        endTime = _endTime;
        weiTokenPrice = _weiTokenPrice;
        weiInvestmentObjective =
            _etherInvestmentObjective *
            1000000000000000000;
        CrowdSaleToken = new simpleCoin(0);
        isFinalized = false;
        isRefundedAllowed = false;
        owner = msg.sender;
    }
}
