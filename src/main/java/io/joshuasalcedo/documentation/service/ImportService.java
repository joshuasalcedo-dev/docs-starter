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
