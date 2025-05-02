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
import io.joshuasalcedo.documentation.views.main.MainLayout;

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
