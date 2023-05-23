# autocylons

This is a hackathon project for the [ETHGlobal Autonomous Worlds](https://ethglobal.com/events/autonomous) hackathon. 

Here is the [initial concept pitch deck](https://docs.google.com/presentation/d/1NTXjf348vRfqvpuiooTwFVi_AW8K4ZjuurIhTBsS7Ds/edit#slide=id.p).


Please run the following commands to generate an output : 


node -e "require('./scripts/player1').createGame()"
node -e "require('./scripts/player2').joinLobby(0)"
node -e "require('./scripts/player3').joinLobby(0)"
node -e "require('./scripts/player4').joinLobby(0)"
node -e "require('./scripts/player1').startGame(0)"
node -e "require('./scripts/player2').startGame(0)"
node -e "require('./scripts/player3').startGame(0)"
node -e "require('./scripts/player4').startGame(0)"
node -e "require('./scripts/player1').mafiaKills(0)"
node -e "require('./scripts/player2').mafiaKills(0)"
node -e "require('./scripts/player3').mafiaKills(0)"
node -e "require('./scripts/player4').mafiaKills(0)"
node -e "require('./scripts/player1').castVotes(0)"
node -e "require('./scripts/player2').castVotes(0)"
node -e "require('./scripts/player3').castVotes(0)"
node -e "require('./scripts/player4').castVotes(0)"

"0" is the gameId which will be generated by the first statement. Put that game id as input in all the remaining statements.


