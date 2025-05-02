#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Final Setup ===${NC}"

# Add version control support
echo -e "${GREEN}Setting up Git repository...${NC}"
cat > ./.gitignore << 'EOL'
HELP.md
target/
!.mvn/wrapper/maven-wrapper.jar
!**/src/main/**/target/
!**/src/test/**/target/

### STS ###
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans
.sts4-cache

### IntelliJ IDEA ###
.idea
*.iws
*.iml
*.ipr

### NetBeans ###
/nbproject/private/
/nbbuild/
/dist/
/nbdist/
/.nb-gradle/
build/
!**/src/main/**/build/
!**/src/test/**/build/

### VS Code ###
.vscode/

### H2 Database ###
*.db
*.mv.db
*.trace.db

### Vaadin ###
node_modules/
frontend/generated/
EOL

# Add README.md
echo -e "${GREEN}Creating README.md...${NC}"
cat > ./README.md << 'EOL'
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
EOL

# Create a backup/restore utility
echo -e "${GREEN}Creating backup utility...${NC}"
cat > ./backup-docs.sh << 'EOL'
#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DOCS_HOME="$HOME/.docs/documentation"
BACKUP_DIR="$DOCS_HOME/backups"
DATE_FORMAT=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/documentation_backup_$DATE_FORMAT.zip"

# Function to display help
show_help() {
    echo "Documentation App Backup/Restore Utility"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -b, --backup   Create a backup (default action)"
    echo "  -r, --restore  Restore from a backup"
    echo "  -l, --list     List available backups"
    echo "  -p, --path     Specify a custom backup path"
    echo ""
    echo "Examples:"
    echo "  $0                     # Create a backup with default settings"
    echo "  $0 -r                  # Restore (will prompt for backup file)"
    echo "  $0 -r -p /path/to/file # Restore from specific backup file"
    echo "  $0 -l                  # List available backups"
}

# Function to create a backup
create_backup() {
    echo -e "${BLUE}=== Creating Documentation Backup ===${NC}"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Check if the database exists
    if [ ! -f "$DOCS_HOME/db.mv.db" ]; then
        echo -e "${RED}No database found at $DOCS_HOME/db.mv.db${NC}"
        echo -e "${YELLOW}Have you run the application at least once?${NC}"
        exit 1
    fi
    
    # Stop any running instances of the application
    echo -e "${YELLOW}Ensuring no application instances are running...${NC}"
    if command -v docker &> /dev/null; then
        docker ps | grep documentation-app > /dev/null && docker stop documentation-app
    fi
    
    # Create backup
    echo -e "${GREEN}Creating backup to $BACKUP_FILE...${NC}"
    zip -j "$BACKUP_FILE" "$DOCS_HOME"/db*
    
    echo -e "${GREEN}Backup completed successfully!${NC}"
    echo -e "${BLUE}Backup saved to:${NC} $BACKUP_FILE"
}

