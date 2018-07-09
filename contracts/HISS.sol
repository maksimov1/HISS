pragma solidity ^0.4.24;
contract Hiss{
    address public owner;
    uint public total;
    uint public balance;
    constructor () public {
        owner = msg.sender;
    }

    
    
    
    mapping(address => mapping(uint => string)) public hashes; //получаем хеш данных по адреу и номеру записи
    mapping(address => uint) public numberOfNotes; //количество записей для данного адреса
    
    mapping(address => bool) public isInsuranceActive; // активна ли страховка для данного пациента
    
    //mapping(string => address) public addressByKey; //не надо  
    mapping(address => string) public keyByAddress;
   
    mapping(address => bool) public hospitalAccess; //по адресу пациента смотрим доступна ли запись для
                                                             //больницы с этим id (uint)
    mapping(address => string) public hospitalSign;
    
    
    enum typesOfMember {NotRegistered, Patient, Hospital, Insurance}
    
    mapping(address => typesOfMember) public typeOfMember; 
    
    modifier isHospital(){
        require(typeOfMember[msg.sender] == typesOfMember.Hospital);
        _;
    }
    
    modifier isPatient(){
        require(typeOfMember[msg.sender] == typesOfMember.Patient);
        _;
    }
    
    modifier isInsurance(){
        require(typeOfMember[msg.sender] == typesOfMember.Insurance);
        _;
    }
    
    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }
    
    //мы добавляем страховые
    function addInsurance (address addr) public isOwner{
        typeOfMember[addr] = typesOfMember.Insurance;
    }
    
    function withdrawal(uint amount) public isOwner{
        require(amount<=balance);
        owner.transfer(amount);
        balance-=amount;
    }
    
    //страховые добавляют пациентов
    function addPatient (address addr, string publicKey, string firstNote) public payable isInsurance{
        require(msg.value >=5000000000000000000 && msg.value<=10000000000000000000);
        require(typeOfMember[addr] == typesOfMember.NotRegistered);
        typeOfMember[addr] = typesOfMember.Patient;
        keyByAddress[addr] = publicKey;
        hashes[addr][0] = firstNote; // первое посещение
        numberOfNotes[addr]++;
        balance+=msg.value;
    }
    //страховые добавляют больницы
    function addHospital (address addr, string digitalSign) public payable isInsurance{
        require(msg.value >=5000000000000000000 && msg.value<=10000000000000000000);
        require(typeOfMember[addr] == typesOfMember.NotRegistered);
        typeOfMember[addr] = typesOfMember.Hospital;
        hospitalSign[addr] = digitalSign;
        balance+=msg.value;
    }
    //управляют страховкой пациента
    function setInsurance (address addr, bool flag) public isInsurance{
        
        require(typeOfMember[addr] == typesOfMember.Patient);
        isInsuranceActive[addr] = flag;
        
    }
    
    //пациент разрешает добавлять новую запись больнице
    function consentToAddData(address addr) public isPatient{ //сейчас разрешаем на все время потом сделаем(подумаем) на одно
        require(typeOfMember[addr] == typesOfMember.Hospital);
        hospitalAccess[addr] = true;
    }
    
    //больница добавляет данные только с разрешения
    function addNewNote(address addr, string note) public isHospital{
        require(typeOfMember[addr] == typesOfMember.Patient);
        require(hospitalAccess[addr] == true);
        hashes[addr][numberOfNotes[addr]] = note;
        numberOfNotes[addr]++;
    }
}
