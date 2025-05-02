package io.joshuasalcedo.documentation;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class DocumentationApplication extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(DocumentationApplication.class, args);
    }
}