# Function to restore from a backup
restore_backup() {
    echo -e "${BLUE}=== Restoring Documentation from Backup ===${NC}"
    
    # If no path is specified, list backups and prompt for selection
    if [ -z "$CUSTOM_PATH" ]; then
        if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
            echo -e "${RED}No backups found in $BACKUP_DIR${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}Available backups:${NC}"
        local i=1
        local backups=()
        
        while IFS= read -r file; do
            echo "  $i. $(basename "$file")"
            backups+=("$file")
            ((i++))
        done < <(find "$BACKUP_DIR" -name "*.zip" | sort -r)
        
        echo ""
        read -p "Enter backup number to restore: " selection
        
        if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#backups[@]}" ]; then
            echo -e "${RED}Invalid selection${NC}"
            exit 1
        fi
        
        BACKUP_FILE="${backups[$((selection-1))]}"
    else
        BACKUP_FILE="$CUSTOM_PATH"
        
        if [ ! -f "$BACKUP_FILE" ]; then
            echo -e "${RED}Backup file not found: $BACKUP_FILE${NC}"
            exit 1
        fi
    fi
    
    # Stop any running instances of the application
    echo -e "${YELLOW}Ensuring no application instances are running...${NC}"
    if command -v docker &> /dev/null; then
        docker ps | grep documentation-app > /dev/null && docker stop documentation-app
    fi
    
    # Backup current database before restoring
    if [ -f "$DOCS_HOME/db.mv.db" ]; then
        echo -e "${YELLOW}Creating backup of current database before restoring...${NC}"
        TEMP_BACKUP="$BACKUP_DIR/pre_restore_backup_$DATE_FORMAT.zip"
        zip -j "$TEMP_BACKUP" "$DOCS_HOME"/db*
        echo -e "${GREEN}Current database backed up to $TEMP_BACKUP${NC}"
    fi
    
    # Remove current database files
    echo -e "${YELLOW}Removing current database files...${NC}"
    rm -f "$DOCS_HOME"/db*
    
    # Extract backup
    echo -e "${GREEN}Restoring from $BACKUP_FILE...${NC}"
    unzip -o "$BACKUP_FILE" -d "$DOCS_HOME"
    
    echo -e "${GREEN}Restore completed successfully!${NC}"
}

# Function to list available backups
list_backups() {
    echo -e "${BLUE}=== Available Documentation Backups ===${NC}"
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        echo -e "${YELLOW}No backups found in $BACKUP_DIR${NC}"
        return
    fi
    
    echo -e "${GREEN}Backup directory:${NC} $BACKUP_DIR"
    echo ""
    
    echo -e "${GREEN}Available backups:${NC}"
    find "$BACKUP_DIR" -name "*.zip" -type f | sort -r | while read -r backup; do
        size=$(du -h "$backup" | cut -f1)
        date=$(date -r "$backup" "+%Y-%m-%d %H:%M:%S")
        echo "  $(basename "$backup") (${size}, created: ${date})"
    done
}

# Parse command line arguments
ACTION="backup"
CUSTOM_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--backup)
            ACTION="backup"
            shift
            ;;
        -r|--restore)
            ACTION="restore"
            shift
            ;;
        -l|--list)
            ACTION="list"
            shift
            ;;
        -p|--path)
            if [[ -n "$2" && "$2" != -* ]]; then
                CUSTOM_PATH="$2"
                shift 2
            else
                echo -e "${RED}Error: Argument for $1 is missing${NC}" >&2
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            show_help
            exit 1
            ;;
    esac
done

# Execute the specified action
case $ACTION in
    backup)
        create_backup
        ;;
    restore)
        restore_backup
        ;;
    list)
        list_backups
        ;;
esac
EOL

# Make the backup script executable
chmod +x ./backup-docs.sh

# Create a custom application.yml for Docker environment
echo -e "${GREEN}Creating Docker configuration...${NC}"
mkdir -p ./src/main/resources/config
cat > ./src/main/resources/config/application-docker.yml << 'EOL'
spring:
  application:
    name: Documentation App
    
  datasource:
    url: jdbc:h2:file:/root/.docs/documentation/db;DB_CLOSE_ON_EXIT=FALSE
    username: admin
    password: password
    driver-class-name: org.h2.Driver
    
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect
    hibernate:
      ddl-auto: update
    show-sql: false
    
  h2:
    console:
      enabled: true
      path: /h2-console
      settings:
        web-allow-others: true

server:
  port: 8080
  compression:
    enabled: true
    mime-types: application/json,application/xml,text/html,text/xml,text/plain,application/javascript,text/css

logging:
  level:
    io.joshuasalcedo: INFO
    org.springframework.web: INFO
    org.hibernate: ERROR

vaadin:
  whitelisted-packages: io.joshuasalcedo.documentation
  pnpm:
    enable: true
EOL

