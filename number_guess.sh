#!/bin/bash

# Connect to the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Get username
echo "Enter your username:"
read USERNAME

# Check if user exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# If user doesn't exist
if [[ -z $USER_ID ]]
then
  # Welcome new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  
  # Add user to database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # Get user stats
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
  
  # Welcome returning user
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start the game
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1

# Loop until correct guess
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  
  read GUESS
  ((NUMBER_OF_GUESSES++))
done

# Update user stats
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
NEW_GAMES_PLAYED=$(($GAMES_PLAYED + 1))

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NUMBER_OF_GUESSES WHERE user_id=$USER_ID")
else
  UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE user_id=$USER_ID")
fi

# Print success message
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
#