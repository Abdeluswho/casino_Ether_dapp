pragma solidity ^0.4.21;


contract Casino {
   address public owner;
   uint256 public minBet;
   uint256 public totalBet;
   uint256 public numberOfBets;
   uint256 public maxBet = 100;
   address[] public players;

   struct Player {
       uint256 amountBet;
       uint256 numberSelected;
   }

   // The address of the player and => the user info   
   mapping(address => Player) public playerInfo;


   function Casino(uint256 _minBet) public {
      owner = msg.sender;
      if (_minBet != 0)
      minBet = _minBet;
   }

   function kill() public {
      if (msg.sender == owner)
        selfdestruct(owner);
   }

   function checkPlayer(address player) public constant returns(bool) {
      for (uint256 i = 0; i < players.length; i++) {
         if (players[i] == player) 
         return true;
      }
      return false;
   }

    // To bet for a number between 1 and 10
   function bet(uint256 numberSelected) public payable {
       require(!checkPlayer(msg.sender));
       require(numberSelected >= 1 && numberSelected <= 10);
       require(msg.value >= minBet);

       playerInfo[msg.sender].amountBet = msg.value;
       playerInfo[msg.sender].numberSelected = numberSelected;
       numberOfBets++;
       players.push(msg.sender);
       totalBet += msg.value;
       if (numberOfBets >= maxBet)
       generateNumberWinner();
   }

   // Generates a number between 1 and 10 that will be the winner
   function generateNumberWinner() public {
       // This isn't secure due to block number visibility
      uint256 numberGenerated = block.number % 10 + 1; 
      distributePrizes(numberGenerated);
   }

   // Sends the corresponding ether to each winner depending on the total bets
   function distributePrizes(uint256 numberWinner) public {
       // We have to create a temporary in memory array with fixed size
      address[100] memory winners; 
      // This is the count for the array of winners
      uint256 count = 0; 

      for (uint256 i = 0; i < players.length; i++) {
         address playerAddress = players[i];
         if (playerInfo[playerAddress].numberSelected == numberWinner) {
            winners[count] = playerAddress;
            count++;
         }
         // Delete all the players
         delete playerInfo[playerAddress]; 
      }

      // Delete all the players array
      players.length = 0; 
      // How much each winner gets
      uint256 winnerEtherAmount = totalBet / winners.length;

      for (uint256 j = 0; j < count; j++) {
        // Check that the address in this fixed array is not empty
         if (winners[j] != address(0)) 
         winners[j].transfer(winnerEtherAmount);
      }
   }
}

