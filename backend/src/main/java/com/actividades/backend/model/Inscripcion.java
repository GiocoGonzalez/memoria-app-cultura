package com.actividades.backend.model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
public class Inscripcion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    private Usuario usuario;

    @ManyToOne(optional = false)
    private Evento evento;

    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaInscripcion;

    public Inscripcion() {}

    public Inscripcion(Usuario usuario, Evento evento, Date fechaInscripcion) {
        this.usuario = usuario;
        this.evento = evento;
        this.fechaInscripcion = fechaInscripcion;
    }

    // Getters y setters
    public Long getId() { return id; }

    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }

    public Evento getEvento() { return evento; }
    public void setEvento(Evento evento) { this.evento = evento; }

    public Date getFechaInscripcion() { return fechaInscripcion; }
    public void setFechaInscripcion(Date fechaInscripcion) { this.fechaInscripcion = fechaInscripcion; }
}
