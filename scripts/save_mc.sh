#!/bin/bash

INST_MC_DIR=$1
tar -zcf $INST_MC_DIR/saves-`date +%Y%m%d%H%M`.tgz $INST_MC_DIR/saves
