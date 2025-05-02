package io.joshuasalcedo.documentation.views;

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

@PageTitle("Documentation App")
public class MainLayout extends AppLayout {

    private H2 viewTitle;

    public MainLayout() {
        setPrimarySection(Section.DRAWER);
        addToNavbar(true, createHeaderContent());
        addToDrawer(createDrawerContent());
    }

    private Component createHeaderContent() {
        HorizontalLayout layout = new HorizontalLayout();
        layout.setWidthFull();
        layout.setSpacing(false);
        layout.setAlignItems(FlexComponent.Alignment.CENTER);
        layout.addClassNames(
                LumoUtility.Padding.MEDIUM);

        DrawerToggle toggle = new DrawerToggle();
        toggle.getElement().setAttribute("aria-label", "Menu toggle");

        viewTitle = new H2();
        viewTitle.addClassNames(LumoUtility.FontSize.LARGE, LumoUtility.Margin.NONE);

        layout.add(toggle, viewTitle);
        return layout;
    }

    private Component createDrawerContent() {
        Scroller scroller = new Scroller();
        H1 appName = new H1("Documentation");
        appName.addClassNames(LumoUtility.FontSize.LARGE, LumoUtility.Margin.MEDIUM);

        SideNav nav = new SideNav();
        nav.addItem(new SideNavItem("Home", HomeView.class, VaadinIcon.HOME.create()));
        nav.addItem(new SideNavItem("Documentation", DocumentationListView.class, VaadinIcon.BOOK.create()));

        scroller.setContent(nav);
        return scroller;
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
