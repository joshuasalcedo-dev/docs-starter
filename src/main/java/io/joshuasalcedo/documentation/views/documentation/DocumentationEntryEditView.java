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
import io.joshuasalcedo.documentation.views.main.MainLayout;

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
        titleField.setRequired(true);
        
        sectionField.setItems(documentationService.getAllSections());
        sectionField.setAllowCustomValue(true);
        sectionField.addCustomValueSetListener(e -> {
            sectionField.setValue(e.getDetail());
        });
        sectionField.setRequired(true);
        sectionField.setWidth("100%");
        
        contentField.setHeight("400px");
        contentField.setWidth("100%");
        contentField.setPlaceholder("Content supports markdown formatting. Use # for headers, **bold** for bold text, etc.");
        
        // Buttons
        Button saveButton = new Button("Save");
        saveButton.addThemeVariants(ButtonVariant.LUMO_PRIMARY);
        saveButton.addClickListener(e -> saveEntry());
        
        Button cancelButton = new Button("Cancel");
        cancelButton.addClickListener(e -> {
            if (currentEntryId != null) {
                UI.getCurrent().navigate(DocumentationEntryView.class, currentEntryId);
            } else {
                UI.getCurrent().navigate(DocumentationListView.class);
            }
        });
        
        Button previewButton = new Button("Preview");
        previewButton.addClickListener(e -> {
            if (currentEntryId != null) {
                // Save temporarily and navigate to view
                saveEntry();
                UI.getCurrent().navigate(DocumentationEntryView.class, currentEntryId);
            }
        });
        
        HorizontalLayout buttonLayout = new HorizontalLayout(saveButton, previewButton, cancelButton);
        buttonLayout.setSpacing(true);
        
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
}