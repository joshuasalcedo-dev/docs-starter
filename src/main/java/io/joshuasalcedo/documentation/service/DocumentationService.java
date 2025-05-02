package io.joshuasalcedo.documentation.service;

import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import io.joshuasalcedo.documentation.data.repository.DocumentationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors; // Added missing import

@Service
public class DocumentationService {
    private final DocumentationRepository documentationRepository;

    @Autowired
    public DocumentationService(DocumentationRepository documentationRepository) {
        this.documentationRepository = documentationRepository;
    }

    public List<DocumentationEntry> findAllEntries() {
        return documentationRepository.findAll();
    }

    public Optional<DocumentationEntry> findById(Long id) {
        return documentationRepository.findById(id);
    }

    public List<DocumentationEntry> findBySection(String section) {
        return documentationRepository.findBySection(section);
    }

    public List<DocumentationEntry> searchByTitle(String titlePart) {
        return documentationRepository.findByTitleContainingIgnoreCase(titlePart);
    }

    public List<DocumentationEntry> search(String searchTerm) {
        return documentationRepository.search(searchTerm);
    }

    public List<String> getAllSections() {
        return documentationRepository.findAllSections();
    }

    public DocumentationEntry saveEntry(DocumentationEntry entry) {
        return documentationRepository.save(entry);
    }

    public void deleteEntry(Long id) {
        documentationRepository.deleteById(id);
    }

    public List<DocumentationEntry> searchByContent(String searchTerm) {
            return documentationRepository.search(searchTerm);
    }
}