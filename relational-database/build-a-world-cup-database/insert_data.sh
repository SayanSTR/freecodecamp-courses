#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Delete existing data
echo $($PSQL "TRUNCATE TABLE games, teams;")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART;")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART;")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != 'year' ]] 
then
  # check if winner team is already in teams table or not
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  if [[ -z $WINNER_ID ]] 
  then
    # insert winner team name
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
    if [[ $INSERT_WINNER_RESULT='INSERT 0 1' ]] 
    then
      echo -e "\nInserted into teams : $WINNER"
      # get generated team_id for newly inserted team
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi
  fi
  # check if opponent team is already in teams table or not
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
  if [[ -z $OPPONENT_ID ]]
  then
    # insert opponent team name
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
    if [[ $INSERT_OPPONENT_RESULT='INSERT 0 1' ]]
    then
      echo -e "\nInserted into teams : $OPPONENT"
      # get generated team_id for newly inserted team
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi
  fi
  # check if game already exist in games table
  GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id='$WINNER_ID' AND opponent_id='$OPPONENT_ID';")
  if [[ -z $GAME_ID ]]
  then
    # insert game data
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND','$WINNER_ID','$OPPONENT_ID','$WINNER_GOALS','$OPPONENT_GOALS');")
    if [[ $INSERT_GAME_RESULT='INSERT 0 1' ]]
    then
      echo -e "\n Inserted into games : $YEAR, $ROUND, $WINNER, $OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS"
    fi
  fi
fi
done
