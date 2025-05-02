#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Setup Final Part ===${NC}"

# Create export functionality
echo -e "${GREEN}Creating export functionality...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/service/ExportService.java << 'EOL'
package io.joshuasalcedo.documentation.service;

import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ExportService {

    /**
     * Exports documentation entries to markdown format
     * @param entries List of documentation entries to export
     * @return String containing markdown representation of the entries
     */
    public String exportToMarkdown(List<DocumentationEntry> entries) {
        StringBuilder markdown = new StringBuilder();
        
        for (DocumentationEntry entry : entries) {
            markdown.append("# ").append(entry.getTitle()).append("\n\n");
            markdown.append("*Section: ").append(entry.getSection()).append("*\n\n");
            markdown.append(entry.getContent()).append("\n\n");
            markdown.append("---\n\n");
        }
        
        return markdown.toString();
    }
    
    /**
     * Exports a single documentation entry to markdown format
     * @param entry The documentation entry to export
     * @return String containing markdown representation
     */
    public String exportEntryToMarkdown(DocumentationEntry entry) {
        StringBuilder markdown = new StringBuilder();
        
        markdown.append("# ").append(entry.getTitle()).append("\n\n");
        markdown.append("*Section: ").append(entry.getSection()).append("*\n\n");
        markdown.append(entry.getContent()).append("\n\n");
        
        return markdown.toString();
    }

    /**
     * Exports documentation entries to HTML format
     * @param entries List of documentation entries to export
     * @return String containing HTML representation of the entries
     */
    public String exportToHtml(List<DocumentationEntry> entries) {
        StringBuilder html = new StringBuilder();
        
        html.append("<!DOCTYPE html>\n<html>\n<head>\n");
        html.append("<meta charset=\"UTF-8\">\n");
        html.append("<title>Documentation Export</title>\n");
        html.append("<style>\n");
        html.append("body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }\n");
        html.append("h1 { color: #1a73e8; }\n");
        html.append(".section { color: #666; font-style: italic; margin-bottom: 20px; }\n");
        html.append(".entry { margin-bottom: 40px; border-bottom: 1px solid #eee; padding-bottom: 20px; }\n");
        html.append("</style>\n");
        html.append("</head>\n<body>\n");
        html.append("<h1>Documentation Export</h1>\n");
        
        for (DocumentationEntry entry : entries) {
            html.append("<div class=\"entry\">\n");
            html.append("<h2>").append(entry.getTitle()).append("</h2>\n");
            html.append("<div class=\"section\">Section: ").append(entry.getSection()).append("</div>\n");
            html.append("<div class=\"content\">").append(entry.getContent().replace("\n", "<br>")).append("</div>\n");
            html.append("</div>\n");
        }
        
        html.append("</body>\n</html>");
        
        return html.toString();
    }
}
EOL

# Create export view
echo -e "${GREEN}Creating export view...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/export/ExportView.java << 'EOL'
package io.joshuasalcedo.documentation.views.export;

import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.checkbox.CheckboxGroup;
import com.vaadin.flow.component.combobox.ComboBox;
import com.vaadin.flow.component.html.Anchor;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Paragraph;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import com.vaadin.flow.server.StreamResource;
import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.service.ExportService;
import io.joshuasalcedo.documentation.views.MainLayout;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@PageTitle("Export Documentation")
@Route(value = "export", layout = MainLayout.class)
public class ExportView extends VerticalLayout {

    private final DocumentationService documentationService;
    private final ExportService exportService;
    
    private final ComboBox<String> sectionSelect = new ComboBox<>("Section");
    private final CheckboxGroup<DocumentationEntry> entrySelect = new CheckboxGroup<>("Select Entries");
    private final ComboBox<String> formatSelect = new ComboBox<>("Export Format");
    
