package com.actividades.backend.dto;

public class LoginResponse {
    private Long id;
    private String nombreCompleto;
    private String email;
    private String origen;
    private boolean activo;

    public LoginResponse(Long id, String nombreCompleto, String email, String origen, boolean activo) {
        this.id = id;
        this.nombreCompleto = nombreCompleto;
        this.email = email;
        this.origen = origen;
        this.activo = activo;
    }

    // Getters
    public Long getId() {
        return id;
    }

    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public String getEmail() {
        return email;
    }

    public String getOrigen() {
        return origen;
    }

    public boolean isActivo() {
        return activo;
    }
}