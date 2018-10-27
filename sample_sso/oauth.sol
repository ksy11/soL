pragma solidity ^0.4.23;

contract Oauth {
    address creator;
    address openIdContractAddress;
    
    struct loginData {
        string accTkn;
        string rfsTkn;
        uint lastLoginDT;
        uint lastLogoutDT;
    }
    
    uint _seed = 0;
    uint _nonce = 0;
    
    mapping(address => loginData) private userDataMap;
    
    function Oauth (address _openIdContractAddress) {
        creator = msg.sender;
        openIdContractAddress = _openIdContractAddress;
    }
    
    function checkAccTkn(string _sstCd, address _ownerAddress, address _address, string _accTkn) view returns (bool) {
        require(chekIsOwner(_sstCd, _ownerAddress), "address is no owner");
        return keccak256(userDataMap[_address].accTkn) == keccak256(_accTkn);
    }
    
    function getAccTkn(string _sstCd, address _ownerAddress, address _address, string _rfsTkn) view returns (string) {
        return keccak256(userDataMap[_address].rfsTkn) == keccak256(_rfsTkn) ? userDataMap[_address].accTkn : "F";
    }
    
    function getRfsTkn(string _sstCd, address _ownerAddress, address _address) view returns (string) {
        require(chekIsOwner(_sstCd, _ownerAddress), "address is no owner");
        return userDataMap[_address].rfsTkn;
    }
    
    function login() {
        require(chekUser(msg.sender), "msg sender is no user");
        _nonce++;
        string memory _accTkn = uint2str(uint(keccak256(keccak256(block.blockhash(block.number), _seed, msg.sender), now)));
        string memory _rfsTkn = uint2str(uint(keccak256(keccak256(block.blockhash(block.number), _seed, _nonce, msg.sender), now)));
        userDataMap[msg.sender] = loginData({
            accTkn : _accTkn
            , rfsTkn : _rfsTkn
            , lastLoginDT : now
            , lastLogoutDT : 0
        });
    }
    
    function uint2str(uint i) internal returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    
    function getLoginUser(address _userAddress) view returns(string, string, uint, uint) {
        return (userDataMap[_userAddress].accTkn, userDataMap[_userAddress].rfsTkn, userDataMap[_userAddress].lastLoginDT, userDataMap[_userAddress].lastLogoutDT);
    }
    
    function chekUser(address _userAddress) private returns(bool c) {
        address addr = address(openIdContractAddress);  //Place the test1 address on the stack
        bytes4 sig = bytes4(keccak256("isExistUser(address)"));
        assembly {
            let x := mload(0x40)   //Find empty storage location using "free memory pointer"
            mstore(x,sig) //Place signature at begining of empty storage 
            mstore(add(x,0x04), _userAddress) //Place first argument directly next to signature
            //mstore(add(x,0x24),b) //Place second argument next to first, padded to 32 bytes
        
            let success := call(      //This is the critical change (Pop the top stack value)
                                gas, //5k gas
                                addr, //To addr
                                0,    //No value
                                x,    //Inputs are stored at location x
                                0x24, //Inputs are 68 bytes long
                                x,    //Store output over input (saves space)
                                0x20) //Outputs are 32 bytes long
        
            c := mload(x)
            mstore(0x40, add(x,0x20)) // update free memory pointer
        }
    }
    
    function chekIsOwner(string _sstCd, address _address) private returns(bool c) {
        address addr = address(openIdContractAddress);  //Place the test1 address on the stack
        bytes4 sig = bytes4(keccak256("isOwner(string,address)"));
        bytes32 sstCdBytes = stringToBytes32(_sstCd);
        uint u64 = 64;
        uint u5 = bytes(_sstCd).length;
        assembly {
            let x := mload(0x40)
            mstore(x,sig)                               // 4byte
            mstore(add(x,0x04), u64)                    // 32byte
            mstore(add(x,0x24), _address)               // 32byte
            mstore(add(x,0x44), u5)                     // 32byte
            mstore(add(x,0x64), sstCdBytes)             // 32byte
            
            let success := call(      //This is the critical change (Pop the top stack value)
                                gas, //5k gas
                                addr, //To addr
                                0,    //No value
                                x,    //Inputs are stored at location x
                                0x84, //Inputs are 68 bytes long
                                x,    //Store output over input (saves space)
                                0x20) //Outputs are 32 bytes long
        
            c := mload(x)
            mstore(0x40, add(x,0x20)) // update free memory pointer
        }
    }
    
    function stringToBytes32(string memory source) returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function logout() {
        userDataMap[msg.sender].accTkn = "";
        userDataMap[msg.sender].rfsTkn = "";
        userDataMap[msg.sender].lastLogoutDT = now;
    }
    
//    function logoutAccTkn(string _accTkn) {
//        loginData userLogin = userDataMap[msg.sender];
//        if(keccak256(userLogin.accTkn) == keccak256(_accTkn)){
//            userDataMap[msg.sender].accTkn = "";
//            userDataMap[msg.sender].rfsTkn = "";
//            userDataMap[msg.sender].lastLogoutDT = now;
//        }
//    }
//    
//    function logoutRfsTkn(string _rfsTkn) {
//        loginData userLogin = userDataMap[msg.sender];
//        if(keccak256(userLogin.rfsTkn) == keccak256(_rfsTkn)){
//            userDataMap[msg.sender].accTkn = "";
//            userDataMap[msg.sender].rfsTkn = "";
//            userDataMap[msg.sender].lastLogoutDT = now;
//        }
//    }

    /**********
     Standard kill() function to recover funds 
     **********/
    function kill() {
        if (msg.sender == creator) {
            suicide(creator); // kills this contract and sends remaining funds back to creator
        }
    }
}