# Update pom.xml to include markdown processor
echo -e "${GREEN}Updating pom.xml for Markdown support...${NC}"
cat > ./pom.xml.temp << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-parent</artifactId>
		<version>3.4.5</version>
		<relativePath/> <!-- lookup parent from repository -->
	</parent>
	<groupId>io.joshuasalcedo</groupId>
	<artifactId>documentation</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<name>documentation</name>
	<description>documentation app</description>
	<properties>
		<java.version>21</java.version>
		<vaadin.version>24.4.1</vaadin.version>
	</properties>
	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-jpa</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
		<dependency>
			<groupId>com.vaadin</groupId>
			<artifactId>vaadin-spring-boot-starter</artifactId>
		</dependency>

		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-devtools</artifactId>
			<scope>runtime</scope>
			<optional>true</optional>
		</dependency>
		<dependency>
			<groupId>com.h2database</groupId>
			<artifactId>h2</artifactId>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
		</dependency>
		
		<!-- Markdown processor -->
		<dependency>
			<groupId>com.vladsch.flexmark</groupId>
			<artifactId>flexmark-all</artifactId>
			<version>0.64.0</version>
		</dependency>
	</dependencies>
	<dependencyManagement>
		<dependencies>
			<dependency>
				<groupId>com.vaadin</groupId>
				<artifactId>vaadin-bom</artifactId>
				<version>${vaadin.version}</version>
				<type>pom</type>
				<scope>import</scope>
			</dependency>
		</dependencies>
	</dependencyManagement>

	<build>
		<plugins>
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
			</plugin>
		</plugins>
	</build>

	<profiles>
		<profile>
			<id>production</id>
			<build>
				<plugins>
					<plugin>
						<groupId>com.vaadin</groupId>
						<artifactId>vaadin-maven-plugin</artifactId>
						<version>${vaadin.version}</version>
						<executions>
							<execution>
								<id>frontend</id>
								<phase>compile</phase>
								<goals>
									<goal>prepare-frontend</goal>
									<goal>build-frontend</goal>
								</goals>
							</execution>
						</executions>
					</plugin>
				</plugins>
			</build>
		</profile>
	</profiles>
</project>
EOL

# Replace the original pom.xml with the updated one
mv ./pom.xml.temp ./pom.xml

# Create markdown renderer helper class
echo -e "${GREEN}Creating markdown renderer...${NC}"
mkdir -p ./src/main/java/io/joshuasalcedo/documentation/util
cat > ./src/main/java/io/joshuasalcedo/documentation/util/MarkdownRenderer.java << 'EOL'
package io.joshuasalcedo.documentation.util;

import com.vladsch.flexmark.html.HtmlRenderer;
import com.vladsch.flexmark.parser.Parser;
import com.vladsch.flexmark.util.ast.Node;
import com.vladsch.flexmark.util.data.MutableDataSet;
import org.springframework.stereotype.Component;

@Component
public class MarkdownRenderer {

    private final Parser parser;
    private final HtmlRenderer renderer;

    public MarkdownRenderer() {
        MutableDataSet options = new MutableDataSet();
        options.set(Parser.EXTENSIONS, Parser.EXTENSIONS);
        
        parser = Parser.builder(options).build();
        renderer = HtmlRenderer.builder(options).build();
    }

    /**
     * Renders markdown content to HTML
     * @param markdown The markdown content to render
     * @return The rendered HTML
     */
    public String renderMarkdown(String markdown) {
        if (markdown == null || markdown.isEmpty()) {
            return "";
        }
        
        Node document = parser.parse(markdown);
        return renderer.render(document);
    }
}
EOL

# Update DocumentationEntryView to use markdown renderer
echo -e "${GREEN}Updating DocumentationEntryView to use markdown rendering...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/documentation/DocumentationEntryView.java << 'EOL'
package io.joshuasalcedo.documentation.views.documentation;

import com.vaadin.flow.component.UI;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.html.Div;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.H3;
import com.vaadin.flow.component.html.Paragraph;
import com.vaadin.flow.component.icon.Icon;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.router.BeforeEvent;
import com.vaadin.flow.router.HasUrlParameter;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.util.MarkdownRenderer;
import io.joshuasalcedo.documentation.views.MainLayout;
import java.time.format.DateTimeFormatter;
import java.util.Optional;

