package com.actividades.backend.model;

import jakarta.persistence.*;
@Entity
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombreCompleto;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private Boolean verificado = false;

    private String tokenVerificacion;

    @Column(nullable = false)
    private String origen = "EMAIL"; // EMAIL o GOOGLE

    @Column(nullable = false)
    private Boolean activo = false;

    public Usuario() {}

    public Usuario(String nombreCompleto, String email, String password) {
        this.nombreCompleto = nombreCompleto;
        this.email = email;
        this.password = password;
        this.origen = "EMAIL";
        this.activo = false;
    }


    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombreCompleto() { return nombreCompleto; }
    public void setNombreCompleto(String nombreCompleto) { this.nombreCompleto = nombreCompleto; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public Boolean getVerificado() { return verificado; }
    public void setVerificado(Boolean verificado) { this.verificado = verificado; }

    public String getTokenVerificacion() { return tokenVerificacion; }
    public void setTokenVerificacion(String tokenVerificacion) { this.tokenVerificacion = tokenVerificacion; }

    public String getOrigen() { return origen; }
    public void setOrigen(String origen) { this.origen = origen; }

    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
}