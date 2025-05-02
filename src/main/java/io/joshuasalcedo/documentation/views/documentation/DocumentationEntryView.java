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
import io.joshuasalcedo.documentation.util.MarkdownRenderer;
import io.joshuasalcedo.documentation.views.MainLayout;
import java.time.format.DateTimeFormatter;
import java.util.Optional;

@PageTitle("Documentation Entry")
@Route(value = "documentation/entry", layout = MainLayout.class)
public class DocumentationEntryView extends VerticalLayout implements HasUrlParameter<Long> {

    private final DocumentationService documentationService;
    private final MarkdownRenderer markdownRenderer;
    
    private H2 title = new H2();
    private Paragraph metadata = new Paragraph();
    private Div contentContainer = new Div();

    public DocumentationEntryView(DocumentationService documentationService, MarkdownRenderer markdownRenderer) {
        this.documentationService = documentationService;
        this.markdownRenderer = markdownRenderer;
        
        setSpacing(true);
        setPadding(true);
        
        Button backButton = new Button("Back to List", new Icon(VaadinIcon.ARROW_LEFT));
        backButton.addClickListener(e -> UI.getCurrent().navigate(DocumentationListView.class));
        
        add(backButton, title, metadata, contentContainer);
    }

    @Override
    public void setParameter(BeforeEvent event, Long parameter) {
        Optional<DocumentationEntry> entryOpt = documentationService.findById(parameter);
        
        if (entryOpt.isPresent()) {
            DocumentationEntry entry = entryOpt.get();
            title.setText(entry.getTitle());
            
            String metadataText = "Section: " + entry.getSection() + " | " +
                    "Created: " + entry.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) + " | " +
                    "Updated: " + entry.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            metadata.setText(metadataText);
            
            Div contentDiv = new Div();
            String renderedContent = markdownRenderer.renderMarkdown(entry.getContent());
            contentDiv.getElement().setProperty("innerHTML", renderedContent);
            
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
