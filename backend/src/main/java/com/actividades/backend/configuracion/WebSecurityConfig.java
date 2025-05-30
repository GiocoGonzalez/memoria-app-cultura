package com.actividades.backend.configuracion;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig {
// CSRF (Cross-Site Request Forgery) se desactiva porque esta API es consumida desde una app móvil,
// la cual no utiliza cookies ni formularios tradicionales, por lo que el riesgo es muy bajo.
// Además, esta configuración facilita las pruebas durante el desarrollo y la integración.
// En entornos productivos web, se recomienda habilitarlo según el contexto


    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable()) // Desactive CSRF para permitir pruebas más sencillas
                //.csrf(csrf ->csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/api/usuarios/registro",
                                "/api/usuarios/login"
                        ).permitAll()
                        .anyRequest().permitAll()  //authenticated() Esto lo cambiaré, pero para rp
                )
                .httpBasic(Customizer.withDefaults());

        return http.build();
    }
    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    } //Encripto contraseñas
}