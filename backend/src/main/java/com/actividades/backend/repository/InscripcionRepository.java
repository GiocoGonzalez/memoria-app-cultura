package com.actividades.backend.repository;

import com.actividades.backend.model.Evento;
import com.actividades.backend.model.Inscripcion;
import com.actividades.backend.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InscripcionRepository extends JpaRepository<Inscripcion, Long> {
    boolean existsByUsuarioAndEvento(Usuario usuario, Evento evento);
    List<Inscripcion> findByUsuario(Usuario usuario);
}