@PageTitle("Documentation Entry")
@Route(value = "documentation/entry", layout = MainLayout.class)
public class DocumentationEntryView extends VerticalLayout implements HasUrlParameter<Long> {

    private final DocumentationService documentationService;
    private final MarkdownRenderer markdownRenderer;
    
    private H2 title = new H2();
    private Paragraph metadata = new Paragraph();
    private Div contentContainer = new Div();

    public DocumentationEntryView(DocumentationService documentationService, MarkdownRenderer markdownRenderer) {
        this.documentationService = documentationService;
        this.markdownRenderer = markdownRenderer;
        
        setSpacing(true);
        setPadding(true);
        
        Button backButton = new Button("Back to List", new Icon(VaadinIcon.ARROW_LEFT));
        backButton.addClickListener(e -> UI.getCurrent().navigate(DocumentationListView.class));
        
        add(backButton, title, metadata, contentContainer);
    }

    @Override
    public void setParameter(BeforeEvent event, Long parameter) {
        Optional<DocumentationEntry> entryOpt = documentationService.findById(parameter);
        
        if (entryOpt.isPresent()) {
            DocumentationEntry entry = entryOpt.get();
            title.setText(entry.getTitle());
            
            String metadataText = "Section: " + entry.getSection() + " | " +
                    "Created: " + entry.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) + " | " +
                    "Updated: " + entry.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            metadata.setText(metadataText);
            
            Div contentDiv = new Div();
            String renderedContent = markdownRenderer.renderMarkdown(entry.getContent());
            contentDiv.getElement().setProperty("innerHTML", renderedContent);
            
            contentContainer.removeAll();
            contentContainer.add(contentDiv);
            
            HorizontalLayout actionButtons = new HorizontalLayout();
            Button editButton = new Button("Edit", new Icon(VaadinIcon.EDIT));
            editButton.addClickListener(e -> UI.getCurrent().navigate(DocumentationEntryEditView.class, parameter));
            actionButtons.add(editButton);
            
            add(actionButtons);
        } else {
            title.setText("Entry not found");
            add(new Paragraph("The requested documentation entry could not be found."));
        }
    }
}
EOL

# Create CSS styles for the application
echo -e "${GREEN}Creating custom CSS styles...${NC}"
mkdir -p ./frontend/themes/documentation/styles
cat > ./frontend/themes/documentation/styles/styles.css << 'EOL'
@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap');

html {
    --lumo-font-family: 'Roboto', Helvetica, Arial, sans-serif;
    --lumo-border-radius: 6px;
    --lumo-primary-color: hsl(214, 90%, 52%);
    --lumo-primary-color-50pct: hsla(214, 90%, 52%, 0.5);
    --lumo-primary-color-10pct: hsla(214, 90%, 52%, 0.1);
    --lumo-shade: hsl(214, 35%, 15%);
    --lumo-shade-90pct: hsla(214, 35%, 15%, 0.9);
    --lumo-shade-80pct: hsla(214, 35%, 15%, 0.8);
    --lumo-shade-70pct: hsla(214, 35%, 15%, 0.7);
    --lumo-shade-60pct: hsla(214, 35%, 15%, 0.6);
    --lumo-shade-50pct: hsla(214, 35%, 15%, 0.5);
    --lumo-shade-40pct: hsla(214, 35%, 15%, 0.4);
    --lumo-shade-30pct: hsla(214, 35%, 15%, 0.3);
    --lumo-shade-20pct: hsla(214, 35%, 15%, 0.2);
    --lumo-shade-10pct: hsla(214, 35%, 15%, 0.1);
    --lumo-shade-5pct: hsla(214, 35%, 15%, 0.05);
}

/* Sidebar styling */
.menu-header {
    font-weight: bold;
    color: var(--lumo-primary-color);
    font-size: 0.9em;
    padding-left: 0.5em;
    margin-top: 1em;
    text-transform: uppercase;
}

