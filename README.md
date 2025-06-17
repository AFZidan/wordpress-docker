### Run Wordpress with Docker

This repository contains a simple setup to run a Wordpress instance using Docker. It includes a Dockerfile and a docker-compose.yml file to facilitate the deployment.

### Prerequisites

- Docker installed on your machine
- Docker Compose installed (if not included with your Docker installation)

### Usage

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Build the Docker image and start the containers:

   ```bash
   docker-compose up -d --build
   ```

3. Access your Wordpress instance by navigating to `http://localhost:8000` in your web browser.
4. To stop the containers, run:

   ```bash
   docker-compose down
   ```

### Configuration

You can customize the Wordpress instance by modifying the `docker-compose.yml` file. Here are some common configurations:
