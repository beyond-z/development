#!/bin/bash
echo "Updating salesforce   ------------- "
(cd salesforce; git checkout master; git pull upstream master; git push origin master;)
echo "Updating rubycas-server  ------------- "
(cd rubycas-server; git checkout master; git pull upstream master; git push origin master;)
echo "Updating braven  ------------- "
(cd braven; git checkout staging; git pull upstream staging; git push origin staging;)
echo "Updating beyondz-platform  ------------- "
(cd beyondz-platform; git checkout staging; git pull upstream staging; git push origin staging;)
echo "Updating canvas-lms  ------------- "
(cd canvas-lms; git checkout bz-staging; git pull upstream bz-staging; git push origin bz-staging;)
echo "Updating osqa  ------------- "
(cd osqa; git checkout master; git pull upstream master; git push origin master;)
