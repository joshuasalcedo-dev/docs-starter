package io.joshuasalcedo.documentation.views.main;

import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.button.ButtonVariant;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Paragraph;
import com.vaadin.flow.component.notification.Notification;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.component.upload.Upload;
import com.vaadin.flow.component.upload.receivers.MemoryBuffer;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import io.joshuasalcedo.documentation.service.DocumentationService;
import io.joshuasalcedo.documentation.views.main.MainLayout;

@PageTitle("Import Documentation")
@Route(value = "documentation/import", layout = MainLayout.class)
public class ImportView extends VerticalLayout {

    private final DocumentationService documentationService;
    private final MemoryBuffer buffer = new MemoryBuffer();
    private final Upload upload = new Upload(buffer);

    public ImportView(DocumentationService documentationService) {
        this.documentationService = documentationService;

        setSizeFull();
        setPadding(true);
        setSpacing(true);

        H2 header = new H2("Import Documentation");
        add(header);

        Paragraph instructions = new Paragraph("Upload a file to import documentation. " +
                "Supported formats: JSON, Markdown, HTML.");
        add(instructions);

        configureUpload();

        Button importButton = new Button("Process Import");
        importButton.addThemeVariants(ButtonVariant.LUMO_PRIMARY);
        importButton.addClickListener(e -> processImport());

        add(upload, importButton);
    }

    private void configureUpload() {
        upload.setAcceptedFileTypes("application/json", ".md", ".html", ".json");
        upload.setMaxFiles(1);
        upload.setDropAllowed(true);
        upload.setWidthFull();

        upload.addSucceededListener(event -> {
            Notification.show("File uploaded: " + event.getFileName());
        });
    }

    private void processImport() {
        if (buffer.getFileData() == null || buffer.getFileName().isEmpty()) {
            Notification.show("Please upload a file first");
            return;
        }

        // This is a placeholder. Actual import functionality would be implemented here
        Notification.show("Import processing started for: " + buffer.getFileName() +
                " (Feature not yet implemented)");
    }
}