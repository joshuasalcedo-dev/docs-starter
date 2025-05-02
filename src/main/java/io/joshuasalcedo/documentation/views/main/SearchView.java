package io.joshuasalcedo.documentation.views.main;

import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.component.textfield.TextField;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.views.main.MainLayout;

import com.vaadin.flow.component.grid.Grid;
import com.vaadin.flow.component.grid.GridVariant;
import com.vaadin.flow.component.UI;
import com.vaadin.flow.component.button.ButtonVariant;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.data.renderer.ComponentRenderer;
import com.vaadin.flow.data.value.ValueChangeMode;

import java.time.format.DateTimeFormatter;
import java.util.List;

@PageTitle("Search Documentation")
@Route(value = "documentation/search", layout = MainLayout.class)
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
        add(header);

        configureSearchField();
        configureGrid();

        HorizontalLayout searchLayout = new HorizontalLayout(searchField);
        searchLayout.setWidthFull();

        add(searchLayout, grid);
    }

    private void configureSearchField() {
        searchField.setPlaceholder("Enter search terms...");
        searchField.setClearButtonVisible(true);
        searchField.setValueChangeMode(ValueChangeMode.LAZY);
        searchField.addValueChangeListener(e -> search(e.getValue()));
        searchField.setWidthFull();

        Button searchButton = new Button("Search", VaadinIcon.SEARCH.create());
        searchButton.addThemeVariants(ButtonVariant.LUMO_PRIMARY);
        searchButton.addClickListener(e -> search(searchField.getValue()));

        searchField.setSuffixComponent(searchButton);
    }

    private void configureGrid() {
        grid.addClassName("search-results-grid");
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
                UI.getCurrent().navigate("documentation/entry/" + entry.getId());
            });
            return viewButton;
        })).setHeader("Actions").setFlexGrow(0);

        grid.getColumns().forEach(col -> col.setAutoWidth(true));
        grid.addThemeVariants(GridVariant.LUMO_ROW_STRIPES);
    }

    private void search(String searchTerm) {
        if (searchTerm == null || searchTerm.isEmpty()) {
            grid.setItems(List.of());
            return;
        }

        List<DocumentationEntry> results = documentationService.searchByContent(searchTerm);
        grid.setItems(results);
    }
}