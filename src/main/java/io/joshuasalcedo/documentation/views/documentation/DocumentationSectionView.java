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
