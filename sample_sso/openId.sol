pragma solidity ^0.4.23;

contract OpenId {
    address creator;
    mapping(string => address) private ownerMap;
    
    struct addrData {
        uint index;
        string data;
        address register;
        bool flag;
    }
    
    address[] private addrArray;
    mapping(string => address) private idAddrMap;
    mapping(uint => string) private indexIdMap;
    mapping(address => addrData) private addrDataMap;
    
    event ChangeOwnerEvent(string _flag, address _caller, string _sstCd, address _owner);
    event ChangeUserEvent(string _flag, address _caller, string _sstCd, address _userAddr, string _id, string _data);
    event TestLog(address _address);
    
    modifier onlyCreator () {
        require(msg.sender == creator, "msg sender is no creator");
        _;
    }
    
    modifier onlyOwner (string _sstCd, address _ownerAddress) {
        require(ownerMap[_sstCd] == _ownerAddress, "msg sender is no owner");
        _;
    }
    
    modifier checkMember {
        require(addrDataMap[msg.sender].flag, "msg sender is no member");
        _;
    }
    
    function OpenId () {
        creator = msg.sender;
        ownerMap["creator"] = msg.sender;
    }
    
    function addOwner (string _sstCd, address _owner) onlyCreator {
        emit TestLog(ownerMap[_sstCd]);
        if(keccak256(_sstCd) != keccak256("creator") && ownerMap[_sstCd] == address(0x0)) {
            ownerMap[_sstCd] = _owner;
            emit ChangeOwnerEvent("add", msg.sender, _sstCd, _owner);
        }
    }
    
    function removeOwner (string _sstCd, address _owner) onlyCreator {
        if(keccak256(_sstCd) != keccak256("creator") && ownerMap[_sstCd] != address(0x0)) {
            delete ownerMap[_sstCd];
            emit ChangeOwnerEvent("remove", msg.sender, _sstCd, _owner);
        }
    }
    
    function isOwner (string _sstCd, address _address) view returns (bool) {
        return ownerMap[_sstCd] == _address;
    }
    
    function createUserInfo (string _sstCd, address _ownerAddress, address _userAddr, string _id, string _data) onlyOwner(_sstCd, _ownerAddress) {
        addrArray.push(_userAddr);
        uint _index = addrArray.length-1;
        
        idAddrMap[_id] = _userAddr;
        indexIdMap[_index];
        addrDataMap[_userAddr] = addrData({
            index : _index
            , data : _data
            , register : _ownerAddress
            , flag : true
        });
        emit ChangeUserEvent("add", msg.sender, _sstCd, _userAddr, _id, _data);
    }
    
    function getUserInfo (string _sstCd, address _ownerAddress, address _userAddr) onlyOwner(_sstCd, _ownerAddress) view returns (string) {
        return addrDataMap[_userAddr].data;
    }
    
    function getUserInfo (string _sstCd, address _ownerAddress, string _id) onlyOwner(_sstCd, _ownerAddress) view returns (string) {
        return addrDataMap[idAddrMap[_id]].data;
    }
    
    function getUserInfo (string _sstCd, address _ownerAddress, uint _index) onlyOwner(_sstCd, _ownerAddress) view returns (string) {
        return addrDataMap[addrArray[_index]].data;
    }
    
    function isExistUser (address _userAddr) view returns (bool) {
        return addrDataMap[_userAddr].register != address(0x0);
    }
    
    /* 비밀번호 변경하면 문제됨 */
    

    /**********
     Standard kill() function to recover funds 
     **********/
    function kill() {
        if (msg.sender == creator) {
            suicide(creator); // kills this contract and sends remaining funds back to creator
        }
    }
}
