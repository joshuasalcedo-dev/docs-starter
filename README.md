# Documentation App

A wiki-style documentation system built with Spring Boot and Vaadin.

## Features

- Create, edit, view, and organize documentation entries
- Organize documentation by sections
- Search functionality
- Export and import capabilities
- Responsive UI with app bar and navigation menu
- Persistent storage with H2 database
- Docker support

## Getting Started

### Prerequisites

- Java 21 or later
- Maven 3.6 or later
- Docker (optional, for containerized deployment)

### Running the Application

#### Using the run script:

```bash
./run-docs-app.sh
```

This script will detect if Docker is available and run the application accordingly:
- If Docker is installed, it will run the application in a Docker container
- If Docker is not installed, it will build and run the application locally

#### Running manually:

1. Build the application:
   ```bash
   ./mvnw clean package
   ```

2. Run the application:
   ```bash
   java -jar target/*.jar
   ```

### Using Docker

1. Build the Docker image:
   ```bash
   docker build -t documentation-app .
   ```

2. Run the container:
   ```bash
   docker run -p 8080:8080 -v $HOME/.docs/documentation:/root/.docs/documentation documentation-app
   ```

## Storage

The application stores its data in an H2 database located at:
```
$HOME/.docs/documentation/db
```

## Usage

1. Access the application at [http://localhost:8080](http://localhost:8080)
2. Use the navigation menu to browse sections or create new documentation entries
3. Use the search functionality to find specific content
4. Export and import documentation as needed

## License

This project is licensed under the MIT License