    public ExportView(DocumentationService documentationService, ExportService exportService) {
        this.documentationService = documentationService;
        this.exportService = exportService;
        
        setSizeFull();
        setPadding(true);
        setSpacing(true);
        
        H2 header = new H2("Export Documentation");
        Paragraph description = new Paragraph("Select the documentation entries you want to export and the desired format.");
        
        setupSectionSelect();
        setupFormatSelect();
        setupEntrySelect();
        
        Button exportButton = createExportButton();
        
        add(header, description, sectionSelect, entrySelect, formatSelect, exportButton);
    }

    private void setupSectionSelect() {
        List<String> sections = documentationService.getAllSections();
        sections.add(0, "All Sections");
        
        sectionSelect.setItems(sections);
        sectionSelect.setValue("All Sections");
        sectionSelect.setWidthFull();
        
        sectionSelect.addValueChangeListener(event -> updateEntrySelect());
    }
    
    private void setupFormatSelect() {
        formatSelect.setItems("Markdown", "HTML");
        formatSelect.setValue("Markdown");
        formatSelect.setWidthFull();
    }
    
    private void setupEntrySelect() {
        entrySelect.setItemLabelGenerator(DocumentationEntry::getTitle);
        entrySelect.setWidthFull();
        updateEntrySelect();
    }
    
    private void updateEntrySelect() {
        String selectedSection = sectionSelect.getValue();
        List<DocumentationEntry> entries;
        
        if ("All Sections".equals(selectedSection)) {
            entries = documentationService.findAllEntries();
        } else {
            entries = documentationService.findBySection(selectedSection);
        }
        
        entrySelect.setItems(entries);
        entrySelect.select(entries);
    }
    
    private Button createExportButton() {
        Button exportButton = new Button("Generate Export");
        
        exportButton.addClickListener(event -> {
            Set<DocumentationEntry> selectedEntries = entrySelect.getSelectedItems();
            
            if (selectedEntries.isEmpty()) {
                return;
            }
            
            String format = formatSelect.getValue();
            String fileExtension = "Markdown".equals(format) ? "md" : "html";
            String mimeType = "Markdown".equals(format) ? "text/markdown" : "text/html";
            String content;
            
            List<DocumentationEntry> entriesToExport = selectedEntries.stream()
                    .collect(Collectors.toList());
            
            if ("Markdown".equals(format)) {
                content = exportService.exportToMarkdown(entriesToExport);
            } else {
                content = exportService.exportToHtml(entriesToExport);
            }
            
            StreamResource resource = new StreamResource("documentation-export." + fileExtension,
                    () -> new ByteArrayInputStream(content.getBytes(StandardCharsets.UTF_8)));
            
            resource.setContentType(mimeType);
            
            Anchor downloadLink = new Anchor(resource, "");
            downloadLink.getElement().setAttribute("download", true);
            downloadLink.setHref(resource);
            
            // Add the anchor to the UI
            add(downloadLink);
            
            // Click the download link
            downloadLink.getElement().callJsFunction("click");
            
            // Remove the anchor after download starts
            remove(downloadLink);
        });
        
        return exportButton;
    }
}
EOL

# Create import functionality
echo -e "${GREEN}Creating import functionality...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/service/ImportService.java << 'EOL'
package io.joshuasalcedo.documentation.service;

