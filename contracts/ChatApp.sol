
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


contract ChatApp {
    struct user{
        string name;
        friend[] friendList;
    }

    struct friend{
        address pubkey;
        string name;
    }

    struct message{
        address sender;
        uint256 timestamp;
        string msg;
    }

    struct AllUserStruct{
        string name;
        address accountAddress;

    }
    AllUserStruct[] getAllUsers;

    mapping(address => user) userList;
    mapping(bytes32 => message) allMessages;


//user exist check
    function checkUserExists(address pubkey) public view returns(bool){
        return bytes(userList[pubkey].name).length > 0;
    }

//create account
    function createAccount(string calldata name) external {
    require(checkUserExists(msg.sender) ==  false,"User already exists");
    require(bytes(name).length>0, "Username cannot be empty");

    userList[msg.sender].name = name;
    getAllUsers.push(AllUserStruct(name,msg.sender));

    }

//get username
    function getUsername( address pubkey) external view returns(string memory){
        require(checkUserExists(pubkey),"User not registered");
        return userList[pubkey].name;

    }

//add friend
    function addFriend(address friend_key,string calldata name)external{
        require( checkUserExists(msg.sender),"Create an account first");
        require(checkUserExists(friend_key),"User is not registered");
        require(msg.sender != friend_key,"User cannot add themself as friend");
        require(checkAlreadyFriends(msg.sender,friend_key)== false,"Friend already exist");
        
        _addFriend(msg.sender,friend_key,name);
        _addFriend(friend_key,msg.sender,userList[msg.sender].name);

    }


//checkalready friend
    function checkAlreadyFriends(address pubkey1,address pubkey2) internal view returns (bool){
        if(userList[pubkey1].friendList.length > userList[pubkey2].friendList.length){
            address temp= pubkey1;
            pubkey1 = pubkey2;
            pubkey2 = temp;
        }
        for(uint256 i = 0;i<userList[pubkey1].friendList.length;i++){

            if(userList[pubkey1].friendList[i].pubkey == pubkey2)return true;
        }

        return false;

    }


//
    function _addFriend(address me,address friend_key,string memory name)internal{
        friend memory newFriend = friend(friend_key,name);
        userList[me].friendList.push(newFriend);
    }


//get my friend
    function getMyFriendList() external view returns(friend[] memory){
        return userList[msg.sender].friendList;

    }


//chatcode
    function _getChatCode(address pubkey1,address pubkey2 )internal pure returns(bytes32){
        if(pubkey1<pubkey2){
            return keccak256(abi.encodePacked(pubkey1,pubkey2));

        }
        else 
        return keccak256(abi.encodePacked(pubkey2,pubkey1));

    }


//send message
    function sendMessage(address friend_key,string calldata _msg)external {
        require(checkUserExists(msg.sender),"Creste an account first");
        require(checkUserExists(friend_key),"user is not registred");
        require(checkAlreadyFriends(msg.sender,friend_key),"you are not friend with the given user");
        bytes32 chatCode=_getChatCode(msg.sender,friend_key);
        message memory newMsg = message(msg.sender,block.timestamp,_msg);
        allMessages[chatCode].push(newMsg);
        
    }



//read message
    function readMessage(address friend_key) external view returns(message[] memory) {
        bytes32 chatcode = _getChatCode(msg.sender,friend_key);
        return allMessages[chatcode];

    }



    function getAllAppUsers()public view returns (AllUserStruct[]memory) {
        return getAllUsers;
    }



    
}