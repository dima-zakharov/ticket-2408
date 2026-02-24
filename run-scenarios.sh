
source ./00-env.sh
nuclei -t . -var TOKEN=$TOKEN -var ADMIN_TOKEN=$ADMIN_TOKEN -var BASE_URL=$BASE_URL