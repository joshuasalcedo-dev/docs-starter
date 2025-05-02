#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Setup Script ===${NC}"
echo -e "${YELLOW}This script will set up a complete documentation system with Spring Boot and Vaadin${NC}"

# Create directories
DOCS_HOME="$HOME/.docs/documentation"
mkdir -p "$DOCS_HOME"
mkdir -p "./temp"

# Download starter from Spring Initializr
echo -e "\n${GREEN}Downloading Spring Boot starter...${NC}"
curl -s "https://start.spring.io/starter.zip?type=maven-project&language=java&platformVersion=3.4.5&packaging=jar&jvmVersion=21&groupId=io.joshuasalcedo&artifactId=documentation&name=documentation&description=documentation%20app&packageName=io.joshuasalcedo.documentation&dependencies=devtools,web,data-jpa,h2,vaadin" -o ./temp/documentation.zip

# Unzip the starter
echo -e "${GREEN}Extracting project...${NC}"
unzip -q ./temp/documentation.zip -d ./temp/
mv ./temp/documentation/* .
rm -rf ./temp

# Update application.properties
echo -e "${GREEN}Configuring application properties...${NC}"
cat > ./src/main/resources/application.properties << EOL
# Application
spring.application.name=Documentation App
server.port=8080

# Vaadin Configuration
vaadin.whitelisted-packages=io.joshuasalcedo.documentation

# H2 Database Configuration
spring.datasource.url=jdbc:h2:file:${HOME}/.docs/documentation/db;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=admin
spring.datasource.password=password
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console

# JPA/Hibernate
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false

# Logging
logging.level.io.joshuasalcedo=INFO
EOL

# Create directory structure for the application
echo -e "${GREEN}Creating project structure...${NC}"
mkdir -p ./src/main/java/io/joshuasalcedo/documentation/data/entity
mkdir -p ./src/main/java/io/joshuasalcedo/documentation/data/repository
mkdir -p ./src/main/java/io/joshuasalcedo/documentation/views
mkdir -p ./src/main/java/io/joshuasalcedo/documentation/views/main
mkdir -p ./src/main/java/io/joshuasalcedo/documentation/views/home
mkdir -p ./src/main/java/io/joshuasalcedo/documentation/views/documentation
mkdir -p ./src/main/java/io/joshuasalcedo/documentation/service

# Create entity classes
echo -e "${GREEN}Creating entity classes...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/data/entity/DocumentationEntry.java << 'EOL'
package io.joshuasalcedo.documentation.data.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
public class DocumentationEntry {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    
    @Column(name = "section")
    private String section;
    
    @Lob
    @Column(name = "content", columnDefinition = "CLOB")
    private String content;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSection() {
        return section;
    }

    public void setSection(String section) {
        this.section = section;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        DocumentationEntry that = (DocumentationEntry) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
EOL

# Create repository classes
echo -e "${GREEN}Creating repository interfaces...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/data/repository/DocumentationRepository.java << 'EOL'
package io.joshuasalcedo.documentation.data.repository;

import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DocumentationRepository extends JpaRepository<DocumentationEntry, Long> {
    List<DocumentationEntry> findBySection(String section);
    
    List<DocumentationEntry> findByTitleContainingIgnoreCase(String titlePart);
    
    @Query("SELECT DISTINCT d.section FROM DocumentationEntry d ORDER BY d.section")
    List<String> findAllSections();
}
EOL

# Create service classes
echo -e "${GREEN}Creating service classes...${NC}"
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

# Create main layout
echo -e "${GREEN}Creating main layout with app bar and navigation...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/MainLayout.java << 'EOL'
package io.joshuasalcedo.documentation.views;

import com.vaadin.flow.component.applayout.AppLayout;
import com.vaadin.flow.component.applayout.DrawerToggle;
import com.vaadin.flow.component.html.H1;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Header;
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

        addToNavbar(true, toggle, viewTitle);
    }

    private void addDrawerContent() {
        H1 appName = new H1("Documentation App");
        appName.addClassNames(LumoUtility.FontSize.LARGE, LumoUtility.Margin.NONE);
        Header header = new Header(appName);

        Scroller scroller = new Scroller(createNavigation());

        addToDrawer(header, scroller);
    }

    private SideNav createNavigation() {
        SideNav nav = new SideNav();
        
        nav.addItem(new SideNavItem("Home", HomeView.class));
        nav.addItem(new SideNavItem("Documentation", DocumentationListView.class));
        
        // Dynamic sections could be added here
        documentationRepository
            .findAllSections()
            .forEach(section -> {
                String route = "documentation/" + section.toLowerCase().replace(" ", "-");
                nav.addItem(new SideNavItem(section, route));
            });
        
        return nav;
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

# Create home view
echo -e "${GREEN}Creating home view...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/home/HomeView.java << 'EOL'
package io.joshuasalcedo.documentation.views.home;

import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Image;
import com.vaadin.flow.component.html.Paragraph;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import com.vaadin.flow.router.RouteAlias;
import com.vaadin.flow.theme.lumo.LumoUtility.Margin;
import io.joshuasalcedo.documentation.views.MainLayout;

@PageTitle("Home")
@Route(value = "home", layout = MainLayout.class)
@RouteAlias(value = "", layout = MainLayout.class)
public class HomeView extends VerticalLayout {

    public HomeView() {
        setSpacing(false);
        
        H2 header = new H2("Welcome to Documentation App");
        header.addClassNames(Margin.Top.XLARGE, Margin.Bottom.MEDIUM);
        add(header);
        
        Paragraph description = new Paragraph("This is a wiki-style documentation system. " +
                "Use the navigation menu to browse through documentation sections or create new entries.");
        add(description);

        Paragraph instructions = new Paragraph("Click on 'Documentation' in the sidebar to view and manage all documentation entries.");
        add(instructions);
        
        setSizeFull();
        setJustifyContentMode(JustifyContentMode.START);
        setDefaultHorizontalComponentAlignment(Alignment.CENTER);
    }
}
EOL

# Create documentation list view
echo -e "${GREEN}Creating documentation list view...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/documentation/DocumentationListView.java << 'EOL'
package io.joshuasalcedo.documentation.views.documentation;

import com.vaadin.flow.component.UI;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.button.ButtonVariant;
import com.vaadin.flow.component.grid.Grid;
import com.vaadin.flow.component.grid.GridVariant;
import com.vaadin.flow.component.html.Div;
import com.vaadin.flow.component.html.H3;
import com.vaadin.flow.component.icon.Icon;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.notification.Notification;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.component.textfield.TextField;
import com.vaadin.flow.data.renderer.ComponentRenderer;
import com.vaadin.flow.data.value.ValueChangeMode;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.views.MainLayout;
import java.time.format.DateTimeFormatter;
import java.util.List;

@PageTitle("Documentation")
@Route(value = "documentation", layout = MainLayout.class)
public class DocumentationListView extends VerticalLayout {

    private final DocumentationService documentationService;
    private final Grid<DocumentationEntry> grid = new Grid<>(DocumentationEntry.class);
    private final TextField filterText = new TextField();
    private final DocumentationEntryForm form;
    private List<DocumentationEntry> entries;

    public DocumentationListView(DocumentationService documentationService) {
        this.documentationService = documentationService;
        addClassName("documentation-list-view");
        setSizeFull();
        
        configureGrid();
        
        form = new DocumentationEntryForm(documentationService.getAllSections());
        form.setWidth("25em");
        form.addSaveListener(this::saveEntry);
        form.addDeleteListener(this::deleteEntry);
        form.addCloseListener(e -> closeEditor());
        
        Div content = new Div(grid, form);
        content.addClassName("content");
        content.setSizeFull();
        
        add(createToolbar(), content);
        updateList();
        closeEditor();
    }

    private void configureGrid() {
        grid.addClassName("documentation-grid");
        grid.setSizeFull();
        grid.setColumns("title", "section");
        grid.addColumn(entry -> entry.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")))
            .setHeader("Created")
            .setSortable(true);
        grid.addColumn(entry -> entry.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")))
            .setHeader("Updated")
            .setSortable(true);
        grid.addColumn(new ComponentRenderer<>(entry -> {
            Button viewButton = new Button("View");
            viewButton.addThemeVariants(ButtonVariant.LUMO_SMALL);
            viewButton.addClickListener(e -> {
                UI.getCurrent().navigate(DocumentationEntryView.class, entry.getId());
            });
            return viewButton;
        })).setHeader("Actions").setFlexGrow(0);
        
        grid.getColumns().forEach(col -> col.setAutoWidth(true));
        grid.addThemeVariants(GridVariant.LUMO_ROW_STRIPES);
        
        grid.asSingleSelect().addValueChangeListener(event -> {
            editEntry(event.getValue());
        });
    }

    private HorizontalLayout createToolbar() {
        filterText.setPlaceholder("Filter by title...");
        filterText.setClearButtonVisible(true);
        filterText.setValueChangeMode(ValueChangeMode.LAZY);
        filterText.addValueChangeListener(e -> updateList());

        Button addEntryButton = new Button("Add Entry");
        addEntryButton.addClickListener(click -> addEntry());

        HorizontalLayout toolbar = new HorizontalLayout(filterText, addEntryButton);
        toolbar.addClassName("toolbar");
        return toolbar;
    }

    private void addEntry() {
        grid.asSingleSelect().clear();
        editEntry(new DocumentationEntry());
    }

    private void editEntry(DocumentationEntry entry) {
        if (entry == null) {
            closeEditor();
        } else {
            form.setEntry(entry);
            form.setVisible(true);
            addClassName("editing");
        }
    }

    private void closeEditor() {
        form.setEntry(null);
        form.setVisible(false);
        removeClassName("editing");
    }

    private void saveEntry(DocumentationEntryForm.SaveEvent event) {
        documentationService.saveEntry(event.getEntry());
        updateList();
        closeEditor();
        Notification.show("Documentation entry saved.");
    }

    private void deleteEntry(DocumentationEntryForm.DeleteEvent event) {
        documentationService.deleteEntry(event.getEntry().getId());
        updateList();
        closeEditor();
        Notification.show("Documentation entry deleted.");
    }

    private void updateList() {
        String filterValue = filterText.getValue().trim();
        if (filterValue.isEmpty()) {
            entries = documentationService.findAllEntries();
        } else {
            entries = documentationService.searchByTitle(filterValue);
        }
        grid.setItems(entries);
    }
}
EOL

# Create documentation entry form
echo -e "${GREEN}Creating documentation entry form...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/documentation/DocumentationEntryForm.java << 'EOL'
package io.joshuasalcedo.documentation.views.documentation;

import com.vaadin.flow.component.Component;
import com.vaadin.flow.component.ComponentEvent;
import com.vaadin.flow.component.ComponentEventListener;
import com.vaadin.flow.component.Key;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.button.ButtonVariant;
import com.vaadin.flow.component.combobox.ComboBox;
import com.vaadin.flow.component.formlayout.FormLayout;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.textfield.TextArea;
import com.vaadin.flow.component.textfield.TextField;
import com.vaadin.flow.data.binder.BeanValidationBinder;
import com.vaadin.flow.data.binder.Binder;
import com.vaadin.flow.shared.Registration;
import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import java.util.List;

public class DocumentationEntryForm extends FormLayout {
    TextField title = new TextField("Title");
    ComboBox<String> section = new ComboBox<>("Section");
    TextArea content = new TextArea("Content");
    
    Button save = new Button("Save");
    Button delete = new Button("Delete");
    Button close = new Button("Cancel");
    
    Binder<DocumentationEntry> binder = new BeanValidationBinder<>(DocumentationEntry.class);

    public DocumentationEntryForm(List<String> sections) {
        addClassName("documentation-form");
        
        binder.bindInstanceFields(this);
        
        section.setItems(sections);
        section.setAllowCustomValue(true);
        section.addCustomValueSetListener(e -> {
            section.setValue(e.getDetail());
        });
        
        content.setHeight("300px");
        
        add(
            title,
            section,
            content,
            createButtonsLayout()
        );
    }
    
    public void setEntry(DocumentationEntry entry) {
        binder.setBean(entry);
    }
    
    private Component createButtonsLayout() {
        save.addThemeVariants(ButtonVariant.LUMO_PRIMARY);
        delete.addThemeVariants(ButtonVariant.LUMO_ERROR);
        close.addThemeVariants(ButtonVariant.LUMO_TERTIARY);
        
        save.addClickListener(event -> validateAndSave());
        delete.addClickListener(event -> fireEvent(new DeleteEvent(this, binder.getBean())));
        close.addClickListener(event -> fireEvent(new CloseEvent(this)));
        
        save.addClickShortcut(Key.ENTER);
        close.addClickShortcut(Key.ESCAPE);
        
        return new HorizontalLayout(save, delete, close);
    }
    
    private void validateAndSave() {
        if (binder.isValid()) {
            fireEvent(new SaveEvent(this, binder.getBean()));
        }
    }

    // Events
    public static abstract class DocumentationFormEvent extends ComponentEvent<DocumentationEntryForm> {
        private final DocumentationEntry entry;

        protected DocumentationFormEvent(DocumentationEntryForm source, DocumentationEntry entry) {
            super(source, false);
            this.entry = entry;
        }

        public DocumentationEntry getEntry() {
            return entry;
        }
    }

    public static class SaveEvent extends DocumentationFormEvent {
        SaveEvent(DocumentationEntryForm source, DocumentationEntry entry) {
            super(source, entry);
        }
    }

    public static class DeleteEvent extends DocumentationFormEvent {
        DeleteEvent(DocumentationEntryForm source, DocumentationEntry entry) {
            super(source, entry);
        }
    }

    public static class CloseEvent extends ComponentEvent<DocumentationEntryForm> {
        CloseEvent(DocumentationEntryForm source) {
            super(source, false);
        }
    }

    public Registration addSaveListener(ComponentEventListener<SaveEvent> listener) {
        return addListener(SaveEvent.class, listener);
    }

    public Registration addDeleteListener(ComponentEventListener<DeleteEvent> listener) {
        return addListener(DeleteEvent.class, listener);
    }

    public Registration addCloseListener(ComponentEventListener<CloseEvent> listener) {
        return addListener(CloseEvent.class, listener);
    }
}
EOL

# Create documentation entry view
echo -e "${GREEN}Creating documentation entry view...${NC}"
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
import io.joshuasalcedo.documentation.views.MainLayout;
import java.time.format.DateTimeFormatter;
import java.util.Optional;

@PageTitle("Documentation Entry")
@Route(value = "documentation/entry", layout = MainLayout.class)
public class DocumentationEntryView extends VerticalLayout implements HasUrlParameter<Long> {

    private final DocumentationService documentationService;
    
    private H2 title = new H2();
    private Paragraph metadata = new Paragraph();
    private Div contentContainer = new Div();

    public DocumentationEntryView(DocumentationService documentationService) {
        this.documentationService = documentationService;
        
        setSpacing(true);
        setPadding(true);
        
        Button backButton = new Button("Back to List", new Icon(VaadinIcon.ARROW_LEFT));
        backButton.addClickListener(e -> UI.getCurrent().navigate(DocumentationListView.class));
        
        add(backButton, title, metadata, contentContainer);
    }

    @Override
    public void setParameter(BeforeEvent event, Long parameter) {
        currentEntryId = parameter;
        Optional<DocumentationEntry> entryOpt = documentationService.findById(parameter);
        
        if (entryOpt.isPresent()) {
            DocumentationEntry entry = entryOpt.get();
            titleField.setValue(entry.getTitle());
            sectionField.setValue(entry.getSection());
            contentField.setValue(entry.getContent());
        } else {
            Notification.show("Entry not found");
            UI.getCurrent().navigate(DocumentationListView.class);
        }
    }
    
    private void saveEntry() {
        if (titleField.isEmpty()) {
            Notification.show("Title cannot be empty");
            return;
        }
        
        if (sectionField.isEmpty()) {
            Notification.show("Section cannot be empty");
            return;
        }
        
        Optional<DocumentationEntry> entryOpt = documentationService.findById(currentEntryId);
        if (entryOpt.isPresent()) {
            DocumentationEntry entry = entryOpt.get();
            entry.setTitle(titleField.getValue());
            entry.setSection(sectionField.getValue());
            entry.setContent(contentField.getValue());
            
            documentationService.saveEntry(entry);
            Notification.show("Entry saved successfully");
            UI.getCurrent().navigate(DocumentationEntryView.class, currentEntryId);
        }
    }
}
EOL

# Create docker-compose.yml
echo -e "${GREEN}Creating Docker Compose file...${NC}"
cat > ./docker-compose.yml << 'EOL'
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: documentation-app
    ports:
      - "8080:8080"
    volumes:
      - ${HOME}/.docs/documentation:/root/.docs/documentation
    restart: unless-stopped
    environment:
      - SPRING_PROFILES_ACTIVE=docker
EOL

# Create Dockerfile
echo -e "${GREEN}Creating Dockerfile...${NC}"
cat > ./Dockerfile << 'EOL'
FROM maven:3.8.6-openjdk-21-slim AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Create directory for H2 database
RUN mkdir -p /root/.docs/documentation

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOL

# Create a wrapper script to run the app
echo -e "${GREEN}Creating run script...${NC}"
cat > ./run-docs-app.sh << 'EOL'
#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Runner ===${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker is not installed. Running in local mode.${NC}"
    echo -e "${GREEN}Building with Maven...${NC}"
    ./mvnw clean package
    
    echo -e "${GREEN}Starting application...${NC}"
    java -jar target/*.jar
else
    echo -e "${GREEN}Docker is installed. Running with Docker Compose...${NC}"
    
    # Create necessary directories
    mkdir -p "$HOME/.docs/documentation"
    
    # Build and start the containers
    docker-compose up --build -d
    
    echo -e "${GREEN}Application is running at http://localhost:8080${NC}"
    echo -e "${YELLOW}To stop the application, run: docker-compose down${NC}"
fi
EOL

# Make scripts executable
chmod +x ./run-docs-app.sh

echo -e "\n${GREEN}Setup completed successfully!${NC}"
echo -e "${YELLOW}To run the application, execute: ./run-docs-app.sh${NC}"
echo -e "${BLUE}The documentation app will be available at: http://localhost:8080${NC}"
echo -e "${BLUE}Data will be stored in: $HOME/.docs/documentation${NC}"Parameter(BeforeEvent event, Long parameter) {
        Optional<DocumentationEntry> entryOpt = documentationService.findById(parameter);
        
        if (entryOpt.isPresent()) {
            DocumentationEntry entry = entryOpt.get();
            title.setText(entry.getTitle());
            
            String metadataText = "Section: " + entry.getSection() + " | " +
                    "Created: " + entry.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) + " | " +
                    "Updated: " + entry.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            metadata.setText(metadataText);
            
            Div contentDiv = new Div();
            // Simple markdown-like rendering (bold, italics, code)
            String processedContent = entry.getContent()
                    .replace("\n\n", "<br><br>")
                    .replace("\n", "<br>");
            contentDiv.getElement().setProperty("innerHTML", processedContent);
            
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

# Create documentation entry edit view
echo -e "${GREEN}Creating documentation entry edit view...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/documentation/DocumentationEntryEditView.java << 'EOL'
package io.joshuasalcedo.documentation.views.documentation;

import com.vaadin.flow.component.UI;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.button.ButtonVariant;
import com.vaadin.flow.component.combobox.ComboBox;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.notification.Notification;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.component.textfield.TextArea;
import com.vaadin.flow.component.textfield.TextField;
import com.vaadin.flow.router.BeforeEvent;
import com.vaadin.flow.router.HasUrlParameter;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.views.MainLayout;
import java.util.Optional;

@PageTitle("Edit Documentation Entry")
@Route(value = "documentation/edit", layout = MainLayout.class)
public class DocumentationEntryEditView extends VerticalLayout implements HasUrlParameter<Long> {

    private final DocumentationService documentationService;
    
    private TextField titleField = new TextField("Title");
    private ComboBox<String> sectionField = new ComboBox<>("Section");
    private TextArea contentField = new TextArea("Content");
    
    private Long currentEntryId;

    public DocumentationEntryEditView(DocumentationService documentationService) {
        this.documentationService = documentationService;
        
        setSpacing(true);
        setPadding(true);
        
        H2 header = new H2("Edit Documentation Entry");
        add(header);
        
        // Configure fields
        titleField.setWidth("100%");
        
        sectionField.setItems(documentationService.getAllSections());
        sectionField.setAllowCustomValue(true);
        sectionField.addCustomValueSetListener(e -> {
            sectionField.setValue(e.getDetail());
        });
        
        contentField.setHeight("400px");
        contentField.setWidth("100%");
        
        // Buttons
        Button saveButton = new Button("Save");
        saveButton.addThemeVariants(ButtonVariant.LUMO_PRIMARY);
        saveButton.addClickListener(e -> saveEntry());
        
        Button cancelButton = new Button("Cancel");
        cancelButton.addClickListener(e -> UI.getCurrent().navigate(DocumentationEntryView.class, currentEntryId));
        
        HorizontalLayout buttonLayout = new HorizontalLayout(saveButton, cancelButton);
        
        add(titleField, sectionField, contentField, buttonLayout);
    }

@Override
public void setParameter(BeforeEvent event, Long parameter) {
    currentEntryId = parameter;
    Optional<DocumentationEntry> entryOpt = documentationService.findById(parameter);
    
    if (entryOpt.isPresent()) {
        DocumentationEntry entry = entryOpt.get();
        titleField.setValue(entry.getTitle());
        sectionField.setValue(entry.getSection());
        contentField.setValue(entry.getContent());
    } else {
        Notification.show("Entry not found");
        UI.getCurrent().navigate(DocumentationListView.class);
    }
}

private void saveEntry() {
    if (titleField.isEmpty()) {
        Notification.show("Title cannot be empty");
        return;
    }
    
    if (sectionField.isEmpty()) {
        Notification.show("Section cannot be empty");
        return;
    }
    
    Optional<DocumentationEntry> entryOpt = documentationService.findById(currentEntryId);
    if (entryOpt.isPresent()) {
        DocumentationEntry entry = entryOpt.get();
        entry.setTitle(titleField.getValue());
        entry.setSection(sectionField.getValue());
        entry.setContent(contentField.getValue());
        
        documentationService.saveEntry(entry);
        Notification.show("Entry saved successfully");
        UI.getCurrent().navigate(DocumentationEntryView.class, currentEntryId);
    }
}
