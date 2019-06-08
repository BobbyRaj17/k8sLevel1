if [ $# -lt 4 ]; then
  echo 1>&2 "$0: Not enough arguments :: Script requires four arguments \n 1.Total No of connection to the service e.g. 200 \n 2. Total no of thread to the service e.g. 200 \n 3. Max time the script will run e.g. 10m \n 4. Url to test the load against e.g. https://google.com"
  exit 2
elif [ $# -gt 4 ]; then
  echo 1>&2 "$0: Too many arguments :: Script requires four arguments \n 1.Total No of connection to the service e.g. 200 \n 2. Total no of thread to the service e.g. 200 \n 3. Max time the script will run e.g. 10m \n 4. Url to test the load against e.g. https://google.com"
  exit 2
fi


#Total No of connection to the service
connection=$1

#Total no of thread to the service
thread=$4

#Max time the script will run
time=$2

#Url to test the load against
url=$3


#Produce some load on the service we will use, a tool called wrk
docker run --rm loadimpact/loadgentest-wrk -c $1 -t $2 -d $3 $4