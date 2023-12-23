.PHONY: all build run reload clean

# Set RTL_DEVICE on the Env 
# $ RTL_DEVICE=/dev/bus/usb/001/002 make run
RTL_DEVICE='0bda:2838'
export RTL_PATH=`./getradiopath.sh ${RTL_DEVICE}`
IMAGE=norcom_radio
CONTAINER=norcom_radio
FREQ=152007500

all: build run

build:
	@echo "Building image..."
	docker build -t ${IMAGE}:latest .
	docker push ghcr.io/forte-bin/${IMAGE}:latest
deploy:
	docker compose up -d
debug:
	@echo "Launching container with RTL device at ${RTL_DEVICE}"
	docker run -it --device=${RTL_DEVICE} -e "RTL_DEVICE=${RTL_DEVICE}" -e FREQ=${FREQ}  --name ${CONTAINER} ${IMAGE}:latest
reload:
	@echo "Copying files into container"
	docker cp . ${CONTAINER}:/app

clean:
	@echo "Deleting container"
	docker kill ${CONTAINER} || docker rm ${CONTAINER}

data: 
	@echo "repeating data from raw input"
	docker exec -it  `docker ps -q -f name=${CONTAINER}` "timeout 5 tail -20 app/raw|python3 /app/norcom_pager.py"
