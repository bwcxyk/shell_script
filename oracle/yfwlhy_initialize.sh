#!/bin/bash

if [ "$1" != "" ];
    then
    data_dir="$1"
fi

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
   create tablespace tms datafile '$data_dir/tms1.dbf' size 1G autoextend on next 256M;
   create temporary tablespace tms_t tempfile '$data_dir/tms_t1.dbf' size 1G autoextend on next 256M;
   create user $tms_user identified by $tms_password default tablespace tms temporary tablespace tms_t;
   grant connect,resource,create view,create job to tms_user;
   grant execute on dbms_crypto to tms_user;
   grant read, write on directory DATA_PUMP_DIR to tms_user;
   exit;
EOF
# wcpt
sqlplus / as sysdba << EOF
   create tablespace wcpt datafile '$data_dir/wcpt1.dbf' size 1G autoextend on next 256M;
   create temporary tablespace wcpt_t tempfile '$data_dir/wcpt_t1.dbf' size 1G autoextend on next 256M;
   create user $wcpt_user identified by $wcpt_password default tablespace wcpt temporary tablespace wcpt_t;
   grant connect,resource,create view,create job,create public database link,drop public database link to wcpt_user;
   grant execute on dbms_crypto to wcpt_user;
   grant read, write on directory DATA_PUMP_DIR to wcpt_user;
   exit;
EOF
# pay
sqlplus / as sysdba << EOF
   create tablespace pay datafile '$data_dir/pay1.dbf' size 1G autoextend on next 256M;
   create temporary tablespace pay_t tempfile '$data_dir/pay_t1.dbf' size 1G autoextend on next 256M;
   create user $pay_user identified by $pay_password default tablespace pay temporary tablespace pay_t;
   grant connect,resource,create view,create job to pay_user;
   grant read, write on directory DATA_PUMP_DIR to pay_user;
   exit;
EOF
