package com.actividades.backend.model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
public class Evento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titulo;

    @ManyToOne
    @JoinColumn(name = "ciudad_id")
    private Ciudad ciudad;

    @Lob
    @Column(columnDefinition = "TEXT", nullable = false)
    private String descripcion;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "categoria_id", nullable = false)
    private Categoria categoria;
    @Temporal(TemporalType.DATE)
    private Date fechaFin;

    @Column(length = 2000)
    private String urlInscripcion;

    public Evento() {
    }

    public Evento(String titulo, Ciudad ciudad, String descripcion, Categoria categoria, Date fechaFin, String urlInscripcion) {
        this.titulo = titulo;
        this.ciudad = ciudad;
        this.descripcion = descripcion;
        this.categoria = categoria;
        this.fechaFin = fechaFin;
        this.urlInscripcion = urlInscripcion;
    }


    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }

    public Ciudad getCiudad() {
        return ciudad;
    }

    public void setCiudad(Ciudad ciudad) {
        this.ciudad = ciudad;
    }

    public Date getFechaFin() {
        return fechaFin;
    }

    public void setFechaFin(Date fechaFin) {
        this.fechaFin = fechaFin;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getUrlInscripcion() {
        return urlInscripcion;
    }

    public void setUrlInscripcion(String urlInscripcion) {
        this.urlInscripcion = urlInscripcion;
    }
}