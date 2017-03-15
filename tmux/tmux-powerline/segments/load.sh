#!/usr/bin/env sh
# Print the average load.
uptime | awk '{printf"u %3.1f:%3.1f",$8,$9}'

exit 0
