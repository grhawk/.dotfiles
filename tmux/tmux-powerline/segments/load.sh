#!/usr/bin/env sh
# Print the average load.
uptime | awk '{printf"u %3.1f:%3.1f",$9,$10}'

exit 0