/* Content styling */
.documentation-form {
    display: flex;
    flex-direction: column;
    gap: 1em;
}

.toolbar {
    margin-bottom: 1em;
}

.content {
    display: flex;
}

.editing .content {
    display: flex;
    gap: 2em;
}

/* Grid styling */
.documentation-grid .content-column {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 300px;
}

/* Documentation view styling */
.content-container {
    border: 1px solid var(--lumo-contrast-10pct);
    border-radius: var(--lumo-border-radius);
    padding: 1em;
    background-color: var(--lumo-base-color);
}

/* Markdown content styling */
.markdown-content h1 {
    margin-top: 0.5em;
    color: var(--lumo-primary-color);
}

.markdown-content h2 {
    color: var(--lumo-primary-color-50pct);
}

.markdown-content pre {
    background-color: var(--lumo-contrast-5pct);
    padding: 1em;
    border-radius: var(--lumo-border-radius);
    overflow-x: auto;
}

.markdown-content code {
    background-color: var(--lumo-contrast-5pct);
    padding: 0.2em 0.4em;
    border-radius: 3px;
    font-family: monospace;
}

.markdown-content blockquote {
    border-left: 4px solid var(--lumo-primary-color-10pct);
    margin-left: 0;
    padding-left: 1em;
    color: var(--lumo-secondary-text-color);
}

.markdown-content img {
    max-width: 100%;
    height: auto;
}

.markdown-content table {
    border-collapse: collapse;
    width: 100%;
    margin: 1em 0;
}

.markdown-content th, .markdown-content td {
    border: 1px solid var(--lumo-contrast-10pct);
    padding: 0.5em;
}

.markdown-content th {
    background-color: var(--lumo-contrast-5pct);
}
EOL

# Create theme configuration
echo -e "${GREEN}Creating theme configuration...${NC}"
cat > ./frontend/themes/documentation/theme.json << 'EOL'
{
  "lumoImports": [
    "typography",
    "color",
    "spacing",
    "badge",
    "utility"
  ]
}
EOL

# Create application.js for custom JavaScript
echo -e "${GREEN}Creating custom JavaScript...${NC}"
mkdir -p ./frontend/js
cat > ./frontend/js/app.js << 'EOL'
// Custom JavaScript for the documentation app

// Function to add syntax highlighting to code blocks
function applySyntaxHighlighting() {
    // This is a placeholder for adding code syntax highlighting
    // You could integrate a library like Prism.js or highlight.js here
    console.log("Syntax highlighting applied");
}

// Function to add responsive behavior to the navigation drawer
function setupResponsiveNavigation() {
    const mql = window.matchMedia('(max-width: 800px)');
    
    function handleScreenSizeChange(e) {
        if (e.matches) {
            // Mobile view - close drawer
            const drawer = document.querySelector('vaadin-app-layout');
            if (drawer) {
                drawer.drawerOpened = false;
            }
        }
    }
    
    mql.addEventListener('change', handleScreenSizeChange);
    handleScreenSizeChange(mql);
}

// Initialize when the document is fully loaded
window.addEventListener('DOMContentLoaded', (event) => {
    applySyntaxHighlighting();
    setupResponsiveNavigation();
});
EOL

# Create a health check endpoint
echo -e "${GREEN}Creating health check endpoint...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/controller/HealthController.java << 'EOL'
package io.joshuasalcedo.documentation.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
public class HealthController {

    @GetMapping
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", System.currentTimeMillis());
        response.put("service", "Documentation App");
        
        return ResponseEntity.ok(response);
    }
}
EOL

# Create docker-compose for production
echo -e "${GREEN}Creating docker-compose for production...${NC}"
cat > ./docker-compose.prod.yml << 'EOL'
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: documentation-app:latest
    container_name: documentation-app
    ports:
      - "80:8080"
    volumes:
      - ${HOME}/.docs/documentation:/root/.docs/documentation
    restart: always
    environment:
      - SPRING_PROFILES_ACTIVE=docker,prod
      - JAVA_OPTS=-Xmx512m -Xms256m
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
EOL

