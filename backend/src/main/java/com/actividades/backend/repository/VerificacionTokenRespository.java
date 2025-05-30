package com.actividades.backend.repository;

import com.actividades.backend.model.Usuario;
import com.actividades.backend.model.VerificacionToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VerificacionTokenRespository extends JpaRepository<VerificacionToken, Long> {
    Optional<VerificacionToken> findByToken(String token);
    Optional<VerificacionToken> findByUsuario(Usuario usuario);
}