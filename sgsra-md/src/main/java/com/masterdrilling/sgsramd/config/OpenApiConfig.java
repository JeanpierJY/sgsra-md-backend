package com.masterdrilling.sgsramd.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

// Documentacion de endpoints bajo especificacion OpenAPI / Swagger (RNF37)
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("SGSRA-MD: API de Repuestos y Almacen de Herramientas")
                        .version("1.0.0")
                        .description("Backend corporativo para gestion logistica de Master Drilling Peru S.A.")
                        .contact(new Contact()
                                .name("Master Drilling Taller Mina")
                                .email("soporte.sistemas@masterdrilling.com")));
    }
}