#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_SERVICES(){
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi
  #get services from the db
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  #display list of services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME service"
  done
  
  read SERVICE_ID_SELECTED
  SERVICES_AVAILABLE=$($PSQL "SELECT service_id,name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
  if [[ -z $SERVICES_AVAILABLE ]]
  then 
    MAIN_SERVICES "I could not find that service. What would you like today?"
  else
    USING_SERVICE
  fi

}

USING_SERVICE() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  PHONE_RECORDED=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $PHONE_RECORDED ]]
  then 
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUST_INFO=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    MAKE_APPOINTMENT
  else
    MAKE_APPOINTMENT
  fi
}
MAKE_APPOINTMENT(){
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
  SERVICE_FORMATED=$(echo $SERVICE | sed -E 's/^ //g')
  CUS_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME_FORMATED=$(echo $CUS_NAME | sed -E 's/^ //g')
  echo -e "\nWhat time would you like your $SERVICE_FORMATED, $CUSTOMER_NAME_FORMATED?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_FORMATED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATED."
}
MAIN_SERVICES
