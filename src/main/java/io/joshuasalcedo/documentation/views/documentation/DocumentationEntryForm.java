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
    
    Binder<DocumentationEntry> binder = new BeanValidationBinder<DocumentationEntry>(DocumentationEntry.class);

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
