package com.actividades.backend.repository;

import com.actividades.backend.model.Ciudad;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CiudadRepository extends JpaRepository<Ciudad, Long> {
    Optional<Ciudad> findByNombreIgnoreCase(String nombre);
}