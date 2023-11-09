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

# tms
sqlplus / as sysdba << EOF
   ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
   create tablespace tms datafile '/opt/oracle/oradata/orcl/tms1.dbf' size 1G autoextend on next 256M;
   create user $tms_user identified by $tms_password default tablespace tms;
   grant connect,resource,create view,create job to tms_user;
   grant execute on dbms_crypto to tms_user;
   grant read, write on directory DATA_PUMP_DIR to tms_user;
   exit;
EOF
# wcpt
sqlplus / as sysdba << EOF
   create tablespace wcpt datafile '/opt/oracle/oradata/orcl/wcpt1.dbf' size 1G autoextend on next 256M;
   create user $wcpt_user identified by $wcpt_password default tablespace wcpt;
   grant connect,resource,create view,create job,create public database link,drop public database link to wcpt_user;
   grant execute on dbms_crypto to wcpt_user;
   grant read, write on directory DATA_PUMP_DIR to wcpt_user;
   exit;
EOF
# pay
sqlplus / as sysdba << EOF
   create tablespace pay datafile '/opt/oracle/oradata/orcl/pay1.dbf' size 1G autoextend on next 256M;
   create user $pay_user identified by $pay_password default tablespace pay;
   grant connect,resource,create view,create job to pay_user;
   grant read, write on directory DATA_PUMP_DIR to pay_user;
   exit;
EOF
