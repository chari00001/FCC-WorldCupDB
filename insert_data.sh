#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo -e "$($PSQL "TRUNCATE teams, games;")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  if [[ $YEAR != year ]]
    then
      # INSERT TEAMS

      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

      if [[ -z $WINNER_ID ]]
        then
          INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
          if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
            then
              echo "Inserted team, $WINNER"
          fi
          
          WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
      fi
      if [[ -z $OPPONENT_ID ]]
        then
          INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
          if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
            then
              echo "Inserted team, $OPPONENT"
          fi

          OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
      fi

      # INSERT GAMES

      TEAMS_ID=$($PSQL "SELECT winner_id,opponent_id FROM games WHERE winner_id='$WINNER_ID' AND opponent_id='$OPPONENT_ID';")
      if [[ -z $TEAMS_ID ]]
        then
          INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $W_GOALS, $O_GOALS);")
          if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
            then
              echo "Inserted game, $WINNER / $OPPONENT: $W_GOALS - $O_GOALS ($ROUND, $YEAR)"
          fi
      fi
  fi
done