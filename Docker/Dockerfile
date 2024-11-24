# Build stage
FROM golang:1.23 as builder

# Set working directory
WORKDIR /app

# Copy the Go application code
COPY . .

# Build the application
#RUN go build -o hello-app
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o hello-app


# Runtime stage
FROM scratch

# Copy the binary from the builder stage
COPY --from=builder /app/hello-app .

# Expose the port the app runs on
EXPOSE 8080

# Run the application
CMD ["./hello-app"]
