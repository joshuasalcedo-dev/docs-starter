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
