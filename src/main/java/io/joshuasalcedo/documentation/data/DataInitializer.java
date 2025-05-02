package io.joshuasalcedo.documentation.data;

import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.data.repository.DocumentationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataInitializer {

    @Bean
    public CommandLineRunner loadData(DocumentationRepository documentationRepository) {
        return args -> {
            if (documentationRepository.count() == 0) {
                // Create welcome entry
                DocumentationEntry welcome = new DocumentationEntry();
                welcome.setTitle("Welcome to Documentation App");
                welcome.setSection("Getting Started");
                welcome.setContent("# Welcome to Documentation App\n\n" +
                        "This is your wiki-style documentation system. " +
                        "Use this application to create, manage, and browse your documentation.\n\n" +
                        "## Features\n\n" +
                        "- Create documentation entries\n" +
                        "- Organize entries by sections\n" +
                        "- Full markdown support\n" +
                        "- Search functionality\n\n" +
                        "## Getting Started\n\n" +
                        "1. Click on 'Documentation' in the sidebar\n" +
                        "2. Create new documentation entries\n" +
                        "3. Organize them in sections\n");
                documentationRepository.save(welcome);
                
                // Create usage guide
                DocumentationEntry usage = new DocumentationEntry();
                usage.setTitle("How to Use the App");
                usage.setSection("Getting Started");
                usage.setContent("# Using the Documentation App\n\n" +
                        "This guide will help you understand how to use this documentation system effectively.\n\n" +
                        "## Creating Documentation\n\n" +
                        "To create a new documentation entry:\n\n" +
                        "1. Navigate to the Documentation page\n" +
                        "2. Click 'Add Entry'\n" +
                        "3. Fill in the title, select or create a section, and add content\n" +
                        "4. Click Save\n\n" +
                        "## Organizing Content\n\n" +
                        "Content is organized by sections. You can create as many sections as needed.\n\n" +
                        "## Formatting\n\n" +
                        "The content editor supports basic formatting:\n\n" +
                        "- **Bold text** with asterisks\n" +
                        "- *Italic text* with underscore\n" +
                        "- Code blocks with backticks\n");
                documentationRepository.save(usage);
                
                // API Documentation example
                DocumentationEntry api = new DocumentationEntry();
                api.setTitle("API Overview");
                api.setSection("API Documentation");
                api.setContent("# API Documentation\n\n" +
                        "This section contains information about our API endpoints.\n\n" +
                        "## Base URL\n\n" +
                        "All API calls should be made to: `https://api.example.com/v1`\n\n" +
                        "## Authentication\n\n" +
                        "API calls require an authentication token in the header:\n\n" +
                        "```\n" +
                        "Authorization: Bearer YOUR_API_TOKEN\n" +
                        "```\n\n" +
                        "## Endpoints\n\n" +
                        "- GET /users - List all users\n" +
                        "- POST /users - Create a new user\n" +
                        "- GET /users/{id} - Get a specific user\n");
                documentationRepository.save(api);
                
                // Technical Documentation example
                DocumentationEntry technical = new DocumentationEntry();
                technical.setTitle("System Architecture");
                technical.setSection("Technical Documentation");
                technical.setContent("# System Architecture\n\n" +
                        "This document provides an overview of our system architecture.\n\n" +
                        "## Components\n\n" +
                        "Our system consists of the following components:\n\n" +
                        "1. **Frontend** - Vaadin-based web interface\n" +
                        "2. **Backend** - Spring Boot application\n" +
                        "3. **Database** - H2 database for storage\n\n" +
                        "## Data Flow\n\n" +
                        "1. User interacts with the Vaadin UI\n" +
                        "2. Requests are processed by Spring controllers\n" +
                        "3. Data is fetched or stored in the H2 database\n" +
                        "4. Response is rendered back to the user\n\n" +
                        "## Deployment\n\n" +
                        "The system can be deployed as a standalone JAR or using Docker.");
                documentationRepository.save(technical);
            }
        };
    }
}
