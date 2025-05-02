
package io.joshuasalcedo.documentation.views.main;

import com.vaadin.flow.component.AttachEvent;
import com.vaadin.flow.component.Component;
import com.vaadin.flow.component.UI;
import com.vaadin.flow.component.applayout.AppLayout;
import com.vaadin.flow.component.applayout.DrawerToggle;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.button.ButtonVariant;
import com.vaadin.flow.component.html.H1;
import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Header;
import com.vaadin.flow.component.icon.Icon;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.FlexComponent;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.Scroller;
import com.vaadin.flow.component.sidenav.SideNav;
import com.vaadin.flow.component.sidenav.SideNavItem;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.theme.lumo.LumoUtility;
import io.joshuasalcedo.documentation.data.repository.DocumentationRepository;
import io.joshuasalcedo.documentation.views.home.HomeView;
import io.joshuasalcedo.documentation.views.documentation.DocumentationListView;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * The main view is a top-level placeholder for other views.
 */
public class MainLayout extends AppLayout {

    private H2 viewTitle;
    private final DocumentationRepository documentationRepository;
    private SideNav nav;

    @Autowired
    public MainLayout(DocumentationRepository documentationRepository) {
        this.documentationRepository = documentationRepository;
        
        setPrimarySection(Section.DRAWER);
        addDrawerContent();
        addHeaderContent();
    }

    private void addHeaderContent() {
        DrawerToggle toggle = new DrawerToggle();
        toggle.getElement().setAttribute("aria-label", "Menu toggle");

        viewTitle = new H2();
        viewTitle.addClassNames(LumoUtility.FontSize.LARGE, LumoUtility.Margin.NONE);

        // Add search button
        Button searchButton = new Button(new Icon(VaadinIcon.SEARCH));
        searchButton.addThemeVariants(ButtonVariant.LUMO_TERTIARY);
        searchButton.addClickListener(new com.vaadin.flow.component.ComponentEventListener<com.vaadin.flow.component.ClickEvent<Button>>() {
            @Override
            public void onComponentEvent(com.vaadin.flow.component.ClickEvent<Button> e) {
                UI.getCurrent().navigate(SearchView.class);
            }
        });
        searchButton.getElement().setAttribute("aria-label", "Search");

        HorizontalLayout header = new HorizontalLayout(toggle, viewTitle, searchButton);
        header.setDefaultVerticalComponentAlignment(FlexComponent.Alignment.CENTER);
        header.setWidthFull();
        header.expand(viewTitle);
        header.addClassNames("py-0", "px-m");

        addToNavbar(true, header);
    }

    private void addDrawerContent() {
        H1 appName = new H1("Documentation App");
        appName.addClassNames(LumoUtility.FontSize.LARGE, LumoUtility.Margin.NONE);
        Header header = new Header(appName);

        nav = new SideNav();
        updateNavigation();
        
        Scroller scroller = new Scroller(nav);

        addToDrawer(header, scroller);
    }

    private void updateNavigation() {
        nav.removeAll();
        
        // Add main navigation items
        nav.addItem(new SideNavItem("Home", HomeView.class, new Icon(VaadinIcon.HOME)));
        nav.addItem(new SideNavItem("All Documentation", DocumentationListView.class, new Icon(VaadinIcon.LIST)));
        nav.addItem(new SideNavItem("Search", SearchView.class, new Icon(VaadinIcon.SEARCH)));
        
        // Add tools section
        SideNavItem toolsHeader = new SideNavItem("Tools");
        toolsHeader.addClassName("menu-header");
        nav.addItem(toolsHeader);
        
        nav.addItem(new SideNavItem("Export", ExportView.class, new Icon(VaadinIcon.DOWNLOAD)));
        nav.addItem(new SideNavItem("Import", ImportView.class, new Icon(VaadinIcon.UPLOAD)));
        
        // Add section header
        SideNavItem sectionsHeader = new SideNavItem("Sections");
        sectionsHeader.addClassName("menu-header");
        nav.addItem(sectionsHeader);
        
        // Add dynamic sections
        for (String section : documentationRepository.findAllSections()) {
            String route = "documentation/section/" + section.toLowerCase().replace(" ", "-");
            SideNavItem sectionItem = new SideNavItem(section, route);
            sectionItem.setPrefixComponent(new Icon(VaadinIcon.BOOK));
            nav.addItem(sectionItem);
        }
    }

    @Override
    protected void onAttach(AttachEvent attachEvent) {
        super.onAttach(attachEvent);
        // Update navigation every time the layout is attached
        updateNavigation();
    }

    @Override
    protected void afterNavigation() {
        super.afterNavigation();
        viewTitle.setText(getCurrentPageTitle());
    }

    private String getCurrentPageTitle() {
        PageTitle title = getContent().getClass().getAnnotation(PageTitle.class);
        return title == null ? "" : title.value();
    }
}
