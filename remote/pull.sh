#!/bin/bash

RESULT=$(cd ./slaver-config && hg pull && hg update)

echo $RESULT
