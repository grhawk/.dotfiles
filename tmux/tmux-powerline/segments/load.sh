#!/usr/bin/env sh
# Print the average load.
uptime | awk '{printf"u %3.1f:%3.1f",$(NF-2),$(NF-1)}'

exit 0