# Create production deployment script
echo -e "${GREEN}Creating production deployment script...${NC}"
cat > ./deploy-production.sh << 'EOL'
#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Production Deployment ===${NC}"

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: Docker and Docker Compose are required for production deployment${NC}"
    exit 1
fi

# Build the application with production profile
echo -e "${GREEN}Building the application with production profile...${NC}"
./mvnw clean package -Pproduction -DskipTests

# Build and start Docker containers
echo -e "${GREEN}Building and starting Docker containers...${NC}"
docker-compose -f docker-compose.prod.yml up --build -d

echo -e "\n${GREEN}Deployment completed successfully!${NC}"
echo -e "${BLUE}The application is now running at: http://localhost${NC}"
echo -e "${YELLOW}Data is stored in: $HOME/.docs/documentation${NC}"
EOL

chmod +x ./deploy-production.sh

# Create a systemd service file template
echo -e "${GREEN}Creating systemd service file template...${NC}"
mkdir -p ./deployment
cat > ./deployment/documentation-app.service << 'EOL'
[Unit]
Description=Documentation App Service
After=network.target

[Service]
User=APP_USER
WorkingDirectory=APP_DIR
ExecStart=/usr/bin/java -jar APP_DIR/target/documentation-0.0.1-SNAPSHOT.jar
SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL

# Create an installation script for systemd service
echo -e "${GREEN}Creating systemd service installation script...${NC}"
cat > ./install-as-service.sh << 'EOL'
#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Service Installer ===${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root or with sudo${NC}"
  exit 1
fi

# Get the current directory and user
APP_DIR=$(pwd)
CURRENT_USER=$(logname || echo $SUDO_USER)

if [ -z "$CURRENT_USER" ]; then
    echo -e "${YELLOW}Could not determine current user, using current directory owner${NC}"
    CURRENT_USER=$(stat -c '%U' .)
fi

echo -e "${GREEN}Installing Documentation App as a systemd service${NC}"
echo -e "${YELLOW}App directory: $APP_DIR${NC}"
echo -e "${YELLOW}User: $CURRENT_USER${NC}"

# Build the application
echo -e "${GREEN}Building the application...${NC}"
sudo -u $CURRENT_USER ./mvnw clean package -DskipTests

# Create the service file
echo -e "${GREEN}Creating systemd service file...${NC}"
SERVICE_FILE="./deployment/documentation-app.service"
DEST_FILE="/etc/systemd/system/documentation-app.service"

# Replace placeholders
sed "s|APP_DIR|$APP_DIR|g; s|APP_USER|$CURRENT_USER|g" $SERVICE_FILE > /tmp/documentation-app.service
mv /tmp/documentation-app.service $DEST_FILE

# Reload systemd
echo -e "${GREEN}Reloading systemd...${NC}"
systemctl daemon-reload

# Enable and start the service
echo -e "${GREEN}Enabling and starting the service...${NC}"
systemctl enable documentation-app.service
systemctl start documentation-app.service

echo -e "\n${GREEN}Installation completed successfully!${NC}"
echo -e "${BLUE}The application is now running as a system service${NC}"
echo -e "${YELLOW}To check status: sudo systemctl status documentation-app${NC}"
echo -e "${YELLOW}To stop: sudo systemctl stop documentation-app${NC}"
echo -e "${YELLOW}To start: sudo systemctl start documentation-app${NC}"
echo -e "${YELLOW}Logs can be viewed with: sudo journalctl -u documentation-app${NC}"
EOL

chmod +x ./install-as-service.sh

# Create a Nginx configuration for reverse proxy
echo -e "${GREEN}Creating Nginx configuration for reverse proxy...${NC}"
mkdir -p ./deployment/nginx
cat > ./deployment/nginx/documentation-app.conf << 'EOL'
server {
    listen 80;
    server_name documentation.example.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Increase max body size for file uploads
    client_max_body_size 20M;
    
    # Add security headers
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-XSS-Protection "1; mode=block";
}
EOL

