package com.masterdrilling.sgsramd.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * [GEN-01] Configuracion para exponer recursos estaticos subidos en /uploads/**
 * Permite que clientes web y moviles carguen fotos de repuestos, herramientas y selfies.
 */
@Configuration
public class WebMvcResourceConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        Path uploadDir = Paths.get("uploads").toAbsolutePath().normalize();
        String uploadUri = uploadDir.toUri().toString();
        
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations(uploadUri, "file:" + uploadDir.toString() + "/")
                .setCachePeriod(3600);
    }
}
