
#!/bin/bash

echo "$1" | sed s/\'/\"/g | sed s/None/null/g