# Create a script to install Nginx configuration
echo -e "${GREEN}Creating Nginx installation script...${NC}"
cat > ./setup-nginx.sh << 'EOL'
#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Nginx Setup ===${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root or with sudo${NC}"
  exit 1
fi

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo -e "${YELLOW}Nginx is not installed. Installing...${NC}"
    apt-get update
    apt-get install -y nginx
fi

# Get domain name
read -p "Enter your domain name (e.g., documentation.example.com): " DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then
    echo -e "${YELLOW}No domain provided. Using documentation.example.com as default${NC}"
    DOMAIN_NAME="documentation.example.com"
fi

# Update Nginx config
echo -e "${GREEN}Creating Nginx configuration...${NC}"
NGINX_CONF_SRC="./deployment/nginx/documentation-app.conf"
NGINX_CONF_DEST="/etc/nginx/sites-available/documentation-app"

# Replace domain name
sed "s/documentation.example.com/$DOMAIN_NAME/g" $NGINX_CONF_SRC > $NGINX_CONF_DEST

# Enable the site
echo -e "${GREEN}Enabling the site...${NC}"
ln -sf $NGINX_CONF_DEST /etc/nginx/sites-enabled/

# Test configuration
echo -e "${GREEN}Testing Nginx configuration...${NC}"
nginx -t

if [ $? -ne 0 ]; then
    echo -e "${RED}Nginx configuration test failed. Please check the error message above.${NC}"
    exit 1
fi

# Restart Nginx
echo -e "${GREEN}Restarting Nginx...${NC}"
systemctl restart nginx

echo -e "\n${GREEN}Nginx setup completed successfully!${NC}"
echo -e "${BLUE}Your Documentation App should now be accessible at: http://$DOMAIN_NAME${NC}"
echo -e "${YELLOW}Don't forget to set up DNS records to point $DOMAIN_NAME to your server's IP address.${NC}"
EOL

chmod +x ./setup-nginx.sh

# Generate JWT token creation utility for API authentication
echo -e "${GREEN}Creating JWT token utilities...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/util/JwtTokenGenerator.java << 'EOL'
package io.joshuasalcedo.documentation.util;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Date;
import java.util.UUID;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import org.springframework.stereotype.Component;

/**
 * Simple JWT token generator for API authentication
 * Note: This is a simplified implementation for demonstration purposes
 */
@Component
public class JwtTokenGenerator {

    private static final String SECRET_KEY = System.getenv("JWT_SECRET") != null ? 
            System.getenv("JWT_SECRET") : "defaultSecretKeyForDocumentationAppShouldBeChanged";
    private static final long EXPIRATION_TIME = 86400000; // 24 hours in milliseconds
    
    /**
     * Generates a JWT token
     * @param username User identifier
     * @return Generated JWT token
     */
    public String generateToken(String username) {
        try {
            // Create JWT header
            String header = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
            String encodedHeader = base64UrlEncode(header);
            
            // Create JWT payload
            long now = System.currentTimeMillis();
            String payload = String.format(
                    "{\"sub\":\"%s\",\"iat\":%d,\"exp\":%d,\"jti\":\"%s\"}",
                    username, 
                    now / 1000, 
                    (now + EXPIRATION_TIME) / 1000, 
                    UUID.randomUUID().toString()
            );
            String encodedPayload = base64UrlEncode(payload);
            
            // Create signature
            String signature = hmacSha256(encodedHeader + "." + encodedPayload, SECRET_KEY);
            
            // Combine to form JWT
            return encodedHeader + "." + encodedPayload + "." + signature;
            
        } catch (Exception e) {
            throw new RuntimeException("Error generating JWT token", e);
        }
    }
    
    private String base64UrlEncode(String str) {
        return Base64.getUrlEncoder().withoutPadding()
                .encodeToString(str.getBytes(StandardCharsets.UTF_8));
    }
    
