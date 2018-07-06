pragma solidity ^0.4.21;
contract Hiss{
    mapping(address => mapping(uint => string)) hashes; //получаем хеш данных по адреу и номеру записи
    mapping(address => uint) numberOfNotes; //количество записей для данного адреса
    
    mapping(string => address) addressByKey; //адрес пациента <=> public Key    
    mapping(address => string) keyByAddress;
   
    mapping(address => mapping(uint => bool)) hospitalAcess; //по адресу пациента смотрим доступна ли запись для
                                                             //больницы с этим id (uint)
    enum typesOfMember {Hospital, Insurance, Patient}
    
    mapping(address => typesOfMember) typeOfMember; 
    
    modifier isHospital(){
        require(typeOfMember[msg.sender] == typesOfMember.Hospital);
        _;
    }
   
    function createNote(address adr, string note) public isHospital {
        hashes[adr][numberOfNotes[adr]] = note;
        numberOfNotes[adr] = numberOfNotes[adr] + 1;
    }
    //debug function
    function readNote(address adr, uint numberOfNote) public returns (string){
        return hashes[adr][numberOfNote];
    }
}
