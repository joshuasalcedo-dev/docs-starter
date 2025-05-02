package io.joshuasalcedo.documentation.data.repository;

import io.joshuasalcedo.documentation.data.entity.DocumentationEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DocumentationRepository extends JpaRepository<DocumentationEntry, Long> {

    List<DocumentationEntry> findBySection(String section);

    List<DocumentationEntry> findByTitleContainingIgnoreCase(String titlePart);

    @Query("SELECT DISTINCT d.section FROM DocumentationEntry d ORDER BY d.section")
    List<String> findAllSections();

    // Modified query that only uses LOWER on title, and direct comparison for content
    @Query("SELECT d FROM DocumentationEntry d WHERE " +
            "LOWER(d.title) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "d.content LIKE CONCAT('%', :searchTerm, '%')")
    List<DocumentationEntry> search(@Param("searchTerm") String searchTerm);
}
