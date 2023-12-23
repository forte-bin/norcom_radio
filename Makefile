.PHONY: all build run reload clean

# Set RTL_DEVICE on the Env 
# $ RTL_DEVICE=/dev/bus/usb/001/002 make run
RTL_DEVICE_PROD="0bda:2838"
RTL_DEVICE_DEBUG="1d50:6089"
IMAGE=norcom_radio
CONTAINER=norcom_radio
FREQ=152007500

#only support having one radio connected at a time
export RTL_PATH=`./getradiopath.sh ${RTL_DEVICE_PROD} && ./getradiopath.sh ${RTL_DEVICE_DEBUG}`
#export RTL_PATH_DEBUG=`./getradiopath.sh ${RTL_DEVICE}`

all: build run

build:
	@echo "Building image..."
	docker build -t ${IMAGE}:latest .
	docker push ghcr.io/forte-bin/${IMAGE}:latest
deploy:
	@echo "RTL_PATH = ${RTL_PATH}"
	docker compose up -d
debug:
	@echo "RTL_PATH = ${RTL_PATH}"
	docker compose up 
reload:
	@echo "Copying files into container"
	docker cp . ${CONTAINER}:/app

clean:
	@echo "Deleting container"
	docker kill ${CONTAINER} || docker rm ${CONTAINER}

data: 
	@echo "repeating data from raw input"
	docker exec -it  `docker ps -q -f name=${CONTAINER}` "timeout 5 tail -20 app/raw|python3 /app/norcom_pager.py"
