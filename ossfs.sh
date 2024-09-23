#! /bin/bash
#
# ossfs      Automount Aliyun OSS Bucket in the specified direcotry.
#
# chkconfig: 2345 90 10
# description: Activates/Deactivates ossfs configured to start at boot time.

ossfs backup /data/ossfs -ourl=http://oss-cn-shanghai-internal.aliyuncs.com -oallow_other -ouid=1000 -ogid=1000