import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class ImportService {

    /**
     * Imports documentation entries from markdown format
     * @param markdownContent Markdown content to parse
     * @param defaultSection Default section to use if none is specified
     * @return List of parsed documentation entries
     */
    public List<DocumentationEntry> importFromMarkdown(String markdownContent, String defaultSection) {
        List<DocumentationEntry> entries = new ArrayList<>();
        
        // Split the content by markdown header level 1
        String[] entryBlocks = markdownContent.split("(?m)^# ");
        
        // Skip the first block if it's empty (happens when the document starts with a header)
        int startIndex = entryBlocks[0].trim().isEmpty() ? 1 : 0;
        
        for (int i = startIndex; i < entryBlocks.length; i++) {
            String block = entryBlocks[i].trim();
            if (block.isEmpty()) continue;
            
            // Extract title (first line)
            String title;
            String content;
            
            int firstLineEnd = block.indexOf('\n');
            if (firstLineEnd > 0) {
                title = block.substring(0, firstLineEnd).trim();
                content = block.substring(firstLineEnd).trim();
            } else {
                title = block;
                content = "";
            }
            
            // Extract section if present (format: *Section: SectionName*)
            String section = defaultSection;
            Pattern sectionPattern = Pattern.compile("\\*Section:\\s*([^*]+)\\*");
            Matcher sectionMatcher = sectionPattern.matcher(content);
            
            if (sectionMatcher.find()) {
                section = sectionMatcher.group(1).trim();
                // Remove the section line from content
                content = content.replaceFirst("\\*Section:\\s*[^*]+\\*", "").trim();
            }
            
            // Create entry
            DocumentationEntry entry = new DocumentationEntry();
            entry.setTitle(title);
            entry.setSection(section);
            entry.setContent(content);
            
            entries.add(entry);
        }
        
        return entries;
    }
}
EOL

# Create import view
echo -e "${GREEN}Creating import view...${NC}"
cat > ./src/main/java/io/joshuasalcedo/documentation/views/import/ImportView.java << 'EOL'
package io.joshuasalcedo.documentation.views.import;

import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.combobox.ComboBox;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Paragraph;
import com.vaadin.flow.component.notification.Notification;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.component.textfield.TextArea;
import com.vaadin.flow.component.textfield.TextField;
import com.vaadin.flow.component.upload.Upload;
import com.vaadin.flow.component.upload.receivers.MemoryBuffer;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.service.ImportService;
import io.joshuasalcedo.documentation.views.MainLayout;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.List;
import java.util.stream.Collectors;

@PageTitle("Import Documentation")
@Route(value = "import", layout = MainLayout.class)
public class ImportView extends VerticalLayout {

    private final DocumentationService documentationService;
    private final ImportService importService;
    
    private final TextField newSectionField = new TextField("New Section Name");
    private final ComboBox<String> sectionSelect = new ComboBox<>("Import to Section");
    private final TextArea contentArea = new TextArea("Markdown Content");
    
    public ImportView(DocumentationService documentationService, ImportService importService) {
        this.documentationService = documentationService;
        this.importService = importService;
        
        setSizeFull();
        setPadding(true);
        setSpacing(true);
        
        H2 header = new H2("Import Documentation");
        Paragraph description = new Paragraph(
                "Import documentation from Markdown files. The content should follow this format:\n" +
                "# Entry Title\n" +
                "*Section: Optional Section Name*\n\n" +
                "Entry content...\n\n" +
                "# Another Entry\n" +
                "More content..."
        );
        
        setupSectionFields();
        
        contentArea.setHeight("300px");
        contentArea.setWidthFull();
        
        MemoryBuffer buffer = new MemoryBuffer();
        Upload upload = new Upload(buffer);
        upload.setAcceptedFileTypes(".md", ".txt", ".markdown");
        upload.setMaxFiles(1);
        upload.setWidthFull();
        
        upload.addSucceededListener(event -> {
            try {
                InputStream inputStream = buffer.getInputStream();
                String content = new BufferedReader(new InputStreamReader(inputStream))
                        .lines().collect(Collectors.joining("\n"));
                contentArea.setValue(content);
            } catch (Exception e) {
                Notification.show("Error reading file: " + e.getMessage());
            }
        });
        
        Button importButton = new Button("Import Documentation");
        importButton.addClickListener(event -> importDocumentation());
        
        add(header, description, upload, sectionSelect, newSectionField, contentArea, importButton);
    }

