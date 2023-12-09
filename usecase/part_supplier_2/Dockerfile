FROM golang:1.21.1-alpine

# Create directory for our app inside the container
WORKDIR /app

# Prepare dependencies
COPY go.mod ./
COPY go.sum ./
RUN go mod download

# Copy code /to the container image.
COPY . ./

# Build the binary and call it "docker-part-supplier-2"
RUN go build -tags jwx_es256k -o /docker-part-supplier-2 ./

EXPOSE 3000

CMD [ "/docker-part-supplier-2" ]
