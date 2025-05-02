package io.joshuasalcedo.documentation.util;

import org.commonmark.node.Node;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;
import org.commonmark.ext.gfm.tables.TablesExtension;
import org.commonmark.ext.gfm.strikethrough.StrikethroughExtension;
import org.commonmark.ext.autolink.AutolinkExtension;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

/**
 * Utility class for rendering Markdown content to HTML
 */
@Component
public class MarkdownRenderer {

    private final Parser parser;
    private final HtmlRenderer renderer;

    public MarkdownRenderer() {
        // Set up extensions
        List<org.commonmark.Extension> extensions = Arrays.asList(
                TablesExtension.create(),
                StrikethroughExtension.create(),
                AutolinkExtension.create()
        );

        // Create parser and renderer with extensions
        parser = Parser.builder()
                .extensions(extensions)
                .build();

        renderer = HtmlRenderer.builder()
                .extensions(extensions)
                .escapeHtml(true)
                .build();
    }

    /**
     * Render Markdown text to HTML
     *
     * @param markdown the markdown text to render
     * @return the rendered HTML
     */
    public String renderMarkdown(String markdown) {
        if (markdown == null || markdown.isEmpty()) {
            return "";
        }

        Node document = parser.parse(markdown);
        return renderer.render(document);
    }
}