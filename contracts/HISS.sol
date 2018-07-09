pragma solidity ^0.4.24;

contract Hiss {
    address public owner;
    uint public balance;
    
    uint public min = 50000000000000000;
    uint public max = 100000000000000000;
    
    constructor () public {
        owner = msg.sender;
    }

    enum typeOfMembership {NotRegistered, Patient, Hospital, InsuranceCompany} //тип участия
    
    mapping(address => mapping(uint => string)) public hashes; //получаем хеш данных по адреу и номеру записи
    
    mapping(address => uint) public numberOfNotes; //количество записей для данного адреса
    
    mapping(address => bool) public isInsuranceActive; // активна ли страховка для данного пациента
     
    mapping(address => string) public keyByAddress; //получаем открытый ключ пациента по адресу
   
    mapping(address => mapping(address => bool)) public accessByHospital; //по адресу пациента смотрим доступна ли запись для больницы с этим id (uint)

    mapping(address => string) public hospitalSign; //цифровая подись больниц, для подписи записей, добавляемых в базу (пока не используется)
    
    mapping(address => typeOfMembership) public typeByAddress; //получаем тип участия по адресу участника
    
    modifier isHospital() {
        require(typeByAddress[msg.sender] == typeOfMembership.Hospital);
        _;
    }
    
    modifier isPatient() {
        require(typeByAddress[msg.sender] == typeOfMembership.Patient);
        _;
    }
    
    modifier isInsuranceCompany() {
        require(typeByAddress[msg.sender] == typeOfMembership.InsuranceCompany);
        _;
    }
    
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    
    //владелец сервиса добавляет страховые
    function addInsuranceCompany (address addr) public isOwner {
        require(typeByAddress[addr] == typeOfMembership.NotRegistered);
        typeByAddress[addr] = typeOfMembership.InsuranceCompany;
    }
    
    
    //страховые добавляют пациентов
    function addPatient (address addr, string publicKey, string firstNote) public payable isInsuranceCompany {
        require(msg.value >= min && msg.value <= max);
        require(typeByAddress[addr] == typeOfMembership.NotRegistered);
        typeByAddress[addr] = typeOfMembership.Patient;
        keyByAddress[addr] = publicKey;
        hashes[addr][0] = firstNote; // первое посещение
        numberOfNotes[addr]++;
        balance += msg.value;
    }
    //страховые добавляют больницы
    function addHospital (address addr, string digitalSign) public payable isInsuranceCompany {
        require(msg.value >= min && msg.value <= max);
        require(typeByAddress[addr] == typeOfMembership.NotRegistered);
        typeByAddress[addr] = typeOfMembership.Hospital;
        hospitalSign[addr] = digitalSign;
        balance += msg.value;
    }
    //старховые управляют страховкой пациента
    function setInsuranceStatus (address addr, bool flag) public isInsuranceCompany {
        require(typeByAddress[addr] == typeOfMembership.Patient);
        isInsuranceActive[addr] = flag;
    }
    
    //пациент разрешает добавлять новую запись больнице
    function consentToAddData(address addr) public isPatient {
        require(typeByAddress[addr] == typeOfMembership.Hospital);
        accessByHospital[msg.sender][addr] = true;
    }
    
    //больница добавляет данные только с разрешения
    function addNewNote(address addr, string note) public isHospital {
        require(typeByAddress[addr] == typeOfMembership.Patient);
        require(accessByHospital[addr][msg.sender] == true);
        hashes[addr][numberOfNotes[addr]] = note;
        numberOfNotes[addr]++;
        accessByHospital[addr][msg.sender] = false;
    }
    
    //вывод средств на кошелек владельца сервиса
    function withdrawal(uint amount) public isOwner {
        require(amount <= balance);
        owner.transfer(amount);
        balance -= amount;
    }
    
    //изменение минимальной и максимальной стоимостей услуг
    function setLimits(uint _min, uint _max) public isOwner {
        min = _min;
        max = _max;
    }
}
