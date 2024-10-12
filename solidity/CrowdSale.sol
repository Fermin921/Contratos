// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "./simpleCoin 2.sol";

contract SimpleCrowdSale {
    uint256 public startTime; // Tiempo de inicio
    uint256 public endTime; // Tiempo de finalización
    uint256 public weiTokenPrice; // Precio del token en Wei
    uint256 public weiInvestmentObjective; // Objetivo de inversión en Wei
    mapping(address => uint256) public investmentAmountOf; // Inversiones de cada dirección
    uint256 public investmentReceived; // Total de inversión recibida
    uint256 public investmentRefunded; // Total de inversión reembolsada
    bool public isFinalized; // Si la venta se ha finalizado
    bool public isRefundedAllowed; // Si los reembolsos están permitidos
    address public owner; // Dueño del contrato
    simpleCoin public crowdSaleToken; // Token para la venta

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _weiTokenPrice,
        uint256 _etherInvestmentObjective
    ) {
        require(_startTime >= block.timestamp, "Start time is in the past");
        require(_endTime >= _startTime, "End time is before start time");
        require(_weiTokenPrice != 0, "Token price is zero");
        require(_etherInvestmentObjective != 0, "Investment objective is zero");

        startTime = _startTime;
        endTime = _endTime;
        weiTokenPrice = _weiTokenPrice;
        weiInvestmentObjective = _etherInvestmentObjective * 1 ether;
        crowdSaleToken = new simpleCoin(0);
        isFinalized = false;
        isRefundedAllowed = false;
        owner = msg.sender;
    }

    function isValidInvestment(
        uint256 _investment
    ) internal view returns (bool) {
        bool nonZeroInvestment = _investment != 0;
        bool withinCrowdSalePeriod = block.timestamp >= startTime &&
            block.timestamp <= endTime;
        return nonZeroInvestment && withinCrowdSalePeriod;
    }

    function calcularNumberOfTokens(
        uint256 _investment
    ) internal view returns (uint256) {
        return _investment / weiTokenPrice;
    }

    function assignTokens(address _beneficiary, uint256 _investment) internal {
        uint256 numberOfTokens = calcularNumberOfTokens(_investment);
        crowdSaleToken.mint(_beneficiary, numberOfTokens);
        emit LogTokenAssignment(_beneficiary, numberOfTokens);
    }

    event LogInvestment(address indexed investor, uint256 value);
    event LogTokenAssignment(address indexed investor, uint256 numTokens);

    function invest() public payable {
        require(isValidInvestment(msg.value), "Invalid investment");
        address investor = msg.sender;
        uint256 investment = msg.value;

        investmentAmountOf[investor] += investment;
        investmentReceived += investment;

        assignTokens(investor, investment);

        emit LogInvestment(investor, investment);
    }

    function finalize() public onlyOwner {
        require(!isFinalized, "Already finalized");

        bool isCrowdSaleComplete = block.timestamp > endTime;
        bool investmentObjectiveMet = investmentReceived >=
            weiInvestmentObjective;

        if (isCrowdSaleComplete) {
            if (investmentObjectiveMet) {
                crowdSaleToken.release();
            } else {
                isRefundedAllowed = true;
            }
            isFinalized = true;
        }
    }

    event Refund(address indexed investor, uint256 value);

    function refund() public {
        require(isRefundedAllowed, "Refunds not allowed");

        address payable investor = payable(msg.sender);
        uint256 investment = investmentAmountOf[investor];

        require(investment != 0, "No investment to refund");

        investmentAmountOf[investor] = 0;
        investmentRefunded += investment;

        emit Refund(investor, investment);

        require(investor.send(investment), "Refund failed");
    }
}

// pragma solidity ^0.8.20;

// import "./simpleCoin 2.sol";

// contract SimpleCrowdSale {
//     uint256 public startTime; //Fecha de inicio del contrato
//     uint256 public endTime; //Fecha de termino del contrato
//     uint256 public weiTokenPrice; //Es el precio a la que se le da ala moneda en wei
//     uint256 public weiInvestmentObjective; //La cantidad que se necesita
//     mapping (address => uint256) public investmentAmountOf; //Un mapa de las cuentas que han donado y cantidad
//     uint256 public investmentReceived; //Cantidad de wei recibido
//     uint256 public investRefunded; //Lo que se a regresado
//     bool public isFinalized; //Saber si ya finalizo
//     bool public isRefundedAllowed;
//     address public owner; //Dueño
//     SimpleCoin public crowdSaleToken; //Token que se venderia

//   modifier onlyOwner(){
//     if(msg.sender != owner) revert();
//     _;
// }

// constructor(
//     uint256  _startTime,
//     uint256  _endTime,
//     uint256 _weiTokenPrice,
//     uint256 _etherInvestmentObjective//
// ) public {
//     require(_startTime >= block.timestamp);
//     require(_endTime >= _startTime);
//     require(_weiTokenPrice != 0);
//     require(_etherInvestmentObjective != 0);
//     startTime = _startTime;
//     endTime = _endTime;
//     weiTokenPrice = _weiTokenPrice;
//     weiInvestmentObjective = _etherInvestmentObjective*1000000000000000000;
//     crowdSaleToken = new SimpleCoin(0);
//     isFinalized = false;
//     isRefundedAllowed = false;
//     owner = msg.sender;
//  }
// }
// //Solo se puede usar dentro de la blockchain con la palabra reservada internal
// function isValidInvestment(uint256 _investment) internal view returns(bool){
//     bool nonZeroInvestment = _investment != 0;
//     bool withinCrowdSalePeriod = bloc.timestamp >= startTime && block.timestamp <= endTime;
//     return nonZeroInvestment && withinCrowdSalePeriod;
// }
// //Funcion que calcula el numero de tokens existentes
// function CalculateNumberOfTokens(uint256 _investment)internal returns(uint256){
//     return _investment / weiTokenPrice;
// }
// //Funcion encargada de asignar la cantidad de tokens a la cuenta
// function assignTokens(uint256 _investment)internal{
//     uint256 _numberOfTokens = CalculateNumberOfTokens(_investment);
//     crowdSaleToken.mint(_beneficiary, _numberOfTokens);
// }

// event LogInvestment(address indexed investor, uint256 value);
// event LogTokenAssignment(address indexed investor, uint256 numTokens);

// function invest() public payable {
//     require(isValidInvestment(msg.value));
//     address investor = msg.sender;
//     uint256 investment = msg.value;
//     investmentReceived += investment;
//     assignTokens(investor,investment);
//     emit LogInvestment(investor,investment);
// }
// //Funcion para finalizar pero verifica si se alcanzo la inversion minima si no se logro se ejecuta el refound en caso contrarrio ejecuta la funcion release ue libera el token
// function finalize() public onlyOwner{
//     if(isFinalized) revert();
//     bool isCrowdSaleComplete = block.timestamp > endTime;
//     bool investmentObjective = investmentReceived >= weiInvestmentObjective;

//     if(isCrowdSaleComplete){
//         if(investmentObjective){
//             crowdSaleToken.release();
//         }else {
//             ifRefundedAllowed = true;
//         }
//         isFinalized = true;
//     }

//     event Refund(address investor,uint256 value);
//     function refund() public{
//         if(!isRefundedAllowed)revert();
//         address payable investor = payable(msg.sender);
//         uint256 investment = InvestmentAmountOf[investor];
//         if(investment!=0)revert();
//         InvestmentAmountOf[investor] = 0;
//         investmentRefunded += investment;
//         emit Refund(msg.sender,investment);
//         if(!investor.send(investment))revert();
//     }

// }
