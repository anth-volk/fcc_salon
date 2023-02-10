#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --field-separator=, --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES_MENU

}

SERVICES_MENU() {
  # Display list of services available
  echo -e "\nWhich service would you like today?\n"
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services;")

  echo "$SERVICE_LIST" | while IFS=',' read SERVICE_ID SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  # Have user select service
  read SERVICE_ID_SELECTED

  # If selection not a number, return to main menu
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Invalid service selection. Please select a number."
  else
    # If selection not in db, return to main menu
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      MAIN_MENU "Service not found. Please select another."
    else
      APPOINTMENT_MENU
    fi
  fi
}

APPOINTMENT_MENU() {
  # Print arg1
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Have user input phone number
  echo -e "\nTo schedule an appointment, please type your phone number"
  read CUSTOMER_PHONE

  # If phone number not in db, send to REGISTRATION_MENU()
  # Otherwise, proceed to scheduling
  CUSTOMER_NAME=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]
  then
    REGISTRATION_MENU $CUSTOMER_PHONE
  else
    SCHEDULER_MENU $CUSTOMER_PHONE
  fi
}

SCHEDULER_MENU() {

  # Pull customer data based on customer_id
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

  # Ask user to input service time
  echo -e "\nPlease type the time you'd like your service"
  read SERVICE_TIME

  # Select customer_id based on phone
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
  APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  # Print exit message
  echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."

}

REGISTRATION_MENU() {
  # Prompt user for name
  echo -e "\nWe couldn't find your customer information. Please type your name."
  read CUSTOMER_NAME

  # Add customer to customers table
  CUSTOMER_INSERTION_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  
  # Test to ensure insertion worked correctly
  if [[ -z $CUSTOMER_INSERTION_RESULT ]]
  then
    MAIN_MENU "There was an error adding your customer information."
  else
    SCHEDULER_MENU
  fi

}


# If not customer, input name, then input customer into customers table

# Input time

# Create appointment record

# Output message for service

# Exit menu

# Display header
echo -e "\n~~~ SALON SERVICES ~~~"

MAIN_MENU