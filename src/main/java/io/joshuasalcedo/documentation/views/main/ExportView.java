package io.joshuasalcedo.documentation.views.main;

import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.button.ButtonVariant;
import com.vaadin.flow.component.combobox.ComboBox;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Paragraph;
import com.vaadin.flow.component.notification.Notification;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.views.main.MainLayout;

@PageTitle("Export Documentation")
@Route(value = "documentation/export", layout = MainLayout.class)
public class ExportView extends VerticalLayout {

    private final DocumentationService documentationService;
    private final ComboBox<String> sectionSelector = new ComboBox<>("Select Section");
    private final ComboBox<String> formatSelector = new ComboBox<>("Export Format");

    public ExportView(DocumentationService documentationService) {
        this.documentationService = documentationService;

        setSizeFull();
        setPadding(true);
        setSpacing(true);

        H2 header = new H2("Export Documentation");
        add(header);

        Paragraph instructions = new Paragraph("Select a section and export format to download documentation.");
        add(instructions);

        configureSectionSelector();
        configureFormatSelector();

        Button exportButton = new Button("Export");
        exportButton.addThemeVariants(ButtonVariant.LUMO_PRIMARY);
        exportButton.addClickListener(e -> exportDocumentation());

        HorizontalLayout formLayout = new HorizontalLayout(sectionSelector, formatSelector);
        formLayout.setWidthFull();

        add(formLayout, exportButton);
    }

    private void configureSectionSelector() {
        sectionSelector.setItems(documentationService.getAllSections());
        sectionSelector.setPlaceholder("All Sections");
        sectionSelector.setAllowCustomValue(false);
        sectionSelector.setWidthFull();
    }

    private void configureFormatSelector() {
        formatSelector.setItems("HTML", "PDF", "Markdown", "JSON");
        formatSelector.setValue("HTML");
        formatSelector.setAllowCustomValue(false);
        formatSelector.setWidthFull();
    }

    private void exportDocumentation() {
        String section = sectionSelector.getValue();
        String format = formatSelector.getValue();

        // This is a placeholder. Actual export functionality would be implemented here
        Notification.show("Export " + (section != null ? section : "All Sections") +
                " in " + format + " format (Feature not yet implemented)");
    }
}