    private String hmacSha256(String data, String secret) 
            throws NoSuchAlgorithmException, InvalidKeyException {
        
        SecretKeySpec secretKey = new SecretKeySpec(
                secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(secretKey);
        byte[] hmacData = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        return Base64.getUrlEncoder().withoutPadding().encodeToString(hmacData);
    }
}
EOL

# Create a utility to generate API tokens for the CLI
echo -e "${GREEN}Creating API token generator script...${NC}"
cat > ./generate-api-token.sh << 'EOL'
#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App API Token Generator ===${NC}"

# Check if OpenSSL is available
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}Error: OpenSSL is required to generate tokens${NC}"
    exit 1
fi

# Default secret key
SECRET_KEY="${JWT_SECRET:-defaultSecretKeyForDocumentationAppShouldBeChanged}"

# Get username
read -p "Enter username for the token: " USERNAME
if [ -z "$USERNAME" ]; then
    echo -e "${YELLOW}No username provided. Using 'api-user' as default${NC}"
    USERNAME="api-user"
fi

# Generate a simple JWT token
# Note: This is a simplified implementation for demonstration purposes only
HEADER='{"alg":"HS256","typ":"JWT"}'
HEADER_BASE64=$(echo -n "$HEADER" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Current time and expiration (24 hours)
CURRENT_TIME=$(date +%s)
EXPIRATION_TIME=$((CURRENT_TIME + 86400))
PAYLOAD="{\"sub\":\"$USERNAME\",\"iat\":$CURRENT_TIME,\"exp\":$EXPIRATION_TIME}"
PAYLOAD_BASE64=$(echo -n "$PAYLOAD" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Create signature
SIGNATURE_INPUT="$HEADER_BASE64.$PAYLOAD_BASE64"
SIGNATURE=$(echo -n "$SIGNATURE_INPUT" | openssl dgst -sha256 -hmac "$SECRET_KEY" -binary | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Combine to form JWT
TOKEN="$HEADER_BASE64.$PAYLOAD_BASE64.$SIGNATURE"

echo -e "\n${GREEN}API Token generated successfully!${NC}"
echo -e "${YELLOW}Token expires in 24 hours${NC}"
echo -e "${BLUE}Token:${NC} $TOKEN"
echo -e "\n${GREEN}Example API usage:${NC}"
echo "curl -H \"Authorization: Bearer $TOKEN\" http://localhost:8080/api/documentation"

# Save token to file
echo -n "$TOKEN" > api-token.txt
echo -e "\n${GREEN}Token also saved to api-token.txt${NC}"
EOL

chmod +x ./generate-api-token.sh

# Create final script to complete setup
echo -e "${GREEN}Creating final setup script...${NC}"
cat > ./finalize-setup.sh << 'EOL'
#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Setup Finalization ===${NC}"

# Make all scripts executable
chmod +x *.sh
chmod +x deployment/*.sh 2>/dev/null

# Create required directories
mkdir -p "$HOME/.docs/documentation"

# Build the application
echo -e "${GREEN}Building the application...${NC}"
./mvnw clean package -DskipTests

echo -e "\n${GREEN}Setup completed!${NC}"
echo -e "${BLUE}Your Documentation App is ready to use.${NC}"
echo -e "${YELLOW}To run the application:${NC}"
echo -e "  Local mode: ./run-docs-app.sh"
echo -e "  Docker mode: docker-compose up -d"
echo -e "  Production mode: ./deploy-production.sh"
echo -e "\n${YELLOW}Additional utilities:${NC}"
echo -e "  Backup/restore: ./backup-docs.sh"
echo -e "  Install as service: sudo ./install-as-service.sh"
echo -e "  Configure Nginx: sudo ./setup-nginx.sh"
echo -e "  Generate API token: ./generate-api-token.sh"
EOL

chmod +x ./finalize-setup.sh

echo -e "\n${GREEN}All scripts completed successfully!${NC}"
echo -e "${YELLOW}Run ./finalize-setup.sh to complete the setup process${NC}"
