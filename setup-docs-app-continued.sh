#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Setup Continued ===${NC}"

# Create documentation section view
echo -e "${GREEN}Creating documentation section view...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/documentation/DocumentationSectionView.java << 'EOL'
package io.joshuasalcedo.documentation.views.documentation;

import com.vaadin.flow.component.UI;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.grid.Grid;
import com.vaadin.flow.component.grid.GridVariant;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.icon.Icon;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.data.renderer.ComponentRenderer;
import com.vaadin.flow.router.BeforeEvent;
import com.vaadin.flow.router.HasUrlParameter;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.views.MainLayout;
import java.time.format.DateTimeFormatter;
import java.util.List;

@PageTitle("Section")
@Route(value = "documentation/section", layout = MainLayout.class)
public class DocumentationSectionView extends VerticalLayout implements HasUrlParameter<String> {

    private final DocumentationService documentationService;
    private final Grid<DocumentationEntry> grid = new Grid<>(DocumentationEntry.class);
    private String currentSection;

    public DocumentationSectionView(DocumentationService documentationService) {
        this.documentationService = documentationService;
        
        setSizeFull();
        setPadding(true);
        setSpacing(true);
        
        configureGrid();
    }

    private void configureGrid() {
        grid.addClassName("documentation-grid");
        grid.setSizeFull();
        grid.setColumns("title");
        grid.addColumn(entry -> entry.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")))
            .setHeader("Created")
            .setSortable(true);
        grid.addColumn(entry -> entry.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")))
            .setHeader("Updated")
            .setSortable(true);
        grid.addColumn(new ComponentRenderer<>(entry -> {
            Button viewButton = new Button("View");
            viewButton.addClickListener(e -> {
                UI.getCurrent().navigate(DocumentationEntryView.class, entry.getId());
            });
            return viewButton;
        })).setHeader("Actions").setFlexGrow(0);
        
        grid.getColumns().forEach(col -> col.setAutoWidth(true));
        grid.addThemeVariants(GridVariant.LUMO_ROW_STRIPES);
    }

    @Override
    public void setParameter(BeforeEvent event, String parameter) {
        // Convert URL parameter back to section name (e.g., "api-documentation" -> "API Documentation")
        currentSection = parameter.replace("-", " ");
        
        H2 sectionTitle = new H2("Section: " + currentSection);
        
        Button backButton = new Button("Back to All Documentation", new Icon(VaadinIcon.ARROW_LEFT));
        backButton.addClickListener(e -> UI.getCurrent().navigate(DocumentationListView.class));
        
        Button addEntryButton = new Button("Add Entry to Section", new Icon(VaadinIcon.PLUS));
        addEntryButton.addClickListener(e -> addEntryToSection());
        
        HorizontalLayout toolbar = new HorizontalLayout(backButton, addEntryButton);
        toolbar.setWidthFull();
        toolbar.setJustifyContentMode(JustifyContentMode.BETWEEN);
        
        removeAll();
        add(toolbar, sectionTitle, grid);
        
        updateList(currentSection);
    }

    private void updateList(String section) {
        List<DocumentationEntry> entries = documentationService.findBySection(section);
        grid.setItems(entries);
    }
    
    private void addEntryToSection() {
        // Create a new entry with pre-populated section
        DocumentationEntry newEntry = new DocumentationEntry();
        newEntry.setSection(currentSection);
        
        // Save it to get an ID
        DocumentationEntry savedEntry = documentationService.saveEntry(newEntry);
        
        // Navigate to edit view
        UI.getCurrent().navigate(DocumentationEntryEditView.class, savedEntry.getId());
    }
}
EOL

# Create data initializer for demo content
echo -e "${GREEN}Creating data initializer...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/data/DataInitializer.java << 'EOL'
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
EOL

# Update MainLayout to dynamically load sections
echo -e "${GREEN}Updating MainLayout for dynamic sections...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/MainLayout.java << 'EOL'
package io.joshuasalcedo.documentation.views;

import com.vaadin.flow.component.AttachEvent;
import com.vaadin.flow.component.Component;
import com.vaadin.flow.component.applayout.AppLayout;
import com.vaadin.flow.component.applayout.DrawerToggle;
import com.vaadin.flow.component.html.H1;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Header;
import com.vaadin.flow.component.icon.Icon;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.FlexComponent;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.Scroller;
import com.vaadin.flow.component.sidenav.SideNav;
import com.vaadin.flow.component.sidenav.SideNavItem;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.theme.lumo.LumoUtility;
import io.joshuasalcedo.documentation.data.repository.DocumentationRepository;
import io.joshuasalcedo.documentation.views.home.HomeView;
import io.joshuasalcedo.documentation.views.documentation.DocumentationListView;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * The main view is a top-level placeholder for other views.
 */
public class MainLayout extends AppLayout {

    private H2 viewTitle;
    private final DocumentationRepository documentationRepository;
    private SideNav nav;

    @Autowired
    public MainLayout(DocumentationRepository documentationRepository) {
        this.documentationRepository = documentationRepository;
        
        setPrimarySection(Section.DRAWER);
        addDrawerContent();
        addHeaderContent();
    }

    private void addHeaderContent() {
        DrawerToggle toggle = new DrawerToggle();
        toggle.getElement().setAttribute("aria-label", "Menu toggle");

        viewTitle = new H2();
        viewTitle.addClassNames(LumoUtility.FontSize.LARGE, LumoUtility.Margin.NONE);

        HorizontalLayout header = new HorizontalLayout(toggle, viewTitle);
        header.setDefaultVerticalComponentAlignment(FlexComponent.Alignment.CENTER);
        header.setWidthFull();
        header.addClassNames("py-0", "px-m");

        addToNavbar(true, header);
    }

    private void addDrawerContent() {
        H1 appName = new H1("Documentation App");
        appName.addClassNames(LumoUtility.FontSize.LARGE, LumoUtility.Margin.NONE);
        Header header = new Header(appName);

        nav = new SideNav();
        updateNavigation();
        
        Scroller scroller = new Scroller(nav);

        addToDrawer(header, scroller);
    }

    private void updateNavigation() {
        nav.removeAll();
        
        // Add main navigation items
        nav.addItem(new SideNavItem("Home", HomeView.class, new Icon(VaadinIcon.HOME)));
        nav.addItem(new SideNavItem("All Documentation", DocumentationListView.class, new Icon(VaadinIcon.LIST)));
        
        // Add section header
        SideNavItem sectionsHeader = new SideNavItem("Sections");
        sectionsHeader.addClassName("menu-header");
        nav.addItem(sectionsHeader);
        
        // Add dynamic sections
        documentationRepository
            .findAllSections()
            .forEach(section -> {
                String route = "documentation/section/" + section.toLowerCase().replace(" ", "-");
                SideNavItem sectionItem = new SideNavItem(section, route);
                sectionItem.setPrefixComponent(new Icon(VaadinIcon.BOOK));
                nav.addItem(sectionItem);
            });
    }

    @Override
    protected void onAttach(AttachEvent attachEvent) {
        super.onAttach(attachEvent);
        // Update navigation every time the layout is attached
        updateNavigation();
    }

    @Override
    protected void afterNavigation() {
        super.afterNavigation();
        viewTitle.setText(getCurrentPageTitle());
    }

    private String getCurrentPageTitle() {
        PageTitle title = getContent().getClass().getAnnotation(PageTitle.class);
        return title == null ? "" : title.value();
    }
}
EOL

# Update application.properties with more configuration
echo -e "${GREEN}Updating application properties...${NC}"
cat > ./src/main/resources/application.properties << EOL
# Application
spring.application.name=Documentation App
server.port=8080

# Vaadin Configuration
vaadin.whitelisted-packages=io.joshuasalcedo.documentation
vaadin.pnpm.enable=true

# H2 Database Configuration
spring.datasource.url=jdbc:h2:file:\${HOME}/.docs/documentation/db;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=admin
spring.datasource.password=password
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
spring.h2.console.settings.web-allow-others=false

# JPA/Hibernate
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=true

# Logging
logging.level.io.joshuasalcedo=INFO
logging.level.org.springframework.web=INFO
logging.level.org.hibernate=ERROR

# Server compression
server.compression.enabled=true
server.compression.mime-types=application/json,application/xml,text/html,text/xml,text/plain,application/javascript,text/css
EOL

# Create search view
echo -e "${GREEN}Creating search view...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/search/SearchView.java << 'EOL'
package io.joshuasalcedo.documentation.views.search;

import com.vaadin.flow.component.Key;
import com.vaadin.flow.component.UI;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.grid.Grid;
import com.vaadin.flow.component.grid.GridVariant;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.icon.Icon;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.component.textfield.TextField;
import com.vaadin.flow.data.renderer.ComponentRenderer;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import com.vaadin.flow.router.RouteParameters;
import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.views.MainLayout;
import io.joshuasalcedo.documentation.views.documentation.DocumentationEntryView;
import java.time.format.DateTimeFormatter;
import java.util.List;

@PageTitle("Search Documentation")
@Route(value = "search", layout = MainLayout.class)
public class SearchView extends VerticalLayout {

    private final DocumentationService documentationService;
    private final TextField searchField = new TextField();
    private final Grid<DocumentationEntry> grid = new Grid<>(DocumentationEntry.class);

    public SearchView(DocumentationService documentationService) {
        this.documentationService = documentationService;
        
        setSizeFull();
        setPadding(true);
        setSpacing(true);
        
        H2 header = new H2("Search Documentation");
        
        // Configure search field
        searchField.setPlaceholder("Enter search term...");
        searchField.setClearButtonVisible(true);
        searchField.setPrefixComponent(new Icon(VaadinIcon.SEARCH));
        searchField.setWidth("100%");
        
        Button searchButton = new Button("Search");
        searchButton.addClickListener(e -> search());
        searchButton.addClickShortcut(Key.ENTER);
        
        HorizontalLayout searchLayout = new HorizontalLayout(searchField, searchButton);
        searchLayout.setWidthFull();
        searchLayout.setFlexGrow(1, searchField);
        
        configureGrid();
        
        add(header, searchLayout, grid);
    }

    private void configureGrid() {
        grid.addClassName("search-results-grid");
        grid.setSizeFull();
        grid.setColumns("title", "section");
        grid.addColumn(entry -> entry.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")))
            .setHeader("Updated")
            .setSortable(true);
        grid.addColumn(new ComponentRenderer<>(entry -> {
            Button viewButton = new Button("View");
            viewButton.addClickListener(e -> {
                UI.getCurrent().navigate(DocumentationEntryView.class, entry.getId());
            });
            return viewButton;
        })).setHeader("Actions").setFlexGrow(0);
        
        grid.getColumns().forEach(col -> col.setAutoWidth(true));
        grid.addThemeVariants(GridVariant.LUMO_ROW_STRIPES);
    }

    private void search() {
        String searchTerm = searchField.getValue().trim();
        if (!searchTerm.isEmpty()) {
            List<DocumentationEntry> results = documentationService.searchByTitle(searchTerm);
            grid.setItems(results);
        }
    }
}
EOL

# Add search functionality to DocumentationService
echo -e "${GREEN}Adding search functionality to DocumentationService...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/service/DocumentationService.java << 'EOL'
package io.joshuasalcedo.documentation.service;

import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.data.repository.DocumentationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DocumentationService {
    private final DocumentationRepository documentationRepository;

    @Autowired
    public DocumentationService(DocumentationRepository documentationRepository) {
        this.documentationRepository = documentationRepository;
    }

    public List<DocumentationEntry> findAllEntries() {
        return documentationRepository.findAll();
    }

    public Optional<DocumentationEntry> findById(Long id) {
        return documentationRepository.findById(id);
    }

    public List<DocumentationEntry> findBySection(String section) {
        return documentationRepository.findBySection(section);
    }

    public List<DocumentationEntry> searchByTitle(String titlePart) {
        return documentationRepository.findByTitleContainingIgnoreCase(titlePart);
    }

    public List<String> getAllSections() {
        return documentationRepository.findAllSections();
    }

    public DocumentationEntry saveEntry(DocumentationEntry entry) {
        return documentationRepository.save(entry);
    }

    public void deleteEntry(Long id) {
        documentationRepository.deleteById(id);
    }
}
EOL

# Add search repository method
echo -e "${GREEN}Adding search functionality to DocumentationRepository...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/data/repository/DocumentationRepository.java << 'EOL'
package io.joshuasalcedo.documentation.data.repository;

import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DocumentationRepository extends JpaRepository<DocumentationEntry, Long> {
    
    List<DocumentationEntry> findBySection(String section);
    
    List<DocumentationEntry> findByTitleContainingIgnoreCase(String titlePart);
    
    @Query("SELECT DISTINCT d.section FROM DocumentationEntry d ORDER BY d.section")
    List<String> findAllSections();
    
    @Query("SELECT d FROM DocumentationEntry d WHERE " +
           "LOWER(d.title) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(d.content) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    List<DocumentationEntry> search(@Param("searchTerm") String searchTerm);
}
EOL

# Update the DocumentationService to include the content search
echo -e "${GREEN}Updating DocumentationService with content search...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/service/DocumentationService.java << 'EOL'
package io.joshuasalcedo.documentation.service;

import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.data.repository.DocumentationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DocumentationService {
    private final DocumentationRepository documentationRepository;

    @Autowired
    public DocumentationService(DocumentationRepository documentationRepository) {
        this.documentationRepository = documentationRepository;
    }

    public List<DocumentationEntry> findAllEntries() {
        return documentationRepository.findAll();
    }

    public Optional<DocumentationEntry> findById(Long id) {
        return documentationRepository.findById(id);
    }

    public List<DocumentationEntry> findBySection(String section) {
        return documentationRepository.findBySection(section);
    }

    public List<DocumentationEntry> searchByTitle(String titlePart) {
        return documentationRepository.findByTitleContainingIgnoreCase(titlePart);
    }
    
    public List<DocumentationEntry> search(String searchTerm) {
        return documentationRepository.search(searchTerm);
    }

    public List<String> getAllSections() {
        return documentationRepository.findAllSections();
    }

    public DocumentationEntry saveEntry(DocumentationEntry entry) {
        return documentationRepository.save(entry);
    }

    public void deleteEntry(Long id) {
        documentationRepository.deleteById(id);
    }
}
EOL

# Update the SearchView to use the enhanced search
echo -e "${GREEN}Updating SearchView to use enhanced search...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/search/SearchView.java << 'EOL'
package io.joshuasalcedo.documentation.views.search;

import com.vaadin.flow.component.Key;
import com.vaadin.flow.component.UI;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.grid.Grid;
import com.vaadin.flow.component.grid.GridVariant;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Span;
import com.vaadin.flow.component.icon.Icon;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.component.textfield.TextField;
import com.vaadin.flow.data.renderer.ComponentRenderer;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.views.MainLayout;
import io.joshuasalcedo.documentation.views.documentation.DocumentationEntryView;
import java.time.format.DateTimeFormatter;
import java.util.List;

@PageTitle("Search Documentation")
@Route(value = "search", layout = MainLayout.class)
public class SearchView extends VerticalLayout {

    private final DocumentationService documentationService;
    private final TextField searchField = new TextField();
    private final Grid<DocumentationEntry> grid = new Grid<>(DocumentationEntry.class);
    private final Span resultCount = new Span("0 results");

    public SearchView(DocumentationService documentationService) {
        this.documentationService = documentationService;
        
        setSizeFull();
        setPadding(true);
        setSpacing(true);
        
        H2 header = new H2("Search Documentation");
        
        // Configure search field
        searchField.setPlaceholder("Enter search term...");
        searchField.setClearButtonVisible(true);
        searchField.setPrefixComponent(new Icon(VaadinIcon.SEARCH));
        searchField.setWidth("100%");
        
        Button searchButton = new Button("Search");
        searchButton.addClickListener(e -> search());
        searchButton.addClickShortcut(Key.ENTER);
        
        HorizontalLayout searchLayout = new HorizontalLayout(searchField, searchButton);
        searchLayout.setWidthFull();
        searchLayout.setFlexGrow(1, searchField);
        
        configureGrid();
        
        add(header, searchLayout, resultCount, grid);
    }

    private void configureGrid() {
        grid.addClassName("search-results-grid");
        grid.setSizeFull();
        grid.setColumns("title", "section");
        grid.addColumn(entry -> entry.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")))
            .setHeader("Updated")
            .setSortable(true);
        grid.addColumn(new ComponentRenderer<>(entry -> {
            Button viewButton = new Button("View");
            viewButton.addClickListener(e -> {
                UI.getCurrent().navigate(DocumentationEntryView.class, entry.getId());
            });
            return viewButton;
        })).setHeader("Actions").setFlexGrow(0);
        
        grid.getColumns().forEach(col -> col.setAutoWidth(true));
        grid.addThemeVariants(GridVariant.LUMO_ROW_STRIPES);
    }

    private void search() {
        String searchTerm = searchField.getValue().trim();
        if (!searchTerm.isEmpty()) {
            List<DocumentationEntry> results = documentationService.search(searchTerm);
            grid.setItems(results);
            resultCount.setText(results.size() + " results found");
        }
    }
}
EOL

# Update MainLayout to include search icon in the header
echo -e "${GREEN}Adding search icon to MainLayout...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/MainLayout.java << 'EOL'
package io.joshuasalcedo.documentation.views;

import com.vaadin.flow.component.AttachEvent;
import com.vaadin.flow.component.Component;
import com.vaadin.flow.component.UI;
import com.vaadin.flow.component.applayout.AppLayout;
import com.vaadin.flow.component.applayout.DrawerToggle;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.button.ButtonVariant;
import com.vaadin.flow.component.html.H1;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Header;
import com.vaadin.flow.component.icon.Icon;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.FlexComponent;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.Scroller;
import com.vaadin.flow.component.sidenav.SideNav;
import com.vaadin.flow.component.sidenav.SideNavItem;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.theme.lumo.LumoUtility;
import io.joshuasalcedo.documentation.data.repository.DocumentationRepository
