package com.actividades.backend.repository;

import com.actividades.backend.model.Evento;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Date;

public interface EventoRepository extends JpaRepository<Evento, Long> {


    Page<Evento> findAll(Pageable pageable);

    Page<Evento> findByCiudad_NombreIgnoreCase(String ciudad, Pageable pageable);

//    Page<Evento> findByCategoria_NombreIgnoreCase(String categoria, Pageable pageable);

//    Page<Evento> findByCiudad_NombreIgnoreCaseAndCategoria_NombreIgnoreCase(String ciudad, String categoria, Pageable pageable);

    Page<Evento> findByCiudad_NombreIgnoreCaseOrCategoria_NombreIgnoreCase(String ciudad, String categoria, Pageable pageable);

    /*Eliminar eventos vencidos */
    int deleteByFechaFinBefore(Date fecha);

    /*Verificación anti-duplicado */
//    boolean existsByTituloIgnoreCaseAndCiudad_NombreIgnoreCaseAndFechaFin(String titulo, String ciudad, Date fechaFin);
}