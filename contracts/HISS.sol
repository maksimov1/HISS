pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import 'openzeppelin-solidity/contracts/ownership/rbac/RBAC.sol';

contract HISSRBAC is RBAC, Ownable {
  string public constant ROLE_ADMIN = "admin";
  string public constant ROLE_INSURANCE_COMPANY = "insurance_company";
  string public constant ROLE_PATIENT = "patient";
  string public constant ROLE_HOSPITAL = "hospital";
  string public constant ROLE_UNKNOWN = "unknown";

  modifier onlyAdmin()
  {
    checkRole(msg.sender, ROLE_ADMIN);
    _;
  }

  modifier onlyInsuranceCompany()
  {
    checkRole(msg.sender, ROLE_INSURANCE_COMPANY);
    _;
  }

  modifier onlyPatient()
  {
    checkRole(msg.sender, ROLE_PATIENT);
    _;
  }

  modifier onlyHospital()
  {
    checkRole(msg.sender, ROLE_HOSPITAL);
    _;
  }

  constructor(address[] _admins)
  public
  {
    addRole(msg.sender, ROLE_ADMIN);

    for (uint256 i = 0; i < _admins.length; i++) {
      addRole(_admins[i], ROLE_ADMIN);
    }
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminAddRole(address addr, string roleName)
    onlyAdmin
    public
  {
    addRole(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminRemoveRole(address addr, string roleName)
    onlyAdmin
    public
  {
    removeRole(addr, roleName);
  }
}

contract Hiss is HISSRBAC {
    uint public balance;
    
    uint public min = 50000000000000000;
    uint public max = 100000000000000000;
    
    mapping(address => mapping(uint => string)) public hashes; //получаем хеш данных по адреу и номеру записи
    
    mapping(address => uint) public numberOfNotes; //количество записей для данного адреса
    
    mapping(address => bool) public isInsuranceActive; // активна ли страховка для данного пациента
     
    mapping(address => string) public keyByAddress; //получаем открытый ключ пациента по адресу
   
    mapping(address => mapping(address => bool)) public accessByHospital; //по адресу пациента смотрим доступна ли запись для больницы с этим id (uint)

    mapping(address => string) public hospitalSign; //цифровая подись больниц, для подписи записей, добавляемых в базу (пока не используется)
    
    //владелец сервиса добавляет страховые
    function addInsuranceCompany (address addr) public onlyAdmin {
        //require(typeByAddress[addr] == typeOfMembership.NotRegistered);

	addRole(addr, ROLE_INSURANCE_COMPANY);
    }
    
    //страховые добавляют пациентов
    function addPatient (address addr, string publicKey, string firstNote) public payable onlyInsuranceCompany {
        require(msg.value >= min && msg.value <= max);
        //require(typeByAddress[addr] == typeOfMembership.NotRegistered);

	addRole(addr, ROLE_PATIENT);
        keyByAddress[addr] = publicKey;
        hashes[addr][0] = firstNote; // первое посещение
        numberOfNotes[addr]++;
        balance += msg.value;
    }
    //страховые добавляют больницы
    function addHospital (address addr, string digitalSign) public payable onlyInsuranceCompany {
        require(msg.value >= min && msg.value <= max);
        //require(typeByAddress[addr] == typeOfMembership.NotRegistered);

	addRole(addr, ROLE_HOSPITAL);
        hospitalSign[addr] = digitalSign;
        balance += msg.value;
    }
    //старховые управляют страховкой пациента
    function setInsuranceStatus (address addr, bool flag) public onlyInsuranceCompany {
	checkRole(addr, ROLE_PATIENT);
        isInsuranceActive[addr] = flag;
    }
    
    //пациент разрешает добавлять новую запись больнице
    function consentToAddData(address addr) public onlyPatient {
	checkRole(addr, ROLE_HOSPITAL);
        accessByHospital[msg.sender][addr] = true;
    }
    
    //больница добавляет данные только с разрешения
    function addNewNote(address addr, string note) public onlyHospital {
	checkRole(addr, ROLE_PATIENT);
        require(accessByHospital[addr][msg.sender] == true);
        hashes[addr][numberOfNotes[addr]] = note;
        numberOfNotes[addr]++;
        accessByHospital[addr][msg.sender] = false;
    }
    
    //вывод средств на кошелек владельца сервиса
    function withdrawal(uint amount) public onlyOwner {
        require(amount <= balance);
        owner.transfer(amount);
        balance -= amount;
    }
    
    //изменение минимальной и максимальной стоимостей услуг
    function setLimits(uint _min, uint _max) public onlyOwner {
        min = _min;
        max = _max;
    }
}
