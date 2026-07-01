#!/bin/bash

#!/bin/bash
mkdir "/var/log/j3dnas/$(date +%F)" -p

set -x
echo "output" >> "./output.txt"
ls -a >> "./output.txt"
echo "hello world completed"