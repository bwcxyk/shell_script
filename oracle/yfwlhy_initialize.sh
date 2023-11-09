#!/bin/bash

tms_user=tms_user
tms_password=$(openssl rand -base64 12)
wcpt_user=wcpt_user
wcpt_password=$(openssl rand -base64 12)
pay_user=pay_user
pay_password=$(openssl rand -base64 12)

echo "tms_password:$tms_password"
echo "wcpt_password:$wcpt_password"
echo "pay_password:$pay_password"

sqlplus / as sysdba << EOF
   ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
   create user $tms_user identified by $tms_password default tablespace tms;
   create user $wcpt_user identified by $wcpt_password default tablespace tms;
   create user $pay_user identified by $pay_password default tablespace tms;
   grant read, write on directory DATA_PUMP_DIR to tms_user;
   grant read, write on directory DATA_PUMP_DIR to wcpt_user;
   grant read, write on directory DATA_PUMP_DIR to pay_user;
   exit;
EOF
