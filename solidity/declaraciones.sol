pragma solidity ^0.8.19;

contract Token {
    //Tipos de datos
    enum UserType {
        TokenHolder,
        Admin,
        Owner
    }
    //Equivalnete a un objeto
    struct UserInfo {
        address account; //Lo detecta como hexadecimal, es especial para las direcciones de las cuentas
        string firstName;
        string lastName;
        UserType usertype;
    }
    //Funciona como el json, puede usarse para guardar una lista por ejemplo
    mapping(address => uint) public tokenbalance;

    address public owner = 0x000000;
    uint256 public constant maxTranferLimit = 10000; //uint no almacena un signo

    event Transfer(address from, address to, uint256 value);
    event FrozenAccount(address target, bool frozen);
    //Puede usarse para proteger la informacion
    modifier onlyOwner() {
        require(msg.sender == owner); //Funciona como condicional si se cumple continua y en caso contrario se detiene.
        _; //Espacio vacio dentro del codigo
    }

    constructor(uint256 _initialSupply) public {
        owner = msg.sender; //Se ejecuta solo 1 vez, el dueno se le esta guardando o asignando para usarlo.
    }
}
