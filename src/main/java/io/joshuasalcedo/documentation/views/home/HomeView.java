package io.joshuasalcedo.documentation.views.home;

import com.vaadin.flow.component.html.H2;
import com.vaadin.flow.component.html.Image;
import com.vaadin.flow.component.html.Paragraph;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import com.vaadin.flow.router.RouteAlias;
import com.vaadin.flow.theme.lumo.LumoUtility.Margin;
import io.joshuasalcedo.documentation.views.main.MainLayout;

@PageTitle("Home")
@Route(value = "home", layout = MainLayout.class)
@RouteAlias(value = "", layout = MainLayout.class)
public class HomeView extends VerticalLayout {

    public HomeView() {
        setSpacing(false);
        
        H2 header = new H2("Welcome to Documentation App");
        header.addClassNames(Margin.Top.XLARGE, Margin.Bottom.MEDIUM);
        add(header);
        
        Paragraph description = new Paragraph("This is a wiki-style documentation system. " +
                "Use the navigation menu to browse through documentation sections or create new entries.");
        add(description);

        Paragraph instructions = new Paragraph("Click on 'Documentation' in the sidebar to view and manage all documentation entries.");
        add(instructions);
        
        setSizeFull();
        setJustifyContentMode(JustifyContentMode.START);
        setDefaultHorizontalComponentAlignment(Alignment.CENTER);
    }
}