    private void setupSectionFields() {
        List<String> sections = documentationService.getAllSections();
        sections.add(0, "New Section...");
        
        sectionSelect.setItems(sections);
        sectionSelect.setValue("New Section...");
        sectionSelect.setWidthFull();
        
        newSectionField.setWidthFull();
        
        sectionSelect.addValueChangeListener(event -> {
            String value = event.getValue();
            newSectionField.setVisible("New Section...".equals(value));
        });
    }
    
    private void importDocumentation() {
        String content = contentArea.getValue();
        if (content.isEmpty()) {
            Notification.show("Please enter or upload content");
            return;
        }
        
        String section;
        if ("New Section...".equals(sectionSelect.getValue())) {
            section = newSectionField.getValue();
            if (section.isEmpty()) {
                Notification.show("Please enter a section name");
                return;
            }
        } else {
            section = sectionSelect.getValue();
        }
        
        List<DocumentationEntry> entries = importService.importFromMarkdown(content, section);
        
        if (entries.isEmpty()) {
            Notification.show("No valid entries found in the content");
            return;
        }
        
        // Save all entries
        for (DocumentationEntry entry : entries) {
            documentationService.saveEntry(entry);
        }
        
        Notification.show("Successfully imported " + entries.size() + " entries");
        
        // Clear form
        contentArea.clear();
    }
}
EOL

# Update MainLayout to include export and import
echo -e "${GREEN}Updating MainLayout for export and import...${NC}"
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
import io.joshuasalcedo.documentation.data.repository.DocumentationRepository;
import io.joshuasalcedo.documentation.views.home.HomeView;
import io.joshuasalcedo.documentation.views.documentation.DocumentationListView;
import io.joshuasalcedo.documentation.views.search.SearchView;
import io.joshuasalcedo.documentation.views.export.ExportView;
import io.joshuasalcedo.documentation.views.import.ImportView;
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

        // Add search button
        Button searchButton = new Button(new Icon(VaadinIcon.SEARCH));
        searchButton.addThemeVariants(ButtonVariant.LUMO_TERTIARY);
        searchButton.addClickListener(e -> UI.getCurrent().navigate(SearchView.class));
        searchButton.getElement().setAttribute("aria-label", "Search");

        HorizontalLayout header = new HorizontalLayout(toggle, viewTitle, searchButton);
        header.setDefaultVerticalComponentAlignment(FlexComponent.Alignment.CENTER);
        header.setWidthFull();
        header.expand(viewTitle);
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
        nav.addItem(new SideNavItem("Search", SearchView.class, new Icon(VaadinIcon.SEARCH)));
        
        // Add tools section
        SideNavItem toolsHeader = new SideNavItem("Tools");
        toolsHeader.addClassName("menu-header");
        nav.addItem(toolsHeader);
        
        nav.addItem(new SideNavItem("Export", ExportView.class, new Icon(VaadinIcon.DOWNLOAD)));
        nav.addItem(new SideNavItem("Import", ImportView.class, new Icon(VaadinIcon.UPLOAD)));
        
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

# Create a wrapper script to run all setup scripts
echo -e "${GREEN}Creating wrapper script...${NC}"
cat > ./setup-documentation-app.sh << 'EOL'
#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Setup Wrapper ===${NC}"
echo -e "${YELLOW}This script will run all necessary setup scripts${NC}"

# Make all scripts executable
chmod +x setup-docs-app.sh
chmod +x setup-docs-app-continued.sh
chmod +x setup-docs-app-continued2.sh

# Run the scripts in sequence
echo -e "\n${GREEN}Running first setup script...${NC}"
./setup-docs-app.sh

echo -e "\n${GREEN}Running second setup script...${NC}"
./setup-docs-app-continued.sh

echo -e "\n${GREEN}Running final setup script...${NC}"
./setup-docs-app-continued2.sh

echo -e "\n${BLUE}All setup scripts completed successfully!${NC}"
echo -e "${YELLOW}To run the application, execute: ./run-docs-app.sh${NC}"
